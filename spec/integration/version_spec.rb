RSpec.describe "Version" do
  subject { execute(args) }
  let(:args) { %w{--version} }

  it "prints out the version number of the release" do
    expect_output /branch cli 0.8.0/
  end
end
