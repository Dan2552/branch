RSpec.describe "Version" do
  subject { execute(args) }
  let(:args) { %w{--version} }

  it "prints out the version number of the release" do
    spec = Gem::Specification::load("#{BranchCli.root}/branch_cli.gemspec")
    expect_output /branch cli #{spec.version}/
  end
end
