# Git Repository Status Checker

This script checks the Git status of directories under a specified root directory. It categorizes the directories based on their Git status and provides a summarized report with color-coded output.

---

## Features

- Detects directories that:
  - Are not Git repositories.
  - Are local-only Git repositories (no remote).
  - Are clean and up-to-date with the remote.
  - Have uncommitted changes.
  - Need to pull updates from the remote.
  - Need to push changes to the remote.
  - Have diverged and have conflicts with the remote.
- Supports recursive or non-recursive directory checks.
- Provides a clear and color-coded summary for easy reading.

---

## Requirements

- **Bash**: Ensure you are running this script in a Bash shell.
- **Git**: Git must be installed and accessible in the system path.

---

## Usage

```bash
./git_status_checker.sh [-s] [-d root_directory]
```

### Options

-s: Enable recursive checking. The script will traverse all subdirectories.
-d: root_directory: Specify the root directory to check. If not provided, the current directory (pwd) will be used.

## Example Output

### Command

```bash
./git_status_checker.sh -s -d /projects
```

### Output

```bash
Checking directory: /projects
Recursive check: true

Checking Git repository: /projects/repo1
  ✅ Up-to-date with remote

Checking Git repository: /projects/repo2
  ⚠️ Uncommitted changes

Checking Git repository: /projects/repo3
  ⚠️ Behind remote (pull needed)

Checking Git repository: /projects/repo4
  ⚠️ Local-only Git repository (no remote)

====== Summary ======
[Directories without Git repository]:
  - /projects/dir1
  - /projects/dir2

[Local-only Git repositories (no remote)]:
  - /projects/repo4

[Clean and up-to-date repositories]:
  - /projects/repo1

[Repositories with uncommitted changes]:
  - /projects/repo2

[Repositories that need to pull updates]:
  - /projects/repo3

[Repositories that need to push changes]:

[Repositories with conflicts]:
```

## How It Works

1. **Argument Parsing**:
    - The script uses `getopts` to handle options `-s` and `-d`.
    - If `-d` is not specified, the current directory is used as the root.

2. **Directory Traversal**:
    - Non-recursive mode checks only the first-level directories under the root.
    - Recursive mode uses `find` to traverse all subdirectories.

3. **Git Status Checking**:
    - Determines whether the directory is a Git repository.
    - Checks for remote configuration and compares the local branch with the remote branch.

4. **Color-Coded Categorization**:
    - Uses ANSI color codes to make the output visually distinguishable.

5. **Summary Output**:
    - Aggregates results into categories and prints them in a structured format.

## License

This script is provided under the MIT License. Use it freely for personal or professional purposes.