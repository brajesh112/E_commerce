require "rails_helper"

RSpec.describe Otp, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  it "persists via factory" do
    expect(create(:otp)).to be_persisted
  end
end
