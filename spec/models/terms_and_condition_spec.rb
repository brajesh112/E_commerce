require "rails_helper"

RSpec.describe TermsAndCondition, type: :model do
  it "persists via factory" do
    record = create(:terms_and_condition)
    expect(record).to be_persisted
    expect(record.terms).to eq("Be nice.")
  end
end
