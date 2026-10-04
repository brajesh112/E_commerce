require "rails_helper"

RSpec.describe Category, type: :model do
  describe "associations" do
    it { should have_many(:products) }
    it { should have_many(:sub_categories) }
  end

  it "persists via factory" do
    expect(create(:category)).to be_persisted
  end

  describe "code" do
    it "auto-generates a code from the name when blank" do
      category = create(:category, categories_type: "Home & Kitchen", code: nil)
      expect(category.code).to eq("HOME_KITCHEN")
    end

    it "keeps codes unique by suffixing collisions" do
      create(:category, categories_type: "Books", code: nil)
      second = create(:category, categories_type: "Books", code: nil)
      expect(second.code).to eq("BOOKS_1")
    end
  end
end
