require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability, type: :model do
  describe "admin" do
    let(:admin) { create(:user, :admin) }
    subject(:ability) { Ability.new(admin) }

    it "can manage arbitrary resources" do
      expect(ability.can?(:manage, Product.new)).to be true
      expect(ability.can?(:manage, User.new)).to be true
    end

    it "cannot manage Transaction but can read it" do
      expect(ability.can?(:manage, Transaction.new)).to be false
      expect(ability.can?(:update, Transaction.new)).to be false
      expect(ability.can?(:read, Transaction.new)).to be true
    end
  end

  describe "non-admin (buyer/seller)" do
    let(:user) { create(:user) }
    subject(:ability) { Ability.new(user) }

    it "can read general resources" do
      expect(ability.can?(:read, Category.new)).to be true
    end

    it "cannot read User, BankAccount, or Transaction generally" do
      expect(ability.can?(:read, User.new)).to be false
      expect(ability.can?(:read, BankAccount.new)).to be false
      expect(ability.can?(:read, Transaction.new)).to be false
    end

    it "can read and update its own User record" do
      expect(ability.can?(:read, user)).to be true
      expect(ability.can?(:update, user)).to be true
    end

    it "cannot update another user's User record" do
      other = create(:user)
      expect(ability.can?(:update, other)).to be false
    end

    it "can manage its own products" do
      own_product = build(:product, user: user)
      expect(ability.can?(:manage, own_product)).to be true
    end

    it "cannot manage another user's product" do
      other_product = build(:product, user: create(:user))
      expect(ability.can?(:manage, other_product)).to be false
    end

    it "can manage its own bank account but not another's" do
      own = build(:bank_account, user: user)
      other = build(:bank_account, user: create(:user))
      expect(ability.can?(:manage, own)).to be true
      expect(ability.can?(:manage, other)).to be false
    end
  end
end
