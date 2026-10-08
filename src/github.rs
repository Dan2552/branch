use crate::output::output_line_in_blue;
use regex::Regex;
use std::process::{Command, Stdio};

pub fn is_url(input: &str) -> bool {
    input.starts_with("https://") || input.starts_with("http://")
}

// Resolves a GitHub URL to a branch name. Supports:
//   https://github.com/owner/repo/pull/123 (and sub-pages like /files)
//   https://github.com/owner/repo/tree/branch-name
pub fn branch_from_url(url: &str, is_verbose: bool) -> Result<String, String> {
    let url = url.split(|c| c == '?' || c == '#').next().unwrap_or(url);

    let pull_regex = Regex::new(r"^(?P<pr>https?://[^/]+/[^/]+/[^/]+/pull/\d+)(/.*)?$").unwrap();
    if let Some(captures) = pull_regex.captures(url) {
        return pull_request_branch(&captures["pr"], is_verbose);
    }

    let tree_regex = Regex::new(r"^https?://[^/]+/[^/]+/[^/]+/tree/(?P<branch>.+?)/?$").unwrap();
    if let Some(captures) = tree_regex.captures(url) {
        return Ok(captures["branch"].to_string());
    }

    Err(format!("Unrecognised GitHub URL: {}", url))
}

fn pull_request_branch(pr_url: &str, is_verbose: bool) -> Result<String, String> {
    let args = ["pr", "view", pr_url, "--json", "headRefName", "--jq", ".headRefName"];

    if is_verbose {
        output_line_in_blue(&format!("gh {}", args.join(" ")));
    }

    let output = Command::new("gh")
        .args(&args)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .output()
        .map_err(|_| String::from("Failed to run gh (is the GitHub CLI installed?)"))?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr).trim().to_string();
        return Err(format!("Failed to look up pull request with gh: {}", stderr));
    }

    let branch = String::from_utf8_lossy(&output.stdout).trim().to_string();

    if branch.is_empty() {
        return Err(String::from("gh did not return a branch name for the pull request"));
    }

    Ok(branch)
}
