use crate::configuration::Configuration;
use crate::output::output_line_in_blue;
use std::process::{Command, Stdio};

pub enum ResetMode {
    Mixed,
    Hard,
    Soft
}

pub struct CommandResult {
    pub success: bool,
    pub code: i32,
}

fn config() -> &'static Configuration {
    crate::get_config()
}

fn run_git_command(args: &[&str]) -> CommandResult {
    let cmd_str = format!("git {}", args.join(" "));
    
    if config().is_verbose {
        output_line_in_blue(&cmd_str);
    }

    let output = Command::new("git")
        .args(args)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .output()
        .expect("Failed to execute git");

    CommandResult {
        success: output.status.success(),
        code: output.status.code().unwrap_or(1),
    }
}

fn run_git_command_with_output(args: &[&str]) -> String {
    let cmd_str = format!("git {}", args.join(" "));
    
    if config().is_verbose {
        output_line_in_blue(&cmd_str);
    }

    let output = Command::new("git")
        .args(args)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .output();

    match output {
        Ok(out) => String::from_utf8_lossy(&out.stdout).to_string(),
        Err(_) => String::new()
    }
}

pub fn checkout(options: &str) -> CommandResult {
    let args: Vec<&str> = std::iter::once("checkout")
        .chain(options.split_whitespace())
        .collect();
    run_git_command(&args)
}

pub fn branch(options: &str) -> String {
    let args: Vec<&str> = std::iter::once("branch")
        .chain(options.split_whitespace())
        .collect();
    run_git_command_with_output(&args)
}

pub fn reset(mode: ResetMode, commit: &str) -> CommandResult {
    let mode_str = match mode {
        ResetMode::Mixed => "--mixed",
        ResetMode::Hard => "--hard",
        ResetMode::Soft => "--soft"
    };

    let mut args = vec!["reset", mode_str];
    if !commit.is_empty() {
        args.push(commit);
    }
    run_git_command(&args)
}

pub fn commit(message: &str) {
    let result = run_git_command(&["commit", "-m", message]);
    if !result.success {
        panic!("Failed to execute git");
    }
}

pub fn cherry_pick(commit: &str) {
    let result = run_git_command(&["cherry-pick", commit]);
    if !result.success {
        panic!("Failed to execute git");
    }
}

pub fn add(options: &str) -> CommandResult {
    let args: Vec<&str> = std::iter::once("add")
        .chain(options.split_whitespace())
        .collect();
    run_git_command(&args)
}

pub fn fetch() {
    let result = run_git_command(&["fetch"]);
    if !result.success {
        panic!("Failed to execute git");
    }
}

pub fn status(options: &str) -> String {
    let args: Vec<&str> = std::iter::once("status")
        .chain(options.split_whitespace())
        .collect();
    run_git_command_with_output(&args)
}

pub fn log(options: &str) -> String {
    let args: Vec<&str> = std::iter::once("log")
        .chain(options.split_whitespace())
        .collect();
    run_git_command_with_output(&args)
}

pub fn symbolic_ref(name: &str) -> String {
    run_git_command_with_output(&["symbolic-ref", name])
}
