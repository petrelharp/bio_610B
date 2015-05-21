# Here goes the list of source files to make html and xhtml files
#  (and any other commands you want run in the makefile in the gh-pages branch before making the (x)html)
#
# This will automatically include anything ending in .tex or .md.  
# If you want to have only files you specify, comment out the following and make an explicit list 
# (like the commented example at the end).

# temporary directory to put pdfs, htmls, etc in:
DISPLAYDIR = display

## Exclude these:
EXCLUDE_TEXFILES = 
EXCLUDE_MDFILES = 

## Include everything but the above
TEXFILES = $(wildcard *.tex)
MDFILES = $(wildcard *.md)

## Or only specific files
# MDFILES = outline.md
# TEXFILES = introduction.tex summary-stats.tex
