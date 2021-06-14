#!/bin/bash

date=`date`
version=`./version.sh 2>/dev/null`
PVersion=`cat ../.version`

cat << EOF
---
# Copyright and Version
&copy; 2021 Hewlett Packard Enterprise Development LP


  Product version:
${PVersion}
  Doc version:
${version}
  Date generated:
${date}

EOF

