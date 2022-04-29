#!/bin/bash -x
# Automated Versioning Changes are done here.
# Do Not change versions in any other place

CHANGE_LOG=changelog$$
REPO_PATH=$(git rev-parse --show-toplevel)
COPY_RIGHT=$(cat "$(find "${REPO_PATH}" -name copyright.txt)")
PRODUCT_VERSION=$(cat ${REPO_PATH}/sat-version.txt)
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


if [[ "-d" = "${1}" ]]; then
   cat << EOF
\pagebreak

# Copyright and Version
${COPY_RIGHT}

SAT: ${PRODUCT_VERSION}-${RELEASE}; ${date}

Doc git hash:
${git_hash}

EOF
    # Modify Latex Headers
    cat ./pdf-templates/fancy.tex.template | sed \
        -e "s/VERSIONFOOTER/Version: ${PRODUCT_VERSION}-${RELEASE}/g" > ./pdf-templates/fancy.tex
   exit 0
fi

if [[ ! -z "${BUILD_NUMBER}" ]]; then
    if [[ -z "${PRODUCT_VERSION}" ]]; then
        echo "Version: ${PRODUCT_VERSION} is Empty"
        exit 1
    fi
    create_changelog $CHANGE_LOG ${PRODUCT_VERSION}


    # Modify .version files
    sed -i s/999.999.999/${PRODUCT_VERSION}-${BUILD_NUMBER}/g .version
    sed -i s/999.999.999/${PRODUCT_VERSION}/g .version_rpm

    # Modify rpm spec
    cat portal/developer-portal/product-docs.spec.template | sed \
        -e "s/999.999.999/$PRODUCT_VERSION/g" \
        -e "/__CHANGELOG_SECTION__/r $CHANGE_LOG" \
        -e "/__CHANGELOG_SECTION__/d" > portal/developer-portal/product-docs.spec
fi
rm -f ${CHANGE_LOG}
