#!/usr/bin/python
"""
This script is used to take a .mds (markdown-slingshot) file and convert the
file into a .md file.

Instead of creating one large gigantic markdown file, we can now modularize by
loading specific snippets of markdown.  This is allows for better organization,
reuse, and better maintainability as we will only need to update 1 location.

The .mds file can still have regular markdown syntax as well.  The only
special directive that this file cares about is: '_include <location>.md'

The output filename will written to <filename>.md when the script completes

"""
import re
import sys
from os import path

MD_LINK_REGEX = re.compile('\[(.*)\]\(.+.md#(.*)\)')
MD_FILE_EXTENSION = ".md"


def convert_md_links(line):
    """Convert links between markdown files into anchor links.

    E.g. convert this:
      [A link to something](filename.md#location-within-file)
    To this:
      [A link to something](#location-within-file)
    """
    match = MD_LINK_REGEX.search(line)
    if match:
        original_link = match.group(0)
        link_text = match.group(1)
        link_location = match.group(2)
        anchor_link = '[{}](#{})'.format(link_text, link_location)
        print('Converting .md link {} to anchor link {}'.format(original_link, anchor_link))
        return line.replace(original_link, anchor_link)
    return line


if len(sys.argv) != 2:
    print("<filename> argument is required")
    exit()

filename=sys.argv[1]

if filename[-4:] != ".mds":
    print("File extension must be .mds")
    exit()

if path.isfile(filename) is False:
    print(filename + ": File does not Exist")
    exit()


# This will keep reading/writing files to the correct location
# This is also important for the relative-path  _include directives.
base_path=path.abspath(filename)
base_dir=path.dirname(base_path)
base_filename=path.basename(filename)

# Writing to '.md'
fd_output = open( base_path[:-4] + MD_FILE_EXTENSION, 'w')

# Opening the '.mds'
fd_mds = open( filename, 'r')


for line in fd_mds.readlines():
    if "_include" in line:
        include_location = line.split()[1]
        # Open Include file
        fd_include = open(base_dir + "/"+ include_location, 'r')
        fd_output.writelines([convert_md_links(l) for l in fd_include.readlines()])
        fd_include.close()
    else:
        fd_output.write(line)

fd_mds.close()
fd_output.close()
