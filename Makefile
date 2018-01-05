### To set up the gh-pages branch:
# git checkout --orphan gh-pages
# (REMOVE FILES LYING AROUND NOW)
# cp directory-to-gh-pages-stuff/* .
# git add (STUFF JUST ADDED)
#

.PHONY : clean publish pdfs setup htmls display skelml.index

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

MD_HTML = $(patsubst %.md,$(DISPLAYDIR)/%.html,$(MDFILES))
TEX_HTML = $(patsubst %.tex,$(DISPLAYDIR)/%.html,$(filter-out $(EXCLUDE_TEXFILES), $(TEXFILES)))
HTMLS = $(MD_HTML) $(TEX_HTML)

PDFS = $(patsubst %.tex,$(DISPLAYDIR)/%.pdf,$(filter-out $(EXCLUDE_TEXFILES), $(TEXFILES))) $(patsubst %.md,$(DISPLAYDIR)/%.pdf,$(MDFILES))

# hope their head isn't detached
GITBRANCH := $(shell git symbolic-ref -q --short HEAD)

# this re-makes everything.  if this is too onerous, delete 'clean' here.
# but beware, cruft will start to build up.
display : clean
	make $(HTMLS)
	# don't want to overwrite index.html if it is already there
	find display -maxdepth 1 -name "index.html" | grep -q . || make skelml.index

htmls :
	make $(HTMLS)

pdfs :
	make $(PDFS)


# update html in the gh-pages branch
#   add e.g. 'pdfs' to the next line to also make pdfs available there
publish : display
	@if ! git diff-index --quiet HEAD --; then echo "Commit changes first."; exit 1; fi
	git checkout gh-pages
	@echo "removing -- $$(grep -vxF -f <(echo .gitignore; find display/ -type f | sed -e 's_^display/__') <(git ls-files) | tr '\n' ' ')"
	# remove files no longer in display
	OLDFILES=$$(grep -vxF -f  <(echo .gitignore; find display/ -type f | sed -e 's_^display/__') <(git ls-files)); \
			 if [ ! -z "$$OLDFILES" ]; then git rm $$OLDFILES; fi
	# and add updated or new ones
	@echo "adding -- $$(find display/ -type f | sed -e 's_^display/__' | tr '\n' ' ')"
	cp -r display/* .
	UPFILES=$$(find display/ -type f | sed -e 's_^display/__'); \
		if [ ! -z "$$UPFILES" ]; then git add $$UPFILES; fi
	git commit -a -m 'automatic update of html'
	git checkout $(GITBRANCH)

# set up a clean gh-pages branch
setup : 
	@if ! git diff-index --quiet HEAD --; then echo "Commit changes first."; exit 1; fi
	-mkdir display
	git checkout --orphan gh-pages
	-rm $(shell git ls-files -c)
	git rm --cached $(shell git ls-files --cached)
	echo "display/" >> .gitignore
	-git add .gitignore
	git commit -m 'initialized gh-pages branch'
	git checkout $(GITBRANCH)

clean : 
	-rm -f $(shell git ls-files --other display/*)
	-rm -f *.aux *.log *.bbl *.blg *.out *.toc *.nav *.snm *.vrb texput.* LaTeXML.cache
	-cd display; rm -f *.aux *.log *.bbl *.blg *.out *.toc *.nav *.snm *.vrb texput.* LaTeXML.cache

# make pdfs locally
$(DISPLAYDIR)/%.pdf : %.tex %.bbl
	$(eval FIGS = $(shell grep '\\includegraphics' $*.tex  | sed -e 's/.*\\includegraphics[^{]*{\([^}]*\)\}.*/$(DISPLAYDIR)\/\1.pdf/'))
	-if [ '$(FIGS)' ]; then \
		echo 'making $(FIGS)'; \
		make $(FIGS); \
	fi
	export TEXINPUTS=$(DISPLAYDIR):${TEXINPUTS}; while ( pdflatex -output-directory $(DISPLAYDIR) $<;  grep -q "Rerun to get" $(DISPLAYDIR)/$*.log ) do true ; done

%.bbl : %.tex
	-export TEXINPUTS=$(DISPLAYDIR):${TEXINPUTS}; pdflatex -interaction nonstopmode -output-directory $(DISPLAYDIR) $<
	-bibtex $(DISPLAYDIR)/$*.aux


$(DISPLAYDIR)/%.pdf : %.md
	pandoc $(PANDOC_OPTS) $(PANDOC_PDF_OPTS) -f markdown -o $@ $<


###
# html stuff

$(DISPLAYDIR)/%.html : %.md
	mkdir -p $(DISPLAYDIR)/resources
	cp resources/pandoc.css $(DISPLAYDIR)/resources
	pandoc $(PANDOC_OPTS) $(PANDOC_HTML_OPTS) -f markdown -o $@ $<

$(DISPLAYDIR)/%.html : %.Rmd
	Rscript -e "templater::render_template(\"$<\", output=\"$@\", change.rootdir=TRUE)"


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

##
# automatic index.html creation

# this is not a rule for index.html since then if someone creates index.tex this will take precedence
skelml.index ::
	echo '<html xmlns="http://www.w3.org/1999/xhtml"> <head> <title></title> <meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8"/> <link rel="stylesheet" href="pandoc.css" type="text/css" /></head> <body>' >display/index.html
	echo '<h1>html files in this repository</h1><ul>' >> display/index.html
	for x in $$(echo display/*html | sed -e 's/\<index.html\>//' | sed -e 's_\<display/__g'); do echo "<li><a href=\"$${x}\">$${x}</a></li>" >> display/index.html; done
	echo '</ul><p>Create your own <code>index.md</code> file to make this look nicer.</p>' >> display/index.html
	echo '</body></html>' >> display/index.html



