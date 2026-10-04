require "rails_helper"

RSpec.describe Address, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:orders).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:address) }

    it { should validate_presence_of(:house_no) }
    it { should validate_presence_of(:street) }
    it { should validate_presence_of(:landmark) }
    it { should validate_presence_of(:country) }
    it { should validate_presence_of(:pin) }

    it "is valid with country VA and blank state/city" do
      expect(build(:address, country: "VA", state: nil, city: nil)).to be_valid
    end
  end

  describe "CS-backed option methods" do
    let(:address) { build(:address, country: "VA") }

    it "#country_opts returns a hash including VA" do
      opts = address.country_opts
      expect(opts).to be_a(Hash)
      expect(opts.keys).to include("VA")
    end

    it "#country_name returns the readable country name" do
      expect(address.country_name).to eq(address.country_opts["VA"])
    end

    it "#state_opts returns a hash" do
      expect(address.state_opts).to be_a(Hash)
    end

    it "#city_opts returns an array-like collection" do
      expect(address.city_opts).to respond_to(:each)
    end
  end
end
