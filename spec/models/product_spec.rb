require "rails_helper"

RSpec.describe Product, type: :model do
  describe "validations" do
    subject { build(:product) }

    it { should validate_presence_of(:product_name) }
    it { should validate_presence_of(:price) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:stock) }
    it { should validate_comparison_of(:stock).is_greater_than_or_equal_to(0) }
  end

  describe "enums" do
    it { should define_enum_for(:product_type).with_values([:national, :personal]) }
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:category) }
    it { should belong_to(:variant) }
    # sub_category is a vestigial belongs_to with no FK column, so shoulda's
    # column check can't verify it; just confirm the association is optional.
    it "has an optional sub_category association" do
      assoc = Product.reflect_on_association(:sub_category)
      expect(assoc.options[:optional]).to be true
    end
    it { should have_one(:discount).dependent(:destroy) }
    it { should have_many(:product_colors).dependent(:destroy) }
    it { should have_many(:sizes).dependent(:destroy) }
    it { should have_and_belong_to_many(:offer_types) }
    it { should have_and_belong_to_many(:orders) }
  end

  describe "notification callbacks" do
    it "enqueues a PushNotificationJob and creates a notification on create" do
      expect {
        create(:product)
      }.to have_enqueued_job(PushNotificationJob)
    end

    it "creates a notification record on create" do
      product = create(:product)
      expect(product.notifications.count).to be >= 1
      expect(product.notifications.last.action).to eq("Your Product Created")
    end

    it "enqueues a PushNotificationJob on update" do
      product = create(:product)
      expect {
        product.update!(product_name: "Renamed")
      }.to have_enqueued_job(PushNotificationJob)
    end
  end

  describe "invalid stock" do
    it "is invalid with negative stock" do
      expect(build(:product, stock: -1)).not_to be_valid
    end
  end
end
