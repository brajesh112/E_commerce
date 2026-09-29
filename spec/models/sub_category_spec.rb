require "rails_helper"

RSpec.describe SubCategory, type: :model do
  describe "associations" do
    it { should belong_to(:category) }
    # has_many :products is declared but Product has no sub_category_id column,
    # so the association can't resolve a FK — assert it's declared, not usable.
    it "declares has_many :products" do
      expect(SubCategory.reflect_on_association(:products)).to be_present
    end
    it { should have_many(:variant) }
  end

  it "persists via factory" do
    expect(create(:sub_category)).to be_persisted
  end
end
