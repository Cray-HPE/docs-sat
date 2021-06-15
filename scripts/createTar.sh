#! /bin/bash
# Builds off base image created by Dockerfile
set -x

IMAGENAME=$1
echo "building tar: ${IMAGENAME}.tar"
OUTPUTDIR=$2
echo "Output Directory: ${OUTPUTDIR}"
mkdir -p ${OUTPUTDIR}

#cd /tmp/workdir/source/cli/craycli; python3 -m pip install --upgrade pip
#cd /tmp/workdir/source/cli/craycli; python3 -m pip install .
#cd /tmp/workdir/source/cli/craycli; python3 -m pip install --ignore-installed -r /tmp/workdir/requirements-docs.txt
#cd /tmp/workdir/source/cli/craycli/docs/; make markdown

cd /tmp/workdir/portal;yarn install;yarn build --relative-paths
cd /tmp/workdir;tar cvzf ${IMAGENAME}.tar.gz portal/public
cd /tmp/workdir;cp ${IMAGENAME}.tar.gz ${OUTPUTDIR}
ls ${OUTPUTDIR}
