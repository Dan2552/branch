#[macro_use] extern crate shell;

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

#[macro_use] extern crate prettytable;

fn main() {
    state::set_local(|| {
        let yaml = load_yaml!("cli.yml");
        let matches = App::from_yaml(yaml).get_matches();
        let branch = String::from(matches.value_of("target_branch").unwrap_or(""));

        Configuration {
            is_verbose: matches.is_present("verbose"),
            prefer_local: matches.value_of("local_or_remote").unwrap_or("") == "local",
            prefer_remote: matches.value_of("local_or_remote").unwrap_or("") == "remote",
            prefer_discard: matches.value_of("discard").unwrap_or("") == "true",
            prefer_keep: matches.value_of("discard").unwrap_or("") == "false",
            list: matches.is_present("list"),
            choice: matches.is_present("choice"),
            target_branch: branch
        }
    });

    let state = state::get_local::<Configuration>();

    git_helpers::add_all();

    if state.choice {
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
