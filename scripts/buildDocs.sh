#!/bin/bash

# (C) Copyright 2021 Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

dir_path="../portal/developer-portal"
output_path="../portal/developer-portal/docs"
rm -rf $output_path

mkdir -p ${output_path}/pdf
mkdir -p ${output_path}/html/images

cur_pwd=$(pwd);
file_list=$(cd ../portal/developer-portal/;   ls *.mds | sed 's/.mds//g' )
cd $cur_pwd;

for file in $(echo $file_list);do

    echo Compiling $file
    ./compileMDS.py $dir_path/${file}.mds

    # Create HTML
    pandoc ${dir_path}/${file}.md -o $output_path/html/${file}.html "-fmarkdown-implicit_figures -o" --from=markdown -s --toc --highlight-style=espresso 2>&1 | grep -v '[WARNING]'

    # Create PDF
    pandoc ${dir_path}/${file}.md -o $output_path/pdf/${file}.pdf "-fmarkdown-implicit_figures -o" --from=markdown -s --toc --highlight-style=espresso --title=true --toc -V geometry:margin=.75in 2>&1 | grep -v '[WARNING]'

    cp ${dir_path}/images/* $output_path/html/images

    # FIX HTML file.

    cat $output_path/html/${file}.html | awk '{ if (NR!=18) { print $0 } }' > /tmp/result1
    cat /tmp/result1 | awk '{ if (NR==88) { print $0 "\n" "color: #fff;" "\n" "background: #000;" } else { print $0 }}' > $output_path/html/${file}.html
done
