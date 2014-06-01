skelml
======

This is a skeleton for a project that
1. contains LaTeX and/or markdown files
2. is checked into a git repository, and
3. has products automatically compiled into xhtml/html and pushed to github pages.

Workflow
--------
1. Edit LaTeX.
2. Run
```
make display
```
3. Look at the output, which lives in `display/`; revise; repeat.
4. Commit changes. (`git commit -a`)
5. When it all looks good, run
```
make publish
```
6. When you update your github repository, also update the gh-pages branch, e.g. by:
```
git push origin --all
```
or, to be specific
```
git push origin master:master
git push origin gh-pages:gh-pages
```
Then, the web page for your project will have nice, freshly updated html made from your latex and markdown documents.
7. If you want pdfs, in `display/`, do
```
make pdfs
```
8. Occasionally, run
```
make clean
```
to keep things tidy.



Prerequisites
-------------

1. [LaTeXML](http://dlmf.nist.gov/LaTeXML) 
2. [git](http://git-scm.com/)
3. [github account](http://github.com) or else modify to push to your own web server; see below.



How to use it
-------------
1. [Download](https://github.com/petrelharp/skelml/zipball/master) the source from this project, unzip it, and rename the resulting directory to whatever you want your project to be called.
2. Initialize a git repository in that directory and add the files to the repository. (`git init .; git add $(git ls-files --other); git commit -a -m 'initial skeleton'`)
3. Run `make setup` to set up the `gh-pages` branch.
4. Get some source files in there.  Add them to the repository (`git add`).
5. Follow "Workflow" above.


How it works:
-------------
1. `make display` runs [LaTeXML](http://dlmf.nist.gov/LaTeXML) on all `.tex` files, and [pandoc](http://johnmacfarlane.net/pandoc/) on all the `.md` files to create the html/xhtml in `display/`.
2. The `gh-pages` branch keeps a copy of everything in the `display/` directory. `make publish` checks out `gh-pages`, and updates from `display/`, removing from the index all files no longer present.  This means anything in `display/` you check into git will '''not appear in gh-pages'''.


Notes
-----
1. You could replace the "push to gh-pages" step with updating a static website, as [described here](http://nicolasgallagher.com/simple-git-deployment-strategy-for-static-sites/).


Troubleshooting
---------
1. Do *not* put spaces in the file names.  This will confuse `make` a whole lot.
2. If you get the error
```
/bin/bash: latexml: command not found
```
then you need to either put the `latexml` executable in your `PATH`, or else add its full path to the `makefile`, e.g.
```
LATEXML = /path/to/latexml
```
and likewise for `latexmlc` and `latexmlpost`.

To-do
-----
1. Automate creation of `index.html`.
