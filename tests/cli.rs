use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, Output};
use std::sync::atomic::{AtomicU64, Ordering};
use std::time::{SystemTime, UNIX_EPOCH};

static NEXT_TEMP_DIR: AtomicU64 = AtomicU64::new(0);

struct TempDir {
    path: PathBuf,
}

impl TempDir {
    fn new(label: &str) -> Self {
        let unique = NEXT_TEMP_DIR.fetch_add(1, Ordering::Relaxed);
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("system clock is before the Unix epoch")
            .as_nanos();
        let path = std::env::temp_dir().join(format!(
            "branch-integration-{label}-{}-{nanos}-{unique}",
            std::process::id()
        ));
        fs::create_dir(&path).expect("failed to create temporary test directory");
        Self { path }
    }

    fn path(&self) -> &Path {
        &self.path
    }
}

impl Drop for TempDir {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.path);
    }
}

struct GitFixture {
    _root: TempDir,
    checkout: PathBuf,
}

impl GitFixture {
    fn new() -> Self {
        let root = TempDir::new("repository");
        let remote = root.path().join("remote.git");
        let seed = root.path().join("seed");
        let checkout = root.path().join("checkout");

        git(root.path(), &["init", "--bare", path_str(&remote)]);
        fs::create_dir(&seed).expect("failed to create seed repository");
        git(&seed, &["init"]);
        git(&seed, &["checkout", "-b", "main"]);
        git(&seed, &["config", "user.name", "Integration Test"]);
        git(
            &seed,
            &["config", "user.email", "integration-test@example.com"],
        );

        fs::write(seed.join("README.md"), "main branch\n")
            .expect("failed to write main branch file");
        git(&seed, &["add", "."]);
        git(&seed, &["commit", "-m", "Create main branch"]);

        git(&seed, &["checkout", "-b", "feature"]);
        fs::write(seed.join("feature.txt"), "feature branch\n")
            .expect("failed to write feature branch file");
        git(&seed, &["add", "."]);
        git(&seed, &["commit", "-m", "Create feature branch"]);
        git(&seed, &["checkout", "main"]);

        git(&seed, &["remote", "add", "origin", path_str(&remote)]);
        git(&seed, &["push", "origin", "main", "feature"]);
        git(&remote, &["symbolic-ref", "HEAD", "refs/heads/main"]);
        git(
            root.path(),
            &["clone", path_str(&remote), path_str(&checkout)],
        );
        git(&checkout, &["config", "user.name", "Integration Test"]);
        git(
            &checkout,
            &["config", "user.email", "integration-test@example.com"],
        );

        Self {
            _root: root,
            checkout,
        }
    }

    fn run_branch(&self, args: &[&str]) -> Output {
        Command::new(env!("CARGO_BIN_EXE_branch"))
            .args(args)
            .current_dir(&self.checkout)
            .output()
            .expect("failed to run branch")
    }

    fn current_branch(&self) -> String {
        let output = git_output(&self.checkout, &["branch", "--show-current"]);
        String::from_utf8(output.stdout)
            .expect("branch name was not UTF-8")
            .trim()
            .to_owned()
    }
}

#[test]
fn reports_an_error_outside_a_git_repository() {
    let directory = TempDir::new("not-a-repository");
    let output = Command::new(env!("CARGO_BIN_EXE_branch"))
        .current_dir(directory.path())
        .output()
        .expect("failed to run branch");

    assert_eq!(output.status.code(), Some(1));
    assert_stdout_contains(&output, "Local git repository not found");
}

#[test]
fn status_reports_the_current_branch_and_uncommitted_files() {
    let fixture = GitFixture::new();
    fs::write(fixture.checkout.join("notes.txt"), "not committed\n")
        .expect("failed to write an uncommitted file");

    let output = fixture.run_branch(&[]);

    assert!(
        output.status.success(),
        "branch failed:\n{}",
        output_text(&output)
    );
    assert_stdout_contains(&output, "On branch");
    assert_stdout_contains(&output, "main");
    assert_stdout_contains(&output, "1 uncommited file changes");
    assert_stdout_contains(&output, "notes.txt");
}

#[test]
fn switches_to_a_branch_that_only_exists_on_the_remote() {
    let fixture = GitFixture::new();

    let output = fixture.run_branch(&["feature"]);

    assert!(
        output.status.success(),
        "branch failed:\n{}",
        output_text(&output)
    );
    assert_stdout_contains(&output, "Switching to branch");
    assert_stdout_contains(&output, "Using remote branch");
    assert_eq!(fixture.current_branch(), "feature");
    assert!(fixture.checkout.join("feature.txt").exists());
}

#[test]
fn default_switches_to_the_remote_default_branch() {
    let fixture = GitFixture::new();
    git(&fixture.checkout, &["checkout", "feature"]);

    let output = fixture.run_branch(&["--default"]);

    assert!(
        output.status.success(),
        "branch failed:\n{}",
        output_text(&output)
    );
    assert_eq!(fixture.current_branch(), "main");
    assert_stdout_contains(&output, "Using remote branch");
}

#[test]
fn list_combines_local_and_remote_branch_information() {
    let fixture = GitFixture::new();

    let output = fixture.run_branch(&["--list"]);

    assert!(
        output.status.success(),
        "branch failed:\n{}",
        output_text(&output)
    );
    assert_stdout_contains(&output, "main");
    assert_stdout_contains(&output, "Local + Remote");
    assert_stdout_contains(&output, "feature");
    assert_stdout_contains(&output, "Remote only");
}

fn git(directory: &Path, args: &[&str]) {
    let output = git_output(directory, args);
    assert!(
        output.status.success(),
        "git {} failed in {}:\n{}",
        args.join(" "),
        directory.display(),
        output_text(&output)
    );
}

fn git_output(directory: &Path, args: &[&str]) -> Output {
    Command::new("git")
        .args(args)
        .current_dir(directory)
        .output()
        .expect("failed to run git")
}

fn path_str(path: &Path) -> &str {
    path.to_str().expect("temporary path was not UTF-8")
}

fn assert_stdout_contains(output: &Output, expected: &str) {
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(
        stdout.contains(expected),
        "stdout did not contain {expected:?}:\n{}",
        output_text(output)
    );
}

fn output_text(output: &Output) -> String {
    format!(
        "stdout:\n{}\nstderr:\n{}",
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    )
}
