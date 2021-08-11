#!/bin/bash -x
# Automated Versioning Changes are done here.
# Do Not change versions in another place
# Note: This is called from the make file, bea

CHANGE_LOG=changelog$$
REPO_PATH=$(git rev-parse --show-toplevel)
PRODUCT_VERSION=1.0.0
COPYRIGHT=$(curl https://stash.us.cray.com/projects/SHASTADOCS/repos/docs-as-code/raw/copyright.txt?at=refs%2Fheads%2Fmaster)
source ${REPO_PATH}/sat-versioning.sh
date=`date '+%a %b %d %Y'`
git_hash=`git rev-parse HEAD`
if [[ -z "${BUILD_NUMBER}" ]]; then
  RELEASE="LocalBuild"
else
  RELEASE=${BUILD_NUMBER}
fi


create_changelog() {
    # Usage:
    #    create_changelog <output file name> <release_version>
    outfile=$1
    package_version=$2


    rm -f $1
    echo '* '`date '+%a %b %d %Y'`" $USER <$USER@hpe.com> $package_version" >> $1
    echo "- Built from git hash ${git_hash}" >> $1
}

if [[ ! -z "${1}" ]]; then
   cat << EOF
---
# Copyright and Version
${COPYRIGHT}

SAT: ${SAT_VERSION}-${RELEASE}; ${date}

Doc git hash:
${git_hash}


EOF
   exit 0
fi

