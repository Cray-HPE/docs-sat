#!/bin/bash
set -x
# REPO_PATH=$(git rev-parse --show-toplevel)
# git submodule update --init ${REPO_PATH}/sat-product-stream > /dev/null
# SAT_VERSION=$(cd ${REPO_PATH}/sat-product-stream/ && git checkout -q release/sat-2.1 && cat .version)
# # Generate a file for jenkins to use.
# cat ${REPO_PATH}/sat-product-stream/.version > ${REPO_PATH}/sat-version.txt

REPO_PATH=$(git rev-parse --show-toplevel)
SAT_PRODUCT_STREAM_REPO="https://stash.us.cray.com/scm/sat/sat-product-stream.git"
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" == *"master"* ]]; then
	SAT_PRODUCT_STREAM_BRANCH="master"
	SAT_VERSION=$(cd ${REPO_PATH} && rm -rf sat-product-stream && git clone -q --depth 1 --branch ${SAT_PRODUCT_STREAM_BRANCH} ${SAT_PRODUCT_STREAM_REPO} sat-product-stream && cat sat-product-stream/.version)
elif [[ "$CURRENT_BRANCH" == *"release/"* ]]; then
	# We need the latest release branch
	cd ${REPO_PATH}
	rm -rf sat-product-stream
	git clone -q ${SAT_PRODUCT_STREAM_REPO} sat-product-stream
	cd ${REPO_PATH}/sat-product-stream/
	git branch --all | grep "remotes/origin/release/sat" | sort -nr > ../remotes.txt
	SAT_PRODUCT_STREAM_BRANCH=$(head -n 1 ../remotes.txt | cut -d/ -f3-4)
	SAT_VERSION=$(git checkout -q ${SAT_PRODUCT_STREAM_BRANCH} && cat .version)
	rm ../remotes.txt
else
	SAT_VERSION="1.0.0"
fi

# Per Eli, depending on public repo when done in Jenkins:
# SAT_PRODUCT_STREAM_REPO="https://stash.us.cray.com/scm/sat/sat-product-stream.git"
# SAT_PRODUCT_STREAM_BRANCH="release/sat-2.1"
# REPO_PATH=$(git rev-parse --show-toplevel)
# SAT_VERSION=$(rm -rf sat-product-stream && git clone -q --depth 1 --branch $SAT_PRODUCT_STREAM_BRANCH $SAT_PRODUCT_STREAM_REPO sat-product-stream && cat sat-product-stream/.version)
# rm -rf sat-product-stream

# Generate a file for jenkins to use.
echo ${SAT_VERSION} > ${REPO_PATH}/sat-version.txt