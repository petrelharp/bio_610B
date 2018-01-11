SHELL := /bin/bash
# use bash for <( ) syntax

.PHONY : publish upload all slides

all : README.html syllabus.html schedule.html slides

slides :
	$(MAKE) -C slides

# change this to the location of your local MathJax.js library
LOCAL_MATHJAX = /dont/use/local/mathjax/for/webpages
ifeq ($(wildcard $(LOCAL_MATHJAX)),)
	MATHJAX = https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js
else
	MATHJAX = $(LOCAL_MATHJAX)
endif

# may want to add "--self-contained" to the following
PANDOC_OPTS = --mathjax=$(MATHJAX)?config=TeX-AMS-MML_HTMLorMML --standalone --self-contained
# optionally add in a latex file with macros
LATEX_MACROS = macros.tex
ifeq ($(wildcard $(LATEX_MACROS)),)
	# macros file isn't there
else
	PANDOC_OPTS += -H .pandoc.$(LATEX_MACROS)
endif

.pandoc.$(LATEX_MACROS) : $(LATEX_MACROS)
	(echo '\['; cat $(LATEX_MACROS); echo '\]') > $@

# knitr by default tries to interpret ANY code chunk; I only want it to do the ones beginning with ```r.
KNITR_PATTERNS = list( chunk.begin="^```+\\s*\\{[.]?(r[a-zA-Z]*.*)\\}\\s*$$", chunk.end="^```+\\s*$$", inline.code="`r +([^`]+)\\s*`")
# or, uncomment for OSX:
# KNITR_PATTERNS = list( chunk.begin="^```+\\\\s*\\\\{[.]?(r[a-zA-Z]*.*)\\\\}\\\\s*$$", chunk.end="^```+\\\\s*$$", inline.code="`r +([^`]+)\\\\s*`")

%.html : %.Rmd
	# cd $$(dirname $<); Rscript -e 'knitr::knit2html(basename("$<"),output=basename("$@"))'
	# cd $$(dirname $<); Rscript -e 'rmarkdown::render(basename("$<"),output_file=basename("$@"))'
	# Rscript -e 'templater::render_template("$<", output="$@", change.rootdir=TRUE)'
	Rscript -e 'knitr::knit_patterns[["set"]]($(KNITR_PATTERNS)); templater::render_template("$<", output="$@", change.rootdir=TRUE, clean=FALSE)'

%.html : %.md .pandoc.$(LATEX_MACROS)
	pandoc -o $@ $(PANDOC_OPTS) $<

%.md : %.Rmd
	# cd $$(dirname $<); Rscript -e 'knitr::knit_patterns[["set"]]($(KNITR_PATTERNS)); knitr::knit(basename("$<"),output=basename("$@"))'
	Rscript -e 'knitr::knit_patterns[["set"]]($(KNITR_PATTERNS)); templater::render_template("$<", output="$@", change.rootdir=TRUE)'

%.pdf : %.md
	pandoc -o $@ -t latex $<


## VARIOUS SLIDE METHODS
REVEALJS_OPTS = -t revealjs -V theme=simple -V slideNumber=true -V transition=none -H resources/adjust-revealjs.style --slide-level 2
SLIDES_OPTS = $(REVEALJS_OPTS)

%.slides.html : %.md .pandoc.$(LATEX_MACROS)
	pandoc -o $@ $(SLIDES_OPTS) $(PANDOC_OPTS) $<

%.revealjs.html : %.md .pandoc.$(LATEX_MACROS)
	pandoc -o $@ $(REVEALJS_OPTS) $(PANDOC_OPTS) $<

# hope their head isn't detached
GITBRANCH := $(shell git symbolic-ref -q --short HEAD)

# upload to github
upload :
	git push origin --all

# update the gh-pages branch
publish :
	@if ! git diff-index --quiet HEAD --; then echo "Commit changes first."; exit 1; fi
	git checkout gh-pages
	git merge master
	git diff --quiet || git commit -a -m 'automatic update of html'
	git checkout $(GITBRANCH)
	@echo ""
	@echo ""
	@echo "Now on branch $$(git rev-parse --abbrev-ref HEAD)"

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

## things without mathjax

syllabus.html : syllabus.md
	pandoc -o $@ --standalone --self-contained $<


