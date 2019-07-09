use crate::git;
use std::process::Command;
use regex::Regex;

use prettytable::Table;
use prettytable::format;
use termion::{clear, cursor};
use std::io::{stdout, stdin};
use termion::event::Key;
use termion::input::TermRead;
use termion::raw::IntoRawMode;
use crate::output::output_line_in_red;

struct BranchListInfo {
    branch: String,
    modified_ago_description: String,
    author: String,
    index: i32
}

impl BranchListInfo {
    fn is_local(&self) -> bool {
        !self.is_remote()
    }

    fn is_remote(&self) -> bool {
        (&self.branch).starts_with("origin/")
    }

    fn local_branch_name(&self) -> String {
        let re = Regex::new(r"^origin/(?P<name>.*)").unwrap();
        re.replace(&self.branch, "$name").to_string()
    }

    fn clone(&self) -> BranchListInfo {
        BranchListInfo {
            branch: self.branch.to_string(),
            modified_ago_description: self.modified_ago_description.to_string(),
            author: self.author.to_string(),
            index: self.index
        }
    }
}

struct BranchListRow {
    local_branch: Option<BranchListInfo>,
    remote_branch: Option<BranchListInfo>
}

impl BranchListRow {
    fn local_branch_name(&self) -> String {
        if let Some(local) = &self.local_branch {
            return local.local_branch_name();
        } else if let Some(remote) = &self.remote_branch {
            return remote.local_branch_name();
        } else {
            String::from("")
        }
    }

    fn remote_local_state(&self) -> String {
        if self.has_local_branch() && self.has_remote_branch() {
            return String::from("Local + Remote")
        } else if self.has_local_branch() {
            return String::from("Local only")
        } else if self.has_remote_branch() {
            return String::from("Remote only")
        } else {
            return String::from("")
        }
    }

    fn has_local_branch(&self) -> bool {
        if let Some(_) = &self.local_branch {
            true
        } else {
            false
        }
    }

    fn has_remote_branch(&self) -> bool {
        if let Some(_) = &self.remote_branch {
            true
        } else {
            false
        }
    }

    fn derived_modified_ago_description(&self) -> String {
        if let Some(local) = &self.local_branch {
            if let Some(remote) = &self.remote_branch {
                let mod1 = &local.modified_ago_description;
                let mod2 = &remote.modified_ago_description;

                if mod1 == mod2 {
                    return String::from(format!("{}", mod1))
                } else {
                    return String::from(format!("{} (Local)\n{} (Remote)", mod1, mod2))
                }
            } else {
                return String::from(&local.modified_ago_description)
            }
        } else if let Some(remote) = &self.remote_branch {
            return String::from(&remote.modified_ago_description)
        } else {
            panic!("Row doesn't have remote or local branch")
        }
    }

    fn index(&self) -> i32 {
        if let Some(local) = &self.local_branch {
            if let Some(remote) = &self.remote_branch {
                if local.index < remote.index {
                    return local.index;
                } else {
                    return remote.index;
                }
            } else {
                return local.index;
            }
        } else if let Some(remote) = &self.remote_branch {
            return remote.index;
        } else {
            panic!("Row doesn't have remote or local branch")
        }
    }
}

pub fn choose_from_list() -> String {
    let table = build_table_data();

    let mut choice = 0;

    let highest_choice: i32 = (table.len() as i32) - 1;

    alternate_screen();
    draw_choice_table(&table, choice);

    let stdout = stdout().into_raw_mode().unwrap();
    let stdin = stdin();
    for c in stdin.keys() {
        let key = c.unwrap();
        match key {
            Key::Up | Key::Left => {
                choice -= 1;
                if choice < 0 {
                    choice = highest_choice
                }
            },
            Key::Down | Key::Right => {
                choice += 1;
                if choice > highest_choice {
                    choice = 0
                }
            },
            Key::Char('\n') => {
                break;
            },
            Key::Ctrl('c') => {
                stdout.suspend_raw_mode().unwrap();
                restore_screen();
                output_line_in_red("Aborted (user specified)");
                std::process::exit(1);
            }
            _ => {}
        }
        stdout.suspend_raw_mode().unwrap();
        print!("{}{}", clear::All, cursor::Goto(1, 1));
        draw_choice_table(&table, choice);
        stdout.activate_raw_mode().unwrap();
    }

    restore_screen();

    if let Some(choice) = table.get(choice as usize) {
        String::from(choice.local_branch_name())
    } else {
        panic!("Something went wrong");
    }
}

pub fn print_list() {
    let table = build_table_data();

    draw_simple_table(&table);
}


fn alternate_screen() {
    print!("{}\x1B[?1049h", cursor::Hide);
}

fn restore_screen() {
    print!("{}{}{}\x1B[?1049l", clear::All, cursor::Goto(1, 1), cursor::Show);
}

fn draw_choice_table(table: &Vec<BranchListRow>, choice: i32) {
    let mut table_printer = Table::new();
    table_printer.set_format(*format::consts::FORMAT_BOX_CHARS);

    let mut current_index = 0;

    for row in table {
        let mut cursor = "";
        if choice == current_index {
            cursor = ">";
        }
        table_printer.add_row(row![cursor, row.local_branch_name(), row.remote_local_state(), row.derived_modified_ago_description()]);
        current_index += 1;
    }

    table_printer.printstd();
}

fn draw_simple_table(table: &Vec<BranchListRow>) {
    let mut table_printer = Table::new();
    table_printer.set_format(*format::consts::FORMAT_BOX_CHARS);

    for row in table {
        table_printer.add_row(row![row.local_branch_name(), row.remote_local_state(), row.derived_modified_ago_description()]);
    }
    table_printer.printstd();
}

fn build_table_data() -> Vec<BranchListRow> {
    let mut index = -1;
    let details: Vec<BranchListInfo> = get_refs().iter().map(|reference| {
        index = index + 1;
        get_ref_details(index, &reference)
    }).collect();

    let mut table: Vec<BranchListRow> = Vec::new();

    for detail in &details {
        if detail.local_branch_name() == "HEAD" {
            continue;
        }

        if let Some(matching) = details.iter().find(|d| d.local_branch_name() == detail.local_branch_name() && d.branch != detail.branch) {
            if detail.is_remote() {
                continue;
            }

            let addition = BranchListRow {
                local_branch: Some(detail.clone()),
                remote_branch: Some(matching.clone())
            };

            table.push(addition);
        } else if detail.is_local() {
            let addition = BranchListRow {
                local_branch: Some(detail.clone()),
                remote_branch: None
            };

            table.push(addition);
        } else if detail.is_remote() {
            let addition = BranchListRow {
                local_branch: None,
                remote_branch: Some(detail.clone())
            };

            table.push(addition);
        }
    }

    table.sort_by(|row1, row2| row1.index().cmp(&row2.index()));
    table
}

fn get_refs() -> Vec<String> {
    git::fetch();

    let output = Command::new("git")
        .arg("for-each-ref")
        .arg("refs/heads")
        .arg("refs/remotes")
        .arg("--sort=-committerdate")
        .arg("--format=%(refname)")
        .arg("--count=15")
        .output()
        .expect("git failed to start");

    let stdout = String::from_utf8(output.stdout).unwrap();

    stdout.trim().split("\n").map(|s| s.to_string()).collect()
}

// A reference looks something like:
//
// refs/remotes/origin/rust
// refs/heads/rust
// refs/remotes/origin/HEAD
fn get_ref_details(index: i32, reference: &str) -> BranchListInfo {
    let output = Command::new("git")
        .arg("log")
        .arg("-n1")
        .arg(reference)
        .arg("--format=%cr|%an")
        .output()
        .expect("git failed to start");

    let stdout = String::from_utf8(output.stdout).unwrap();

    let pieces: Vec<String> = stdout.trim().split("|").map(|s| s.to_string()).collect();

    let re = Regex::new(r"^(refs/remotes/|refs/heads/)(?P<name>.*)").unwrap();
    let name = re.replace(reference, "$name").to_string();

    let branch_list_info = BranchListInfo {
        branch: name,
        modified_ago_description: pieces[0].to_string(),
        author: pieces[1].to_string(),
        index: index
    };


    branch_list_info
}
