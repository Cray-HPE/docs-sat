#!/bin/bash
set -x

yum install -y python-devel
yum install -y python36
python3 -m ensurepip --upgrade && \
    pip3 install --upgrade pip setuptools  && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/       python; fi 

#yum install -y python36-setuptools
#yum install -y python3-devel

cd ./source/cli/craycli
#pip3 install --upgrade pip
pip3 install  .
pip3 install --ignore-installed -r ../../../requirements-docs.txt



cd ./docs; make markdown
find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf
