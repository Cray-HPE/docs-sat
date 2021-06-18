# For a full listing of every rule,
# see https://github.com/markdownlint/markdownlint/blob/master/docs/RULES.md
#
# Rules commented out are those that should be adhered to, but require lots of
# work to clean up in existing .md.  Noting for future cleanup effort.
#
# These rules contribute to readability of both md and rendered
# content, and improve consistency across documents.
# Rule MD013 may guard against build breaks.

# Header levels increment by one level at a time
rule 'MD001'
# Header style
rule 'MD003'
# Unordered list style
rule 'MD004'
# Consistent indentation levels
rule 'MD005'
# Consistent ordered list indentation
rule 'MD007', :indent => 4
# Trailing spaces
rule 'MD009'
# Hard Tabs
rule 'MD010'
# Link syntax
rule 'MD011'
# Line length (120 characters, except in tables and code blocks)
rule 'MD013', :line_length => 120, :tables => false, :code_blocks => false
# No space after hash on header
rule 'MD018'
# Multiple spaces after hash on atx style header
rule 'MD019'
# No space inside hashes
rule 'MD020'
# Multiple spaces inside hashes on closed atx style header
rule 'MD021'
# Headers should be surrounded by blank lines. Adds to readability of md
rule 'MD022'
# Headers must start at beginning of line
rule 'MD023'
# Multiple headers with the same content, except in different parent sections
rule 'MD024', :allow_different_nesting => true
# Ordered list item prefix, expect ordered lists
rule 'MD029', :style => :ordered
# Spaces after list markers
rule 'MD030'
# Fenced code should be surrounded by blank lines.  Adds to readability of md.
rule 'MD031'
# Lists should be surrounded by blank lines. Adds to readability of md.
rule 'MD032'
# No bare URLs
rule 'MD034'
# Horizontal rule style
rule 'MD035'
# Use headers instead of **emphasis**
rule 'MD036'
# Spaces inside emphasis markers
rule 'MD037'
# Spaces inside code span elements
rule 'MD038'
# Spaces inside link text
rule 'MD039'
# Code blocks should have language specified
rule 'MD040'
