use crate::configuration::Configuration;
use crate::output::output_line_in_blue;
use std::process::Stdio;

pub enum ResetMode {
    Mixed,
    Hard
}

fn config() -> &'static Configuration {
    state::get_local::<Configuration>()
}

pub fn checkout(options: &str) -> shell::ShellResult {
    let to_execute = format!("git checkout {}", options);
    let mut command = cmd!(&to_execute);

    if config().is_verbose {
        output_line_in_blue(&to_execute);
    }

    command.command.stdout(Stdio::piped());
    command.command.stderr(Stdio::piped());
    command.run()
}

pub fn branch(options: &str) -> shell::ShellResult {
    let to_execute = format!("git branch {}", options);
    let mut command = cmd!(&to_execute);

    if config().is_verbose {
        output_line_in_blue(&to_execute);
    }

    command.command.stdout(Stdio::piped());
    command.command.stderr(Stdio::piped());
    command.run()
}

pub fn reset(mode: ResetMode, commit: &str) -> shell::ShellResult {
    let mode = match mode {
        ResetMode::Mixed => "--mixed",
        ResetMode::Hard => "--hard"
    };

    let to_execute = format!("git reset {} {}", mode, commit);
    let mut command = cmd!(&to_execute);

    if config().is_verbose {
        output_line_in_blue(&to_execute);
    }

    command.command.stdout(Stdio::piped());
    command.command.stderr(Stdio::piped());
    command.run()
}

pub fn add(options: &str) {
    let to_execute = format!("git add {}", options);
    let mut command = cmd!(&to_execute);

    if config().is_verbose {
        output_line_in_blue(&to_execute);
    }

    command.command.stdout(Stdio::piped());
    command.command.stderr(Stdio::piped());
    command.run().expect("Failed to execute git");
}

pub fn fetch() {
    let to_execute = format!("git fetch");
    let mut command = cmd!(&to_execute);

    if config().is_verbose {
        output_line_in_blue(&to_execute);
    }

    command.command.stdout(Stdio::piped());
    command.command.stderr(Stdio::piped());
    command.run().expect("Failed to execute git");
}

pub fn status(options: &str) -> String {
    let to_execute = format!("git status {}", options);
    let mut command = cmd!(&to_execute);

    if config().is_verbose {
        output_line_in_blue(&to_execute);
    }

    command.command.stderr(Stdio::piped());
    command.stdout_utf8().expect("Failed to execute git")
}

// pub fn for_each_ref(options: &str) {
//     let to_execute = format!("git for-each-ref {}", options);
//     let mut command = cmd!(&to_execute);

//     if config().is_verbose {
//         output_line_in_blue(&to_execute);
//     }
//     command.run().expect("Failed to execute git");
//     // command.command.stderr(Stdio::piped());
//     // command.stdout_utf8().expect("Failed to execute git")
// }

pub fn log(options: &str) -> String {
    let to_execute = format!("git log {}", options);
    let mut command = cmd!(&to_execute);

    if config().is_verbose {
        output_line_in_blue(&to_execute);
    }

    command.command.stderr(Stdio::piped());
    command.stdout_utf8().expect("Failed to execute git")
}

pub fn symbolic_ref(name: &str) -> String {
    let to_execute = format!("git symbolic-ref {}", name);
    let mut command = cmd!(&to_execute);

    if config().is_verbose {
        output_line_in_blue(&to_execute);
    }

    command.command.stderr(Stdio::piped());
    command.stdout_utf8().expect("Failed to execute git")
}
