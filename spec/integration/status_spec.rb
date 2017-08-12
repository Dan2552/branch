RSpec.describe "status" do
  subject { execute(args) }
  let(:args) { [] }

  it "prints the current branch" do
    expect_output /On branch .*master/
  end

  context "when verbose is enabled" do
    let(:args) { ["--verbose"] }

    it { expect_output(/git reset --mixed.*git add . -A/m) }
    it { expect_output(/git fetch/)}
  end

  context "there are changed files" do
    before do
      touch "awholenewfile"
    end

    it "prints out the files" do
      expect_output /awholenewfile/
    end
  end

  context "there are committed files" do
    before do
      touch "awholenewfile"
      commit
    end

    it "does not print committed files" do
      expect_to_not_output "awholenewfile"
    end
  end

  context "there is an origin branch" do
    before do
      clone_remote_repo
    end

    context "there are commits that are not pushed to origin" do
      before do
        touch "one"
        commit "Add one"
        touch "two"
        commit "Add two"
      end

      it "prints the commits that are not pushed to origin" do
        expect_output /2 commits ahead of origin.*Add two.*Add one/m
      end
    end

    context "there are commits that are on origin that are not in HEAD" do
      before do
        git_reset "--hard HEAD~2"
      end

      it "prints the commits that are not in the local branch" do
        expect_output /2 commits behind origin/
      end
    end
  end
end
