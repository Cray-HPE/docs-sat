#!/bin/bash -x
# Automated Versioning Changes are done here ,Do Not change versions in anyother place 

if [[ ! -z "${BUILD_NUMBER}" ]]; then
    PRODUCT_VERSION=$(curl https://stash.us.cray.com/projects/SHASTADOCS/repos/docs-as-code/raw/.version?at=refs%2Fheads%2Fmaster)
    if [[ -z "${PRODUCT_VERSION}" ]]; then
        echo "Version: ${PRODUCT_VERSION} is Empty"
        exit 1
    fi 
    sed -i '' s/999.999.999/${PRODUCT_VERSION}-${BUILD_NUMBER}/g .version
    sed -i '' s/999.999.999/${PRODUCT_VERSION}/g .version_rpm
    sed -i '' s/999.999.999/${PRODUCT_VERSION}/g product-docs.spec
fi
