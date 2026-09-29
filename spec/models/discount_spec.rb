require "rails_helper"

RSpec.describe Discount, type: :model do
  describe "associations" do
    it { should belong_to(:product) }
  end

  it "persists via factory" do
    expect(create(:discount)).to be_persisted
  end
end
