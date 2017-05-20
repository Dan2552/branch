RSpec.describe "switching branch" do
  subject { execute(args) }
  let(:args) { %w{new-branch} }

  it "prints that it's switching branch" do
    expect_output /Switching to branch .*new-branch/
  end

  it "switches the branch" do
    subject
    expect_branch "new-branch"
  end

  context "when the branch doesn't exist on remote" do
    it "prints that it's using local branch" do
      expect_output /Using local branch \(no origin branch found\)/
    end
  end

  context "when the working copy has changes" do
    before { touch("changes") }

    it "asks whether to discard changes" do
      expect(Ask).to receive(:list)
                 .with("Continue anyway? Changes will be lost", ["Stop", "Continue"])
      subject
    end
  end

  context "when the branch exists on remote" do
    let(:args) { %w{spec} }
    before { clone_remote_repo }

    context "when the local branch matches the remote" do
      let(:args) { %w{master} }
      before { execute %w{spec --prefer=remote} }

      it "prints that it's using the remote branch" do
        expect_output /Using remote branch/
      end
    end

    context "when the local branch is diverged from the remote" do
      before do
        touch "changes"
        commit
      end
      let(:args) { %w{master} }

      it "asks whether to use the remote or local" do
        expect(Ask).to receive(:list)
                   .with("Keep remote or local copy?", ["Remote", "Local"])
        subject
      end
    end
  end
end
