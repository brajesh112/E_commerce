require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:phone_number) }
    it { should validate_length_of(:phone_number).is_equal_to(10) }
  end

  describe "enums" do
    it { should define_enum_for(:role).with_values([:admin, :buyer, :seller]) }
  end

  describe "associations" do
    it { should have_one(:cart).dependent(:destroy) }
    it { should have_many(:orders).dependent(:destroy) }
    it { should have_many(:products).dependent(:destroy) }
    it { should have_many(:addresses).dependent(:destroy) }
    it { should have_many(:bank_accounts).dependent(:destroy) }
    it { should have_many(:notifications).dependent(:destroy) }
    it { should have_many(:otps).dependent(:destroy) }
    it { should have_many(:device_tokens).dependent(:destroy) }
    it { should have_many(:transactions) }
  end

  describe "after_create callbacks" do
    let(:user) { create(:user) }

    it "auto-creates a cart" do
      expect(user.cart).to be_present
      expect(user.cart).to be_a(Cart)
    end

    it "attaches a default avatar" do
      expect(user.avatar).to be_attached
    end
  end

  describe "role predicate methods" do
    it "#admin? is true for admin role" do
      expect(build(:user, :admin).admin?).to be true
    end

    it "#buyer? is true for buyer role" do
      expect(build(:user).buyer?).to be true
    end

    it "#seller? is true for seller role" do
      expect(build(:user, :seller).seller?).to be true
    end

    it "predicates are false for other roles" do
      admin = build(:user, :admin)
      expect(admin.buyer?).to be false
      expect(admin.seller?).to be false
    end
  end

  describe "phone_number length" do
    it "is invalid when not exactly 10 digits" do
      expect(build(:user, phone_number: "12345")).not_to be_valid
    end
  end
end
