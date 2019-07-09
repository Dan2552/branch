use crate::git;
use crate::git_helpers;
use crate::status;
use crate::prompt;
use crate::output::{output_line_in_red, output_line_in_green, output_line_in_yellow};
use crate::output::format_as_bold;
use shell::ShellResultExt;

pub fn set_branch(target_branch: &str) {
    println!("Switching to branch {}...", format_as_bold(target_branch));

    git::fetch();
    detect_changes();
    let _ = git::reset(git::ResetMode::Hard, "");
    switch_branch(target_branch);
    detect_ahead(target_branch);
    reset_to_origin(target_branch);
}

fn detect_changes() {
    let files = git_helpers::uncommitted_files();

    if files.len() == 0 {
        return
    }

    output_line_in_yellow("\nThere are uncommitted changes");
    git_helpers::print_uncommited_files();
    prompt::continue_anyway()
}

fn switch_branch(target_branch: &str) {
    let _ = git::checkout(&target_branch);
    let current_branch = git_helpers::current_branch();

    if current_branch != target_branch {
        let _ = git::checkout(&format!("-b {}", target_branch));
    }

    let _ = git::branch(&format!("--set-upstream-to=origin/{}", target_branch));

    // refetch the current branch to confirm whether the switch was successful
    let current_branch = git_helpers::current_branch();

    if current_branch != target_branch {
        output_line_in_red("Failed to switch branch");
        std::process::exit(1);
    }
}

fn detect_ahead(target_branch: &str) {
    let status = git::status(&"");

    // On branch master
    // Your branch and 'origin/master' have diverged,
    // and have 1 and 1 different commit each, respectively.
    //   (use "git pull" to merge the remote branch into yours)
    // nothing to commit, working directory clean
    //
    // On branch master
    // Your branch is behind 'origin/master' by 1 commit, and can be fast-forwarded.
    //   (use "git pull" to update your local branch)
    // nothing to commit, working directory clean
    //
    // On branch master
    // Your branch is ahead of 'origin/master' by 1 commit.
    //   (use "git push" to publish your local commits)
    // nothing to commit, working directory clean
    let diverged = status.contains("can be fast-forwarded.") ||
        status.contains("is ahead of 'origin") ||
        status.contains(" have diverged");

    if diverged {
        output_line_in_yellow("\nLocal and remote branches have diverged");
        status::print_commits_behind_and_ahead_of_origin(&target_branch);
        prompt::keep_local();
    }
}

fn reset_to_origin(target_branch: &str) {
    let origin = format!("origin/{}", target_branch);
    let output = git::reset(git::ResetMode::Hard, &origin);

    if output.code() == 0 {
        output_line_in_green("Using remote branch");
    } else {
        output_line_in_green("Using local branch (no origin branch found)");
    }
}