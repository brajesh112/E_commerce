require "rails_helper"

RSpec.describe Size, type: :model do
  describe "associations" do
    it { should belong_to(:product_size) }
    it { should belong_to(:product) }
  end

  it "persists via factory" do
    expect(create(:size)).to be_persisted
  end
end
