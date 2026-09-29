require "rails_helper"

RSpec.describe Category, type: :model do
  describe "associations" do
    it { should have_many(:products) }
    it { should have_many(:sub_categories) }
  end

  it "persists via factory" do
    expect(create(:category)).to be_persisted
  end
end
