require "rails_helper"

RSpec.describe ProductColor, type: :model do
  describe "associations" do
    it { should belong_to(:product) }
  end

  it "persists via factory" do
    expect(create(:product_color)).to be_persisted
  end
end
