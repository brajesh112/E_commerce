require "rails_helper"
require "axlsx"

RSpec.describe ProductImporter do
  # Stub only the 3rd-party Stripe call; DB work is real.
  before do
    allow(StripePayment).to receive(:create_product).and_return(double(id: "price_test"))
  end

  let(:seller)   { create(:user, :seller, email: "seller@example.com") }
  let(:category) { create(:category) }
  let(:sub_cat)  { create(:sub_category, category: category) }
  let!(:variant) { create(:variant, sub_category: sub_cat) }

  # Build a real .xlsx in tmp with a "Products" sheet and return its path.
  def xlsx_with(rows, headers: ProductTemplate::PRODUCT_HEADERS)
    pkg = Axlsx::Package.new
    pkg.workbook.add_worksheet(name: "Products") do |s|
      s.add_row headers
      rows.each { |r| s.add_row r }
    end
    path = Rails.root.join("tmp", "import_#{SecureRandom.hex(6)}.xlsx")
    pkg.serialize(path.to_s)
    path.to_s
  end

  def row(overrides = {})
    {
      "product_name" => "Widget", "seller_email" => "seller@example.com",
      "category_code" => category.code, "sub_category_code" => sub_cat.code,
      "variant_code" => variant.code, "product_type" => "national",
      "price" => 100, "discount_price" => 90, "stock" => 5, "description" => "A widget"
    }.merge(overrides).values_at(*ProductTemplate::PRODUCT_HEADERS)
  end

  it "imports a valid row into a product owned by the seller" do
    path = xlsx_with([row])
    result = described_class.new(path, seller).call

    expect(result.created).to eq(1)
    expect(result.errors).to be_empty
    product = Product.last
    expect(product.user).to eq(seller)
    expect(product.category).to eq(category)
    expect(product.variant).to eq(variant)
    expect(product.images).to be_attached
    expect(product.price_id).to eq("price_test")
  end

  it "fails only the bad row and still imports the good ones" do
    path = xlsx_with([row, row("category_code" => "NOPE")])
    result = described_class.new(path, seller).call

    expect(result.created).to eq(1)
    expect(result.errors.size).to eq(1)
    expect(result.errors.first[:row]).to eq(3)
    expect(result.errors.first[:messages].join).to match(/category_code/)
  end

  it "ignores seller_email and assigns to the uploader when a seller uploads" do
    other = create(:user, :seller, email: "other@example.com")
    path = xlsx_with([row("seller_email" => other.email)])
    described_class.new(path, seller).call
    expect(Product.last.user).to eq(seller)
  end

  context "when an admin uploads" do
    let(:admin) { create(:user, :admin) }

    it "assigns each product to the seller named by seller_email" do
      path = xlsx_with([row("seller_email" => seller.email)])
      result = described_class.new(path, admin).call
      expect(result.created).to eq(1)
      expect(Product.last.user).to eq(seller)
    end

    it "errors a row whose seller_email is unknown" do
      path = xlsx_with([row("seller_email" => "ghost@example.com")])
      result = described_class.new(path, admin).call
      expect(result.created).to eq(0)
      expect(result.errors.first[:messages].join).to match(/seller_email/)
    end
  end

  it "uses the sub-category's first variant when variant_code is blank" do
    path = xlsx_with([row("variant_code" => nil)])
    result = described_class.new(path, seller).call
    expect(result.created).to eq(1)
    expect(Product.last.variant).to eq(variant)
  end

  it "errors when the sub-category has no variant" do
    empty_sub = create(:sub_category, category: category)
    path = xlsx_with([row("sub_category_code" => empty_sub.code, "variant_code" => nil)])
    result = described_class.new(path, seller).call
    expect(result.created).to eq(0)
    expect(result.errors.first[:messages].join).to match(/variant/)
  end

  describe "image_urls" do
    let(:png) { File.binread(described_class::PLACEHOLDER_IMAGE) }

    before do
      # Bypass DNS/SSRF resolution in tests; only the HTTP fetch is stubbed.
      allow_any_instance_of(described_class).to receive(:public_host?).and_return(true)
    end

    it "downloads and attaches images from the URLs (no placeholder)" do
      stub_request(:get, "https://cdn.example.test/a.png")
        .to_return(body: png, headers: { "Content-Type" => "image/png" })
      stub_request(:get, "https://cdn.example.test/b.png")
        .to_return(body: png, headers: { "Content-Type" => "image/png" })

      path = xlsx_with([row("image_urls" => "https://cdn.example.test/a.png | https://cdn.example.test/b.png")])
      result = described_class.new(path, seller).call

      expect(result.created).to eq(1)
      product = Product.last
      expect(product.images.count).to eq(2)
      expect(product.images.map(&:filename).map(&:to_s)).to contain_exactly("a.png", "b.png")
    end

    it "falls back to the placeholder when a download fails" do
      stub_request(:get, "https://cdn.example.test/missing.png").to_return(status: 404)

      path = xlsx_with([row("image_urls" => "https://cdn.example.test/missing.png")])
      result = described_class.new(path, seller).call

      expect(result.created).to eq(1)
      product = Product.last
      expect(product.images.count).to eq(1)
      expect(product.images.first.filename.to_s).to eq("product.png")
    end

    it "rejects a non-public host without attempting the fetch" do
      allow_any_instance_of(described_class).to receive(:public_host?).and_call_original
      allow(Resolv).to receive(:getaddresses).and_return(["127.0.0.1"])

      path = xlsx_with([row("image_urls" => "http://localhost/secret.png")])
      result = described_class.new(path, seller).call

      expect(result.created).to eq(1)
      expect(Product.last.images.first.filename.to_s).to eq("product.png")
    end
  end
end
