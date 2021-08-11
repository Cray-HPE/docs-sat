#!/bin/bash
set -x
REPO_PATH=$(git rev-parse --show-toplevel)
git submodule update --init ${REPO_PATH}/sat-product-stream > /dev/null
SAT_VERSION=$(cd ${REPO_PATH}/sat-product-stream/ && git checkout -q release/sat-2.1 && cat .version)
# Generate a file for jenkins to use.
cat ${REPO_PATH}/sat-product-stream/.version > ${REPO_PATH}/sat-version.txt