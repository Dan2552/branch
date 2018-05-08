RSpec.describe "status" do
  subject { execute(args) }
  let(:args) { [] }

  it { is_expected_to_exit_with(0) }

  it "prints the current branch" do
    expect_output /On branch .*master/
  end

  context "when verbose is enabled" do
    let(:args) { ["--verbose"] }

    it { is_expected_to_exit_with(0) }
    it { expect_output(/git reset --mixed.*git add . -A/m) }
    it { expect_output(/git fetch/)}
  end

  context "there are changed files" do
    before do
      touch "awholenewfile"
    end

    it { is_expected_to_exit_with(0) }

    it "prints out the files" do
      expect_output /1 uncommited changed files.*awholenewfile/m
    end
  end

  context "there are no changed files" do
    it { is_expected_to_exit_with(0) }

    it "does not print uncommited changed files" do
      expect_to_not_output /uncommited changed files/
    end
  end

  context "there are committed files" do
    before do
      touch "awholenewfile"
      commit
    end

    it { is_expected_to_exit_with(0) }

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

      it { is_expected_to_exit_with(0) }

      it "prints the commits that are not pushed to origin" do
        expect_output /2 commits ahead of origin.*Add two.*Add one/m
      end
    end

    context "there are commits that are on origin that are not in HEAD" do
      before do
        git_reset "--hard HEAD~2"
      end

      it { is_expected_to_exit_with(0) }

      it "prints the commits that are not in the local branch" do
        expect_output /commits behind origin/
      end

      it "prints the commits" do
        expect_output `git log origin/master -1 --format=%B`.gsub("\n", "").chomp
        expect_output `git log origin/master -1 --format=%h`.gsub("\n", "").chomp
      end
    end
  end
end
