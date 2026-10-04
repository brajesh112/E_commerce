require "roo"

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
    product.images.attach(io: File.open(PLACEHOLDER_IMAGE), filename: "product.png", content_type: "image/png")

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
