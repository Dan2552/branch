use crate::git;
use crate::output::output_line_in_green;
use regex::Regex;

pub fn remote_default_branch() -> String {
    // Try to get the default branch from the remote HEAD
    let symbolic_ref = git::symbolic_ref("refs/remotes/origin/HEAD");
    
    if !symbolic_ref.is_empty() {
        // Output is like "refs/remotes/origin/main"
        let branch = symbolic_ref
            .replace("refs/remotes/origin/", "")
            .trim()
            .to_owned();
        
        if !branch.is_empty() {
            return branch;
        }
    }
    
    // Fallback: try common default branch names
    // Check if origin/main exists
    let main_check = git::branch("-r --list origin/main");
    if !main_check.trim().is_empty() {
        return String::from("main");
    }
    
    // Check if origin/master exists
    let master_check = git::branch("-r --list origin/master");
    if !master_check.trim().is_empty() {
        return String::from("master");
    }
    
    // Last resort fallback
    String::from("main")
}

pub fn add_all() -> bool {
    let _ = git::reset(git::ResetMode::Mixed, &"");
    let output = git::add(". -A");

    output.code == 0
}

pub fn current_branch() -> String {
    git::symbolic_ref("HEAD").replace("refs/heads/", "").trim().to_owned()
}

pub fn commits_behind_origin(branch_name: &str) -> Vec<String> {
    let mut origin = String::from(branch_name);
    if !branch_name.starts_with("origin/") {
        origin = format!("origin/{}", origin);
    }
    commits_between("HEAD", &origin)
}

pub fn commits_ahead_of_origin(branch_name: &str) -> Vec<String> {
    let mut origin = String::from(branch_name);
    if !branch_name.starts_with("origin/") {
        origin = format!("origin/{}", origin);
    }
    commits_between(&origin, "HEAD")
}

pub fn print_uncommited_files() {
    let files = uncommitted_files();

    if files.len() == 0 {
        return;
    }

    println!("\n{} uncommited file changes", files.len());
    for file in files {
        output_line_in_green(&format!("  {}", file));
    }
}

pub fn uncommitted_files() -> Vec<String> {
    let status = git::status("--porcelain");
    let lines = status.split("\n");

    let regex = Regex::new(r"(?m)^[a-zA-Z| ]{3}(?P<file>[^ ]*)$").unwrap();

    let files = lines
        .map(|line| {
            let captures;
            match regex.captures(&line) {
                Some(v) => captures = v,
                None => return "",
            }
            let file = captures.name("file").expect("Failed to parse git status").as_str();
            file
        })
        .map(|s| s.trim())
        .filter(|s| s.len() > 0)
        .map(|s| s.to_string())
        .collect();

    files
}

pub fn has_uncommitted_files() -> bool {
    uncommitted_files().len() != 0
}

fn commits_between(a: &str, b: &str) -> Vec<String> {
    let options = format!("--oneline {}..{}", a, b);
    let log = git::log(&options);
    log.trim()
        .split("\n")
        .map(|s| s.to_string())
        .filter(|s| s.trim() != "")
        .collect()
}
