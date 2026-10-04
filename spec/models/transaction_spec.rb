require "rails_helper"

RSpec.describe Transaction, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:order) }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values([:pending, :paid]) }
  end

  it "persists via factory" do
    expect(create(:transaction)).to be_persisted
  end
end
