require "rails_helper"

RSpec.describe OrderItem, type: :model do
  describe "associations" do
    it { should belong_to(:order) }
    it { should belong_to(:product) }
  end

  it "persists via factory" do
    expect(create(:order_item)).to be_persisted
  end
end
