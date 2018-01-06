To publish
==========

Workflow
--------
1. Edit source docs.
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
7. If you want pdf and/or html docs (which will appear in `display/`), do
```
make pdfs
make htmls
```
8. Occasionally, run
```
make clean
```
to keep things tidy.




How to use it
-------------
1. [Download](https://github.com/petrelharp/skelml/zipball/master) the source from this project, unzip it, and rename the resulting directory to whatever you want your project to be called.
2. Initialize a git repository in that directory and add the files to the repository. (`git init .; git add $(git ls-files --other); git commit -a -m 'initial skeleton'`)
3. Run `make setup` to set up the `gh-pages` branch.
4. Get some source files in there.  Add them to the repository (`git add`).
5. Follow "Workflow" above.


How it works:
-------------
1. `make display` runs [pandoc](http://johnmacfarlane.net/pandoc/) on all the `.md` or `.Rmd` files to create the html/xhtml in `display/`.
2. The `gh-pages` branch keeps a copy of everything in the `display/` directory. `make publish` checks out `gh-pages`, and updates from `display/`, removing from the index all files no longer present.  This means anything in `display/` you check into git will '''not appear in gh-pages'''.


Notes
-----
1. You could replace the "push to gh-pages" step with updating a static website, as [described here](http://nicolasgallagher.com/simple-git-deployment-strategy-for-static-sites/).
2. This automatically creates an `index.xhtml` page for you; to make your own, just create an index.md or index.tex file.

Troubleshooting
---------
1. Do *not* put spaces in the file names.  This will confuse `make` a whole lot.

To-do
-----
1. Should also automatically copy over tracked `.html`, etcetera files?
2. Make it so we don't have to `clean` out all the latexml'ed temporary image files all the time?
