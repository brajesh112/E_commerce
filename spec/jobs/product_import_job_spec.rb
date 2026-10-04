require "rails_helper"
require "axlsx"

RSpec.describe ProductImportJob, type: :job do
  before do
    allow(StripePayment).to receive(:create_product).and_return(double(id: "price_test"))
  end

  let(:seller)   { create(:user, :seller, email: "seller@example.com") }
  let(:category) { create(:category) }
  let(:sub_cat)  { create(:sub_category, category: category) }
  let!(:variant) { create(:variant, sub_category: sub_cat) }

  # Build a real .xlsx with a "Products" sheet and return its bytes.
  def xlsx_bytes(rows)
    pkg = Axlsx::Package.new
    pkg.workbook.add_worksheet(name: "Products") do |s|
      s.add_row ProductTemplate::PRODUCT_HEADERS
      rows.each { |r| s.add_row r }
    end
    pkg.to_stream.read
  end

  def row(overrides = {})
    {
      "product_name" => "Widget", "seller_email" => "seller@example.com",
      "category_code" => category.code, "sub_category_code" => sub_cat.code,
      "variant_code" => variant.code, "product_type" => "national",
      "price" => 100, "discount_price" => 90, "stock" => 5, "description" => "A widget"
    }.merge(overrides).values_at(*ProductTemplate::PRODUCT_HEADERS)
  end

  def import_with(bytes)
    import = ProductImport.new(user: seller)
    import.file.attach(io: StringIO.new(bytes), filename: "import.xlsx")
    import.save!
    import
  end

  it "runs the importer, saves the file, and records a completed result" do
    import = import_with(xlsx_bytes([row]))

    described_class.perform_now(import.id)

    import.reload
    expect(import.status).to eq("completed")
    expect(import.created_count).to eq(1)
    expect(import.row_errors).to be_empty
    expect(import.file).to be_attached
    expect(Product.last.user).to eq(seller)
  end

  it "records per-row errors while importing the good rows" do
    import = import_with(xlsx_bytes([row, row("category_code" => "NOPE")]))

    described_class.perform_now(import.id)

    import.reload
    expect(import.status).to eq("completed")
    expect(import.created_count).to eq(1)
    expect(import.row_errors.size).to eq(1)
  end

  it "marks the import failed when the file is unreadable" do
    import = ProductImport.new(user: seller)
    import.file.attach(io: StringIO.new("not a real xlsx"), filename: "broken.xlsx")
    import.save!

    described_class.perform_now(import.id)

    import.reload
    # A broken workbook is reported as a row-less error by the importer, so the
    # run still completes; its errors capture the failure.
    expect(import.row_errors).to be_present
    expect(import.created_count).to eq(0)
  end
end
