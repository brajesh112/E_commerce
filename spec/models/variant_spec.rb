require "rails_helper"

RSpec.describe Variant, type: :model do
  describe "associations" do
    it { should belong_to(:sub_category) }
    it { should have_many(:products) }
    it { should have_many(:product_size) }
  end

  it "stores a decimal category_comission" do
    variant = create(:variant, category_comission: 12.5)
    expect(variant.category_comission).to eq(12.5)
  end
end
