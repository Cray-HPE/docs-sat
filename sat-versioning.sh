#!/bin/bash
set -x
# REPO_PATH=$(git rev-parse --show-toplevel)
# git submodule update --init ${REPO_PATH}/sat-product-stream > /dev/null
# SAT_VERSION=$(cd ${REPO_PATH}/sat-product-stream/ && git checkout -q release/sat-2.1 && cat .version)
# # Generate a file for jenkins to use.
# cat ${REPO_PATH}/sat-product-stream/.version > ${REPO_PATH}/sat-version.txt

# Per Eli, depending on public repo when done in Jenkins:
SAT_PRODUCT_STREAM_REPO="https://stash.us.cray.com/scm/sat/sat-product-stream.git"
SAT_PRODUCT_STREAM_BRANCH="release/sat-2.1"
REPO_PATH=$(git rev-parse --show-toplevel)
SAT_VERSION=$(rm -rf sat-product-stream && git clone -q --depth 1 --branch $SAT_PRODUCT_STREAM_BRANCH $SAT_PRODUCT_STREAM_REPO sat-product-stream && cat sat-product-stream/.version)
rm -rf sat-product-stream
# Generate a file for jenkins to use.
echo $SAT_VERSION > ${REPO_PATH}/sat-version.txt