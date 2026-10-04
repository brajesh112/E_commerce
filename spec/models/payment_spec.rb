require "rails_helper"

RSpec.describe Payment, type: :model do
  describe "associations" do
    it { should belong_to(:order) }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values([:success, :failed]) }
  end

  describe "validations" do
    subject { create(:payment) } # uniqueness needs a persisted record
    it { should validate_presence_of(:payment_id) }
    it { should validate_uniqueness_of(:payment_id) }
  end

  it "persists via factory" do
    expect(create(:payment)).to be_persisted
  end
end
