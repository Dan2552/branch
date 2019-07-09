use crate::git_helpers;
use crate::git;
use crate::output::{output_line_in_magenta, output_line_in_light_blue};
use termion::style;

pub fn print_status() {
    git::fetch();
    let current_branch = git_helpers::current_branch();

    println!("On branch {}{}{}", style::Bold, current_branch, style::Reset);
    print_commits_behind_and_ahead_of_origin(&current_branch);
    git_helpers::print_uncommited_files();
}

pub fn print_commits_behind_and_ahead_of_origin(branch: &str) {
    let commits_behind = git_helpers::commits_behind_origin(&branch);
    let commits_behind_count = commits_behind.len();
    if commits_behind_count > 0 {
        println!("\n{} commits behind origin", commits_behind_count);
        for commit in commits_behind {
            output_line_in_magenta(&format!("  {}", commit));
        }
    }

    let commits_ahead = git_helpers::commits_ahead_of_origin(&branch);
    let commits_ahead_count = commits_ahead.len();
    if commits_ahead_count > 0 {
        println!("\n{} commits ahead of origin", commits_ahead_count);
        for commit in commits_ahead {
            output_line_in_light_blue(&format!("  {}", commit));
        }
    }
}
