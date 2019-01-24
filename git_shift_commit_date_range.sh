#!/usr/bin/env bash

git filter-branch -f --setup '
. "'"${0%/*}"'/shut/utils.sh"

requireDeps "git date"

source_hash="'"$1"'"
dest_hash="'"$2"'"

# We know the "between" notion when speaking of commits can be slippery
# src.: https://stackoverflow.com/a/18680080/3514658
# hashes=($(git log --format=%H $source_hash $dest_hash 2>/dev/null))

# Lets use this method based on all gommits between two dates. This is what we
# want, we don'\''t care about tree history.
# src.: https://stackoverflow.com/a/29905095/3514658
hashes=($(git log --oneline --format=%H --since="$(git log -1 $source_hash --pretty=%ad)" --until="$(git log -1 $dest_hash --pretty=%ad)" 2>/dev/null))

# The "until" limit is never taken into account. Add it.
hashes+=($dest_hash)
time_operation="'"$3"'"

# Check if date operation is valid before searching for commits which could be
# a time expensive operation.
if ! date --date="$time_operation" >/dev/null 2>&1; then
    die "The date operation \"$time_operation\" is invalid."
fi

# Check if the hashes we provided are valid and give a result.
if ((${#hashes[@]} == 0)); then
    die "The source and destination hashes are not valid or do not give any result."
fi
' \
--env-filter '
if inArray "$GIT_COMMIT" hashes[@]; then

    # GIT_AUTHOR_DATE is by default "@1434391271 -0800"
    # let''s split at space
    explode " " "${GIT_AUTHOR_DATE}"
    timezone="${retval[1]}"
    truncated_date="${retval[0]}"

    # Convert @<timestamp> to unlocalized date format
    # e.g. Mon Jun 15 09:56:04 CEST 2015
    new_git_author_date="$(LC_ALL=C date --date="${truncated_date}")"

    # Perform date manipulation
    new_git_author_date="$(LC_ALL=C date --date="${new_git_author_date} ${time_operation}")"

    # Add back the timezone
    new_git_author_date+=" ${timezone}"
    export GIT_AUTHOR_DATE="$new_git_author_date"

    # Same logic for GIT_COMMITTER_DATE since both dates can be different.
    explode " " "${GIT_COMMITTER_DATE}"
    timezone="${retval[1]}"
    truncated_date="${retval[0]}"
    new_git_committer_date="$(LC_ALL=C date --date="${truncated_date}")"
    new_git_committer_date="$(LC_ALL=C date --date="${new_git_committer_date} ${time_operation}")"
    new_git_committer_date+=" ${timezone}"
    export GIT_COMMITTER_DATE="$new_git_committer_date"
fi'
