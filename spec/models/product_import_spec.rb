require "rails_helper"

RSpec.describe ProductImport, type: :model do
  it { is_expected.to belong_to(:user) }

  it "defines the status states" do
    expect(described_class.statuses.keys).to contain_exactly("pending", "processing", "completed", "failed")
  end

  it "defaults to pending with no errors" do
    import = described_class.new
    expect(import.status).to eq("pending")
    expect(import.row_errors).to eq([])
  end

  it "requires an attached file" do
    import = described_class.new(user: create(:user, :seller))
    expect(import).not_to be_valid
    expect(import.errors[:file]).to be_present
  end

  it "stores the uploaded file" do
    import = described_class.new(user: create(:user, :seller))
    import.file.attach(io: StringIO.new("data"), filename: "import.xlsx")
    expect(import).to be_valid
    expect(import.file).to be_attached
  end
end
