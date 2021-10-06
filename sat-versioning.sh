#!/bin/bash
set -x

CURRENT_BRANCH=$(git branch --show-current)
SAT_PRODUCT_STREAM_REPO="https://stash.us.cray.com/scm/sat/sat-product-stream.git"

# Returns 0 if branch exists in remote, 1 if branch does not exist.
function branch_exists_in_remote() {
    branch=$1
    remote=$2
    git ls-remote "$remote" | grep "refs/heads/${branch}$" >/dev/null 2>&1
    return $?
}

# Check out the $CURRENT_BRANCH of $SAT_PRODUCT_STREAM_REPO and cat the .version file.
function get_sat_version_from_product_stream_branch() {
    rm -rf sat-product-stream && \
        git clone -q --depth 1 --branch "$CURRENT_BRANCH" "$SAT_PRODUCT_STREAM_REPO" && \
        cat sat-product-stream/.version
}

# If the current sat-docs branch exists in sat-product-stream, use the value of .version in
# that branch of sat-product-stream. Otherwise, use a value of UNKNOWN.
if branch_exists_in_remote "$CURRENT_BRANCH" "$SAT_PRODUCT_STREAM_REPO"; then
    SAT_VERSION=$(get_sat_version_from_product_stream_branch)
    # If cloning failed, e.g. due to network issues, exit here.
    if [ $? -ne 0 ]; then
        >&2 echo "Failed to get .version from ${CURRENT_BRANCH} of ${SAT_PRODUCT_STREAM_REPO}"
        exit 1
    fi
else
    SAT_VERSION="UNKNOWN"
fi

# Generate a file for Jenkins to use.
echo ${SAT_VERSION} > ./sat-version.txt
