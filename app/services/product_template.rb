require "caxlsx"

# Builds the downloadable .xlsx bulk-upload template: a "Products" entry sheet
# plus reference sheets listing the valid category / sub-category / variant codes
# so sellers know exactly which codes to use.
class ProductTemplate
  PRODUCT_HEADERS = %w[
    product_name seller_email category_code sub_category_code variant_code
    product_type price discount_price stock description image_urls
  ].freeze

  def self.workbook
    new.workbook
  end

  def workbook
    package = Axlsx::Package.new
    wb = package.workbook

    wb.add_worksheet(name: "Products") do |sheet|
      sheet.add_row PRODUCT_HEADERS
      sheet.add_row example_row
    end

    wb.add_worksheet(name: "Category Codes") do |sheet|
      sheet.add_row %w[code category]
      Category.order(:categories_type).each { |c| sheet.add_row [c.code, c.categories_type] }
    end

    wb.add_worksheet(name: "Sub Category Codes") do |sheet|
      sheet.add_row %w[code sub_category category_code]
      SubCategory.includes(:category).order(:name).each do |s|
        sheet.add_row [s.code, s.name, s.category&.code]
      end
    end

    wb.add_worksheet(name: "Variant Codes") do |sheet|
      sheet.add_row %w[code variant sub_category_code]
      Variant.includes(:sub_category).order(:variant_name).each do |v|
        sheet.add_row [v.code, v.variant_name, v.sub_category&.code]
      end
    end

    package
  end

  private

  # A realistic example using the first real codes available, so the row works
  # if left as-is (minus seller_email, which the admin fills).
  def example_row
    category = Category.first
    sub      = category&.sub_categories&.first
    variant  = sub&.variant&.first
    [
      "Sample Product", "seller@example.com",
      category&.code, sub&.code, variant&.code,
      "national", 999, 799, 25, "A short product description",
      "https://example.com/img1.jpg | https://example.com/img2.jpg"
    ]
  end
end
