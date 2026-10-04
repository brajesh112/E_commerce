require "rails_helper"

RSpec.describe ProductSize, type: :model do
  describe "associations" do
    it { should belong_to(:variant) }
    it { should have_many(:sizes).dependent(:destroy) }
    it { should have_many(:products).through(:sizes) }
  end

  it "persists via factory" do
    expect(create(:product_size)).to be_persisted
  end
end
