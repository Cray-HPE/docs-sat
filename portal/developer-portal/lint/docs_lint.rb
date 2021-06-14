# For a full listing of every rule,
# see https://github.com/markdownlint/markdownlint/blob/master/docs/RULES.md
#
# Rules commented out are those that should be adhered to, but require lots of
# work to clean up in existing .md.  Noting for future cleanup effort.
#
# These rules contribute to readabity of both md and rendered
# content, and improve consistency across documents.
# Rule MD013 may guard against build breaks.

# Header levels increment by one level at a time
rule 'MD001'
# Header style
rule 'MD003'
# Consistent indentation levels
rule 'MD005'
# Consistent ordered list indentation
rule 'MD007'

#Trailing spaces - valid, but will cause much work to clean up 
#rule 'MD009'

#Hard Tabs - valid, but will cause much work to clean up 
#rule 'MD010'

# Link syntax
rule 'MD011'
# Line length
rule 'MD013', :line_length => 700
# No space after hash on header
rule 'MD018'
# Mult space after hash on header
rule 'MD019'
# No space inside hashes
rule 'MD020'
# Multiple spaces inside hashes on closed atx style header
rule 'MD021'

#Headers should be surrounded by blank lines. Adds to readablity of md.
#rule 'MD022'

# Headers must start at beginning of line
rule 'MD023'

# Spaces after list markers
#rule 'MD030'

#Fenced code should be surrounded by blank lines.  Adds to readability of md.
#rule 'MD031'
#Lists should be surrounded by blank lines. Adds to readability of md.
#rule 'MD032'

#Not practical because of urls in curl commands inside tables
#rule 'MD034'

rule 'MD035'
#emphasis in headers
#rule 'MD036'
rule 'MD038'
rule 'MD039'
rule 'MD040'
