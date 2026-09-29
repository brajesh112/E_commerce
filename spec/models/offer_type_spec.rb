require "rails_helper"

RSpec.describe OfferType, type: :model do
  describe "associations" do
    it { should have_and_belong_to_many(:products) }
  end

  it "persists via factory" do
    expect(create(:offer_type)).to be_persisted
  end
end
