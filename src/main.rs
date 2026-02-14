
use std::process::exit;
use std::sync::OnceLock;
use clap::{App, load_yaml};

mod status;
mod git;
mod git_helpers;
mod branch;
mod prompt;
mod configuration;
mod output;
mod list_of_branches;

use configuration::Configuration;
use crate::output::output_line_in_red;


static CONFIG: OnceLock<Configuration> = OnceLock::new();

pub fn get_config() -> &'static Configuration {
    CONFIG.get().expect("Configuration not initialized")
}

fn main() {
    let yaml = load_yaml!("cli.yml");
    let matches = App::from_yaml(yaml).get_matches();
    let branch = String::from(matches.value_of("target_branch").unwrap_or(""));

    let config = Configuration {
        is_verbose: matches.is_present("verbose"),
        prefer_local: matches.value_of("local_or_remote").unwrap_or("") == "local",
        prefer_remote: matches.value_of("local_or_remote").unwrap_or("") == "remote",
        prefer_discard: matches.value_of("discard").unwrap_or("") == "true",
        prefer_keep: matches.value_of("discard").unwrap_or("") == "false",
        list: matches.is_present("list"),
        choice: matches.is_present("choice"),
        default: matches.is_present("default"),
        target_branch: branch
    };

    CONFIG.set(config).expect("Configuration already initialized");
    
    let state = get_config();

    let add_success = git_helpers::add_all();

    if !add_success {
        output_line_in_red("Local git repository not found");
        exit(1);
    }

    if state.default {
        let target_branch = git_helpers::remote_default_branch();
        branch::set_branch(&target_branch);
    } else if state.choice {
        let target_branch = list_of_branches::choose_from_list();
        branch::set_branch(&target_branch);
    } else if state.list {
        list_of_branches::print_list();
    } else if state.target_branch != "" {
        branch::set_branch(&state.target_branch);
    } else {
        status::print_status();
    }
}
