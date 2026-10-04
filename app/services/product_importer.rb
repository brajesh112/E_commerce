require "roo"
require "net/http"
require "resolv"
require "ipaddr"

# Bulk-creates products from an uploaded .xlsx (the "Products" sheet of the
# template). Each row is processed independently: one bad row never aborts the
# rest. Returns a Result with the created count and per-row errors.
#
# Only the Stripe price creation (a 3rd-party call) is optional/best-effort; the
# DB work is real.
class ProductImporter
  MAX_ROWS = 1000
  SHEET    = "Products".freeze
  PLACEHOLDER_IMAGE = Rails.root.join("app/assets/images/profile.png")
  MAX_IMAGE_BYTES = 5 * 1024 * 1024
  MAX_IMAGES_PER_ROW = 5
  IMAGE_URL_SEPARATOR = /[\s,|]+/

  Result = Struct.new(:created, :errors, keyword_init: true) do
    def summary
      msg = "#{created} product(s) imported."
      msg += " #{errors.size} row(s) failed." if errors.any?
      msg
    end
  end

  def initialize(file, uploader)
    @file = file
    @uploader = uploader
    @errors = []
    @created = 0
  end

  def call
    sheet = open_sheet
    return Result.new(created: 0, errors: @errors) if sheet.nil?

    headers = sheet.row(1).map { |h| h.to_s.strip.downcase.gsub(/\s+/, "_") }
    last = [sheet.last_row.to_i, MAX_ROWS + 1].min

    (2..last).each do |n|
      row = headers.zip(sheet.row(n)).to_h
      next if row.values.all?(&:blank?) # skip empty lines
      import_row(row, n)
    end

    Result.new(created: @created, errors: @errors)
  end

  private

  def open_sheet
    path = @file.respond_to?(:path) ? @file.path : @file.to_s
    name = @file.respond_to?(:original_filename) ? @file.original_filename : path
    unless name.to_s.downcase.end_with?(".xlsx")
      @errors << { row: nil, messages: ["File must be an .xlsx workbook"] }
      return nil
    end
    xlsx = Roo::Excelx.new(path)
    unless xlsx.sheets.include?(SHEET)
      @errors << { row: nil, messages: ["Workbook is missing a '#{SHEET}' sheet"] }
      return nil
    end
    xlsx.sheet(SHEET)
  rescue StandardError => e
    @errors << { row: nil, messages: ["Could not read the file: #{e.message}"] }
    nil
  end

  def import_row(row, line)
    owner        = resolve_owner(row)
    category     = Category.find_by("UPPER(code) = ?", row["category_code"].to_s.strip.upcase)
    sub_category = resolve_sub_category(category, row["sub_category_code"])
    variant      = resolve_variant(sub_category, row["variant_code"])

    missing = []
    missing << "unknown seller_email '#{row["seller_email"]}'" if owner.nil?
    missing << "unknown category_code '#{row["category_code"]}'" if category.nil?
    missing << "unknown sub_category_code '#{row["sub_category_code"]}' for this category" if category && sub_category.nil?
    missing << "no variant found for this sub-category" if sub_category && variant.nil?
    if missing.any?
      @errors << { row: line, messages: missing }
      return
    end

    product = Product.new(
      product_name: row["product_name"],
      description:  row["description"],
      price:        row["price"],
      discount_price: row["discount_price"].presence,
      stock:        row["stock"],
      product_type: product_type_for(row["product_type"]),
      user:         owner,
      category:     category,
      variant:      variant
    )
    attach_images(product, row["image_urls"])

    if product.save
      assign_price_id(product)
      @created += 1
    else
      @errors << { row: line, messages: product.errors.full_messages }
    end
  rescue StandardError => e
    @errors << { row: line, messages: [e.message] }
  end

  # Sellers own their own uploads; admins assign per row via seller_email.
  def resolve_owner(row)
    return @uploader if @uploader.seller?
    User.find_by(email: row["seller_email"].to_s.strip, role: User.roles[:seller])
  end

  def resolve_sub_category(category, code)
    return nil if category.nil? || code.blank?
    category.sub_categories.find_by("UPPER(code) = ?", code.to_s.strip.upcase)
  end

  def resolve_variant(sub_category, code)
    return nil if sub_category.nil?
    if code.present?
      sub_category.variant.find_by("UPPER(code) = ?", code.to_s.strip.upcase)
    else
      sub_category.variant.first
    end
  end

  # Attach images from the comma/space/pipe-separated image_urls cell. Falls back
  # to the placeholder when none are given or all downloads fail, so product
  # listings never hit the Cloudinary nil-attachment bug.
  def attach_images(product, urls_cell)
    urls = urls_cell.to_s.split(IMAGE_URL_SEPARATOR).map(&:strip).reject(&:blank?).first(MAX_IMAGES_PER_ROW)
    attached = 0
    urls.each do |url|
      image = download_image(url)
      next if image.nil?
      product.images.attach(io: StringIO.new(image[:body]), filename: image[:filename], content_type: image[:content_type])
      attached += 1
    end
    return unless attached.zero?
    product.images.attach(io: File.open(PLACEHOLDER_IMAGE), filename: "product.png", content_type: "image/png")
  end

  # Fetch an image over HTTP(S) with SSRF guards (public hosts only), a size cap,
  # and a content-type check. Returns nil on any problem — a bad image URL never
  # fails the row.
  def download_image(url)
    uri = URI.parse(url)
    return nil unless uri.is_a?(URI::HTTP) && uri.host.present?
    return nil unless public_host?(uri.host)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                              open_timeout: 5, read_timeout: 10) do |http|
      http.get(uri.request_uri)
    end
    return nil unless response.is_a?(Net::HTTPSuccess)

    content_type = response.content_type.to_s
    return nil unless content_type.start_with?("image/")
    body = response.body.to_s
    return nil if body.bytesize.zero? || body.bytesize > MAX_IMAGE_BYTES

    { body: body, content_type: content_type,
      filename: File.basename(uri.path).presence || "image" }
  rescue StandardError
    nil
  end

  # Reject loopback / private / link-local addresses to blunt SSRF.
  def public_host?(host)
    Resolv.getaddresses(host).any? do |ip|
      addr = IPAddr.new(ip) rescue nil
      addr && !addr.loopback? && !addr.private? && !addr.link_local?
    end
  rescue StandardError
    false
  end

  def product_type_for(value)
    key = value.to_s.strip.downcase
    Product.product_types.key?(key) ? key : "national"
  end

  # Best-effort Stripe price so card-via-Stripe checkout works; import still
  # succeeds without Stripe configured.
  def assign_price_id(product)
    price = StripePayment.create_product(product)
    product.update_column(:price_id, price.id) if price&.id
  rescue Stripe::StripeError
    nil
  end
end
