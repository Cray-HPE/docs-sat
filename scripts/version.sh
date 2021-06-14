#!/bin/bash

version_regex='([0-9]+)\.([0-9]+)\.?([0-9]*)-([0-9]+)-g([0-9|a-z]+)'
git_string=$(git describe --tags --long)
version_num_plus_commits="unknown"

if [[ $git_string =~ $version_regex ]]; then
    major_version="${BASH_REMATCH[1]}"
    minor_version="${BASH_REMATCH[2]}"
    patch_version="${BASH_REMATCH[3]}"
    commits_ahead="${BASH_REMATCH[4]}"
else
    echo "Error: git describe did not output a valid version string." >&2
    echo "Version: ${version_num_plus_commits}"
    exit
fi

version_num="${major_version}.${minor_version}.${patch_version}"
version_num_plus_commits="${version_num}+${commits_ahead}"
echo "${version_num_plus_commits}"
