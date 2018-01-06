### To set up the gh-pages branch:
# git checkout --orphan gh-pages
# (REMOVE FILES LYING AROUND NOW)
# cp directory-to-gh-pages-stuff/* .
# git add (STUFF JUST ADDED)
#

.PHONY : clean publish pdfs setup htmls display

SHELL = /bin/bash

###
# names of files you want made and published to github (in gh-pages) should be in html-these-files.mk
# which lives in the master branch and is automatically pushed over
include config.mk

###
# stuff for compilers
LATEX_MACROS = macros.tex

PANDOC_OPTS = 
PANDOC_HTML_OPTS = -c resources/pandoc.css --mathjax=https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML
PANDOC_PDF_OPTS = 
ifeq ($(wildcard $(LATEX_MACROS)),)
	# LATEX_MACROS doesn't exist
else
	PANDOC_HTML_OPTS += -H <(echo '\['; cat $(LATEX_MACROS); echo '\]')
	PANDOC_PDF_OPTS += -H $(LATEX_MACROS)
endif

MD_HTML = $(patsubst %.md,$(DISPLAYDIR)/%.html,$(MDFILES)) $(patsubst %.Rmd,$(DISPLAYDIR)/%.html,$(RMDFILES))
TEX_HTML = $(patsubst %.tex,$(DISPLAYDIR)/%.html,$(filter-out $(EXCLUDE_TEXFILES), $(TEXFILES)))
HTMLS = $(MD_HTML) $(TEX_HTML)

PDFS = $(patsubst %.tex,$(DISPLAYDIR)/%.pdf,$(filter-out $(EXCLUDE_TEXFILES), $(TEXFILES))) $(patsubst %.md,$(DISPLAYDIR)/%.pdf,$(MDFILES)) $(patsubst %.Rmd,$(DISPLAYDIR)/%.pdf,$(RMDFILES))

# hope their head isn't detached
GITBRANCH := $(shell git symbolic-ref -q --short HEAD)

htmls :
	make $(HTMLS)

pdfs :
	make $(PDFS)


# update the gh-pages branch
publish :
	@if ! git diff-index --quiet HEAD --; then echo "Commit changes first."; exit 1; fi
	git checkout gh-pages
	git merge master
	git diff --quiet || git commit -a -m 'automatic update of html'
	git checkout $(GITBRANCH)
	@echo ""
	@echo ""
	@echo "Now on branch $$(git branch)"

# set up a clean gh-pages branch
setup : 
	@if ! git diff-index --quiet HEAD --; then echo "Commit changes first."; exit 1; fi
	git checkout -b gh-pages
	git checkout $(GITBRANCH)


$(DISPLAYDIR)/%.pdf : %.md
	pandoc $(PANDOC_OPTS) $(PANDOC_PDF_OPTS) -f markdown -o $@ $<


###
# html stuff

$(DISPLAYDIR)/%.html : %.md
	-mkdir -p $(DISPLAYDIR)/resources
	-cp resources/pandoc.css $(DISPLAYDIR)/resources
	pandoc $(PANDOC_OPTS) $(PANDOC_HTML_OPTS) -f markdown -o $@ $<

$(DISPLAYDIR)/%.html : %.Rmd
	Rscript -e "templater::render_template(\"$<\", output=\"$@\", change.rootdir=TRUE, clean=TRUE)"


## 
# Graphics whatnot

# save inkscape svg files as .ink.svg and this'll do the right thing
$(DISPLAYDIR)/%.svg : %.ink.svg
	inkscape $< --export-plain-svg=$@

$(DISPLAYDIR)/%.pdf : %.ink.svg
	inkscape $< --export-pdf=$@

$(DISPLAYDIR)/%.svg : %.pdf
	inkscape $< --export-plain-svg=$@

$(DISPLAYDIR)/%.png : %.pdf
	convert -density 300 $< -flatten $@
