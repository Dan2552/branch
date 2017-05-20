RSpec.describe "status" do
  subject { execute(args) }
  let(:args) { [] }

  it "prints the current branch" do
    expect_output /On branch .*master/
  end

  context "when there are changed files" do
    before do
      touch "awholenewfile"
    end

    it "prints out the files" do
      expect_output /awholenewfile/
    end
  end

  context "when there are committed files" do
    before do
      touch "awholenewfile"
      commit
    end

    it "does not print committed files" do
      expect_to_not_output "awholenewfile"
    end
  end
end
