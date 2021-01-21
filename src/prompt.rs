use crate::configuration::Configuration;

use termion::event::Key;
use termion::input::TermRead;
use termion::raw::IntoRawMode;
use std::io;
use std::io::{stdout, stdin};
use termion::{color, style, cursor, clear};
use crate::output::{output_line_in_red, output_line_in_green, output_line_in_red_to_err};

enum Question {
    RemoteOrLocal,
    StopOrContinueOrCarry
}

pub enum Answer {
    Abort,
    ContinueAndDiscard,
    ContinueAndCarry
}

fn config() -> &'static Configuration {
    state::get_local::<Configuration>()
}

pub fn continue_anyway() -> Answer {
    println!("");

    let response = {
        if config().prefer_keep {
            0
        } else if config().prefer_discard {
            1
        } else {
            let answer = ask(Question::StopOrContinueOrCarry);
            match answer {
                Ok(index) => index,
                Err(_) => {
                    output_line_in_red_to_err("You must specify `--discard=true` or `--discard=false` or run interactively");
                    std::process::exit(1);
                }
            }
        }
    };

    match response {
      0 => Answer::Abort,
      1 => Answer::ContinueAndDiscard,
      2 => Answer::ContinueAndCarry,
      _ => panic!("Unrecognised answer")
    }
}

pub fn keep_local() {
    let choice = {
        if config().prefer_local {
            "local"
        } else if config().prefer_remote {
            "remote"
        } else {
            let answer = ask(Question::RemoteOrLocal);
            match answer {
                Ok(0) => "remote",
                Ok(1) => "local",
                Ok(_) => panic!("Unrecognised answer"),
                Err(_) => {
                    output_line_in_red_to_err("You must specify `--prefer=local` or `--prefer=remote` or run interactively");
                    std::process::exit(1);
                }
            }
        }
    };

    if choice != "remote" {
        output_line_in_green("Using local branch (user specified)");
        std::process::exit(0);
    }
}


fn ask(question: Question) -> Result<i32, io::Error> {
    print!("{}", cursor::Hide);

    let mut choice = 0;
    let stdin = stdin();

    let size_of_question = match question {
        Question::RemoteOrLocal => {
            remote_or_local_dialog(choice);
            5
        },
        Question::StopOrContinueOrCarry => {
            stop_or_continue_dialog(choice);
            10
        }
    };

    let maximum_choice_index = match question {
        Question::RemoteOrLocal => 1,
        Question::StopOrContinueOrCarry => 2
    };

    let stdout = stdout().into_raw_mode()?;

    for c in stdin.keys() {
        let key = c.unwrap();
        match key {
            Key::Up | Key::Left => {
                choice -= 1;
                if choice < 0 {
                    choice = 1
                }
            },
            Key::Down | Key::Right => {
                choice += 1;
                if choice > maximum_choice_index {
                    choice = 0
                }
            },
            Key::Char('\n') => {
                break;
            },
            Key::Ctrl('c') => {
                stdout.suspend_raw_mode().unwrap();
                print!("{}{}{}", cursor::Up(size_of_question), clear::AfterCursor, cursor::Show);
                output_line_in_red("Aborted (user specified)");
                std::process::exit(1);
            }
            _ => {}
        }

        stdout.suspend_raw_mode().unwrap();
        print!("{}{}", cursor::Up(size_of_question), clear::AfterCursor);
        match question {
            Question::RemoteOrLocal => remote_or_local_dialog(choice),
            Question::StopOrContinueOrCarry => stop_or_continue_dialog(choice)
        };
        stdout.activate_raw_mode().unwrap();
    }

    print!("{}{}{}", cursor::Up(size_of_question), clear::AfterCursor, cursor::Show);
    stdout.suspend_raw_mode().unwrap();

    Ok(choice)
}

fn stop_or_continue_dialog(selected_button: i32) {
    let white_bg = "\x1B[48;5;255m";
    let blue_bg = "\x1B[48;5;25m";
    let grey_bg = "\x1B[6;30;47m";

    let white_fg = "\x1B[38;5;255m";
    let black_fg = "\x1B[38;5;234m";

    let reset = "\x1B[0m";

    let top_button_bg;
    let top_button_fg;
    let middle_button_bg;
    let middle_button_fg;
    let bottom_button_bg;
    let bottom_button_fg;

    match selected_button {
      0 => {
        top_button_bg = blue_bg;
        top_button_fg = white_fg;
        middle_button_bg = grey_bg;
        middle_button_fg = black_fg;
        bottom_button_bg = grey_bg;
        bottom_button_fg = black_fg;
      },
      1 => {
        top_button_bg = grey_bg;
        top_button_fg = black_fg;
        middle_button_bg = blue_bg;
        middle_button_fg = white_fg;
        bottom_button_bg = grey_bg;
        bottom_button_fg = black_fg;
      }
      _ => {
        top_button_bg = grey_bg;
        top_button_fg = black_fg;
        middle_button_bg = grey_bg;
        middle_button_fg = black_fg;
        bottom_button_bg = blue_bg;
        bottom_button_fg = white_fg;
      }
    }

    println!(
        "{}{:^33}{}",
        white_bg,
        "",
        reset
    );
    println!(
        "{}{}{}{:^33}{}{}{}",
        black_fg,
        white_bg,
        style::Bold,
        "There are uncommitted changes.",
        color::Fg(color::Reset),
        reset,
        style::Reset
    );
    println!(
        "{}{}{}{:^33}{}{}{}",
        black_fg,
        white_bg,
        style::Bold,
        "Continue anyway?",
        color::Fg(color::Reset),
        reset,
        style::Reset
    );
    println!(
        "{}{}{:^33}{}{}",
        black_fg,
        white_bg,
        "",
        color::Fg(color::Reset),
        reset
    );
    println!(
        "{}{:^1}{}{}{:^13}{}{:^12}{}{:^2}{}",
        white_bg,
        "",
        top_button_bg,
        top_button_fg,
        "",
        "Abort",
        "",
        white_bg,
        "",
        reset
    );
    println!(
        "{}{}{:^33}{}{}",
        black_fg,
        white_bg,
        "",
        color::Fg(color::Reset),
        reset
    );
    println!(
        "{}{:^1}{}{}{:^1}{}{:^1}{}{:^2}{}",
        white_bg,
        "",
        middle_button_bg,
        middle_button_fg,
        "",
        "Continue and discard changes",
        "",
        white_bg,
        "",
        reset
    );
    println!(
        "{}{}{:^33}{}{}",
        black_fg,
        white_bg,
        "",
        color::Fg(color::Reset),
        reset
    );
    println!(
        "{}{:^1}{}{}{:^2}{}{:^2}{}{:^2}{}",
        white_bg,
        "",
        bottom_button_bg,
        bottom_button_fg,
        "",
        "Continue and carry changes",
        "",
        white_bg,
        "",
        reset
    );
    println!(
        "{}{:^33}{}",
        white_bg,
        "",
        reset
    );
}

fn remote_or_local_dialog(selected_button: i32) {
    let white_bg = "\x1B[48;5;255m";
    let blue_bg = "\x1B[48;5;25m";
    let grey_bg = "\x1B[6;30;47m";

    let white_fg = "\x1B[38;5;255m";
    let black_fg = "\x1B[38;5;234m";

    let reset = "\x1B[0m";

    let left_button_bg;
    let left_button_fg;
    let right_button_bg;
    let right_button_fg;

    if selected_button == 0 {
        left_button_bg = blue_bg;
        left_button_fg = white_fg;
        right_button_bg = grey_bg;
        right_button_fg = black_fg;
    } else {
        left_button_bg = grey_bg;
        left_button_fg = black_fg;
        right_button_bg = blue_bg;
        right_button_fg = white_fg;
    }

    println!(
        "{}{:^32}{}",
        white_bg,
        "",
        reset
    );
    println!(
        "{}{}{}{:^32}{}{}{}",
        black_fg,
        white_bg,
        style::Bold,
        "Keep remote or local copy?",
        color::Fg(color::Reset),
        reset,
        style::Reset
    );
    println!(
        "{}{}{:^32}{}{}",
        black_fg,
        white_bg,
        "",
        color::Fg(color::Reset),
        reset
    );
    println!(
        "{}{:^4}{}{}{:^10}{}{:^4}{}{}{:^9}{}{:^5}{}",
        white_bg,
        "",
        left_button_bg,
        left_button_fg,
        "Remote",
        white_bg,
        "",
        right_button_bg,
        right_button_fg,
        "Local",
        white_bg,
        "",
        reset
    );
    println!(
        "{}{:^32}{}",
        white_bg,
        "",
        reset
    );
}
