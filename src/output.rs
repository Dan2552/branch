use termion::color;
use termion::style;

pub fn output_line_in_blue(line: &str) {
    println!("{}{}{}", color::Fg(color::Blue), line, color::Fg(color::Reset));
}

pub fn output_line_in_light_blue(line: &str) {
    println!("{}{}{}", color::Fg(color::LightBlue), line, color::Fg(color::Reset));
}

pub fn output_line_in_red(line: &str) {
    println!("{}{}{}", color::Fg(color::Red), line, color::Fg(color::Reset));
}

pub fn output_line_in_red_to_err(line: &str) {
    eprintln!("{}{}{}", color::Fg(color::Red), line, color::Fg(color::Reset));
}

pub fn output_line_in_green(line: &str) {
    println!("{}{}{}", color::Fg(color::Green), line, color::Fg(color::Reset));
}

pub fn output_line_in_yellow(line: &str) {
    println!("{}{}{}", color::Fg(color::Yellow), line, color::Fg(color::Reset));
}

pub fn output_line_in_magenta(line: &str) {
    println!("{}{}{}", color::Fg(color::Magenta), line, color::Fg(color::Reset));
}

pub fn format_as_bold(str: &str) -> String {
    format!("{}{}{}", style::Bold, str, style::Reset)
}
