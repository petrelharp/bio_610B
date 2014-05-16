### To set up the gh-pages branch:
# git checkout --orphan gh-pages
# (REMOVE FILES LYING AROUND NOW)
# cp directory-to-gh-pages-stuff/* .
# git add (STUFF JUST ADDED)
#

.PHONY : clean publish pdfs setup xhtmls

###
# names of files you want made and published to github (in gh-pages) should be in html-these-files.mk
# which lives in the master branch and is automatically pushed over
include config.mk

###
# stuff for compilers
LATEXMLFLAGS = --preamble=resources/header.tex --postamble=resources/footer.tex 
LATEXMLPOSTFLAGS = --javascript=resources/LaTeXML-maybeMathjax.js --css=resources/plr-style.css --stylesheet=resources/xsl/LaTeXML-all-xhtml.xsl --javascript=resources/adjust-svg.js

MD_HTML = $(patsubst %.md,%.html,$(MDFILES))
TEX_HTML = $(patsubst %.tex,%.html,$(TEXFILES))
TEX_XHTML = $(patsubst %.tex,%.xhtml,$(TEXFILES))
WEBPAGES = $(MD_HTML) $(TEX_HTML) $(TEX_XHTML)

PDFS = $(patsubst %.tex,$(DISPLAYDIR)/%.pdf,$(TEXFILES))
XHTMLS = $(patsubst %.tex,$(DISPLAYDIR)/%.xhtml,$(TEXFILES))

# hope their head isn't detached
GITBRANCH = $(shell git symbolic-ref -q --short HEAD)

xhtmls :
	make $(XHTMLS)

pdfs :
	make $(PDFS)

branch = git symbolic-ref -q HEAD

echobranch : 
	git checkout gh-pages
	echo $(shell $(branch))

# update html in the gh-pages branch
#   add e.g. 'pdfs' to the next line to also make pdfs available there
publish : xhtmls
	git checkout gh-pages
	$(eval DISPLAYFILES = $$(patsubst display/%,%,$$(shell find display/ -type f)))
	$(eval OLDFILES = $$(filter-out .gitignore,$$(shell git ls-files)))
	$(eval STALEFILES = $$(filter-out $$(DISPLAYFILES),$$(OLDFILES)))
	$(eval BRANCH = $$(shell git symbolic-ref -q HEAD))
	@echo 'on branch $(BRANCH)'
	@echo 'new files -- $(DISPLAYFILES)'
	@echo 'old files -- $(OLDFILES)'
	@echo 'removing -- $(STALEFILES)'
	# remove files no longer in display
	git rm $(STALEFILES)
	@echo 'adding  $(DISPLAYFILES)'
	cp -r display/* .
	git add $(DISPLAYFILES)
	git commit -a -m 'automatic update of html'
	git checkout $(GITBRANCH)

# set up a clean gh-pages branch
setup : 
	@if ! git diff-index --quiet HEAD --; then echo "Commit changes first."; exit 1; fi
	git checkout --orphan gh-pages
	-rm $(shell git ls-files -c)
	git rm --cached $(shell git ls-files --cached)
	echo "display/" > .gitignore
	git add .gitignore
	git commit -m 'initialized gh-pages branch'
	git checkout $(GITBRANCH)

clean : 
	-rm -f $(shell git ls-files --other display/*)
	-rm -f *.aux *.log *.bbl *.blg *.out *.toc *.nav *.snm *.vrb texput.* LaTeXML.cache


# make pdfs locally
$(DISPLAYDIR)/%.pdf : %.tex %.bbl
	rm -f texput.*
	while ( ( cat header.tex; echo '\input{$<}'; cat tailer.tex ) | pdflatex;  grep -q "Rerun to get cross" $*.log ) do true ; done
	mv texput.pdf $@

%.bbl : %.tex
	rm -f texput.*
	( cat header.tex; echo '\input{$<}'; cat tailer.tex ) | pdflatex
	-bibtex texput
	mv textput.bbl $@


## TO-DO:
# automatically figure out which things to tex up
# remove intermediate .xml files

###
# latexml stuff



$(DISPLAYDIR)/%.html : %.md
	pandoc -c resources/github-markdown.css -f markdown_github -o $@ $<

$(DISPLAYDIR)/%.xml : %.bib
	latexmlc --destination=$@ --bibtex $<

$(DISPLAYDIR)/%.xml : %.tex
	latexml $(LATEXMLFLAGS) --destination=$@ $<

$(DISPLAYDIR)/%.xhtml : $(DISPLAYDIR)/%.xml
	$(eval BIBS = $(shell grep '\\bibliography' $*.tex | sed -e 's/.*\\bibliography[^{]*{\([^}]*\)\}.*/$(DISPLAYDIR)\/\1.xml/'))
	@if [ '$(BIBS)' ]; then \
		echo 'making bibliography $(BIBS)'; \
		make $(BIBS); \
	fi
	# $(eval FIGS = $(shell grep '\\includegraphics' $*.tex  | sed -e 's/.*\\includegraphics[^{]*{\([^}]*\)\}.*/$(DISPLAYDIR)\/\1.svg/'))
	# -if [ '$(FIGS)' ]; then \
	# 	echo 'making $(FIGS)'; \
	# 	make $(FIGS); \
	# fi
	latexmlpost --format=xhtml $(foreach bib,$(BIBS),--bibliography=$(bib)) $(LATEXMLPOSTFLAGS) --destination=$@ $<


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
