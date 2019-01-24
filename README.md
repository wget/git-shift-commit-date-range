# git_shift_commit_date_range.sh

A simple Bash script used to change the author/committer date of a range of commits in a Git branch.

## Usage

Execute the script from within the branch you want to change the git commits range from:

```
git_shift_commit_date_range.sh 00206f76c4a78645f8a214dd9993e1374ca51b36 34f80bb753c74afb4e93ea04d65e6916b823b2ea "- 10 days"
```

* Argument 1: the source commit hash (included) - when doing a `git log`, the hash below
* Argument 2: the source destination hash (included) - when doing a `git log`, the hash above
* A date operation following [the GNU/BSD date syntax described here](https://www.gnu.org/software/coreutils/manual/html_node/Date-input-formats.html#Date-input-formats). Fixed date statements and relative date statements are supported.


## License

This software is licensed under the terms of the GNU General Public License v3.0 or later.
