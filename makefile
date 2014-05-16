### To set up the gh-pages branch:
# git checkout --orphan gh-pages
# (REMOVE FILES LYING AROUND NOW)
# cp directory-to-gh-pages-stuff/* .
# git add (STUFF JUST ADDED)
#

.PHONY : clean publish pdfs

###
# names of files you want made and published to github (in gh-pages) should be in html-these-files.mk
# which lives in the master branch and is automatically pushed over
include config.mk

MD_HTML = $(patsubst %.md,%.html,$(MDFILES))
TEX_HTML = $(patsubst %.tex,%.html,$(TEXFILES))
TEX_XHTML = $(patsubst %.tex,%.xhtml,$(TEXFILES))
WEBPAGES = $(MD_HTML) $(TEX_HTML) $(TEX_XHTML)

PDFS = $(patsubst %.tex,$(DISPLAYDIR)/%.pdf,$(TEXFILES))
XHTMLS = $(patsubst %.tex,$(DISPLAYDIR)/%.xhtml,$(TEXFILES))

# hope their head isn't detached
GITBRANCH = $(shell git symbolic-ref -q HEAD)

xhtmls :
	make $(XHTMLS)

pdfs :
	make $(PDFS)

# update html in the gh-pages branch
#   add e.g. 'pdfs' to the next line to also make pdfs available there
publish : xhtmls
	git checkout gh-pages
	cp -r display/* .
	git commit -a -m 'automatic update of html'
	git checkout $(GITBRANCH)

# set up a clean gh-pages branch
setup : 
	git checkout --orphan gh-pages
	-rm $(shell git ls-files -c | grep -v resources)
	git rm --cached $(shell git ls-files --cached | grep -v resources)
	git commit -m 'initialized gh-pages branch'
	git checkout $(GITBRANCH)

clean : 
	-rm -f *.aux *.log *.bbl *.blg *.out *.toc *.nav *.snm *.vrb texput.*
	rm -f LaTeXML.cache


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

$(DISPLAYDIR)/%.html : %.tex
	$(eval BIBS := $(shell grep '\\bibliography' $*.tex | sed -e 's/.*\\bibliography[^{]*{\([^}]*\)\}.*/$(DISPLAYDIR)\/\1.xml/'))
	echo 'making $(BIBS)'
	rm -f LaTeXML.cache
	latexmlc --format=html5 --bibliography=$(DISPLAYDIR)/coaltheory.xml --javascript=resources/LaTeXML-maybeMathjax.js --css=resources/plr-style.css --stylesheet=resources/xsl/LaTeXML-all-xhtml.xsl --javascript=resources/adjust-svg.js --destination=$@ $<

$(DISPLAYDIR)/%.xhtml : %.tex
	$(eval BIBS := $(shell grep '\\bibliography' $*.tex | sed -e 's/.*\\bibliography[^{]*{\([^}]*\)\}.*/$(DISPLAYDIR)\/\1.xml/'))
	echo 'making $(BIBS)'
	if [ '$(BIBS)' ]; then make $(BIBS); fi
	$(eval FIGS := $(shell grep includegraphics $*.tex  | sed -e 's/.*\\includegraphics[^{]*{\([^}]*\)\}.*/$(DISPLAYDIR)\/\1.svg/'))
	echo 'making $(FIGS)'
	if [ '$(FIGS)' ]; then make $(FIGS); fi
	latexmlc --format=xhtml --bibliography=$(BIBS) --javascript=resources/LaTeXML-maybeMathjax.js --css=resources/plr-style.css --stylesheet=resources/xsl/LaTeXML-all-xhtml.xsl --javascript=resources/adjust-svg.js --destination=$@ $<

# $(DISPLAYDIR)/%.xml : %.tex
# 	rm -f LaTeXML.cache
# 	latexml --preamble=header.tex --postamble=tailer.tex --destination=$@ $<
# 
# $(DISPLAYDIR)/%.xhtml : $(DISPLAYDIR)/%.xml
# 	$(eval BIBS := $(shell grep '\\bibliography' $*.tex | sed -e 's/.*\\bibliography[^{]*{\([^}]*\)\}.*/$(DISPLAYDIR)\/\1.xml/'))
# 	echo 'making $(BIBS)'
# 	if [ '$(BIBS)' ]; then make $(BIBS); fi
# 	$(eval FIGS := $(shell grep includegraphics $*.tex  | sed -e 's/.*\\includegraphics[^{]*{\([^}]*\)\}.*/$(DISPLAYDIR)\/\1.svg/'))
# 	echo 'making $(FIGS)'
# 	if [ '$(FIGS)' ]; then make $(FIGS); fi
# 	latexmlpost --bibliography=$(BIBS) --css=resources/plr-style.css --javascript=resources/LaTeXML-maybeMathjax.js --javascript=resources/adjust-svg.js --stylesheet=resources/xsl/LaTeXML-all-xhtml.xsl --destination=$@ $<


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
