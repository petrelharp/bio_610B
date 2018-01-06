# Here goes the list of source files to make html and xhtml files
#  (and any other commands you want run in the makefile in the gh-pages branch before making the (x)html)
#
# This will automatically include anything ending in .tex or .md.  
# If you want to have only files you specify, comment out the following and make an explicit list 
# (like the commented example at the end).

# temporary directory to put pdfs, htmls, etc in:
DISPLAYDIR = .

## Exclude these:
EXCLUDE_TEXFILES = macros.tex
EXCLUDE_MDFILES = publish_notes.md test_document.Rmd

## Include everything but the above
TEXFILES = $(wildcard *.tex)
MDFILES = $(wildcard *.md)
RMDFILES = $(wildcard *.Rmd)

## Or only specific files
# MDFILES = outline.md
# TEXFILES = introduction.tex summary-stats.tex
