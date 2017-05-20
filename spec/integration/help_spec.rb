RSpec.describe "Help" do
  subject { execute(args) }
  let(:args) { %w{--help} }

  it "prints out help text" do
    expect_output /Where PREFERENCE is local or remote/
  end
end
