require "rails_helper"

RSpec.describe BankAccount, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:notifications) }
  end

  it "persists via factory" do
    expect(create(:bank_account)).to be_persisted
  end
end
