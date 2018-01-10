---
title:  "Syllabus :: Advanced Biological Statistics II: Bio 610, Winter 2018"
author: "Peter Ralph"
date: "9 January 2018"
...


-  **Class:** 10-12, Tuesday/Thursday.
-  **Office Hours:** Wednesday 12-1 and Friday 11-12 in 282 Onyx
-  **Instructor:** Peter Ralph (plr@uoregon.edu)
-  **Office:** 6 Deady Hall and/or 282 Onyx (email to arrange)


This course is an introduction to advanced methods in modern statistics,
with an emphasis on applied biological data analysis.
After taking this course, 
you will be able to invent, implement, and apply probabilistic models 
that describe the signal and noise inherent in real datasets.
We will cover modern statistical techniques important for dealing with
large, noisy datasets of many variables, 
including regularization, dimensionality reduction, and deconvolution.
Mostly, we will work in the Bayesian hierarchical modeling framework,
using [Stan](http://mc-stan.org/) as interfaced through [R](https://www.r-project.org/).
We will use almost no mathematical analysis (equations) for understanding and implementing these methods,
relying instead on simulation and the properties of the various kinds of randomness.


## Textbook(s) and Software:

* The main textbook is [Doing Bayesian Data Analysis : a tutorial with R, JAGS, and Stan](http://www.indiana.edu/~kruschke/DoingBayesianDataAnalysis/), 2nd edition, by John Kruschke; PDF available at [this link](http://www.sciencedirect.com/science/book/9780124058880), at least on campus (see [uo library entry](https://alliance-primo.hosted.exlibrisgroup.com/UO:CP71230601620001451)).

* We will also refer to [Experimental Design and Data Analysis for Biologists](https://alliance-primo.hosted.exlibrisgroup.com/UO:CP71150990440001451), Quinn and Keough, 2002.

* The [Stan User's Guide](http://mc-stan.org/users/documentation/index.html) will also be often useful.

**Note:** both [JAGS](http://mcmc-jags.sourceforge.net/) and [Stan](http://mc-stan.org/) do roughly the same job,
and are very similar.  Although Kruschke spends more time with JAGS (for historical reasons), we will only use Stan - so, you can skip the JAGS stuff, although you should make it up with the Stan manual.


* We will make constant use of [R](https://www.r-project.org/).

* You will also need [Stan](http://mc-stan.org/) and it's R interface, [rstan](http://mc-stan.org/users/interfaces/rstan).

* To write reports, you need to be able to compile Rmarkdown documents,
    which uses [knitr](https://yihui.name/knitr/) and [pandoc](https://pandoc.org/) 
    (note that Rstudio includes it's own version of pandoc).

* In class, I will use [Rstudio](https://www.rstudio.com) for demonstrations,
    although you don't have to use it.

To test your setup, you should be able to compile [this Rmarkdown document](test_document.Rmd) 
into something that looks like [this html file](test_document.html) (but: the formatting might differ).

## Assessment, and grading

The main course work will be a series of reports, some *short* and others *longer*.
Short reports will be less than one page of text (more, with code), are mostly based on simulated data,
and are designed to demonstrate you understand and can implement an important topic from that week.
These will occur in weeks without a longer report due.
The three longer reports will contain more narrative, describing and analyzing a real dataset that I will provide.
All reports will be turned in as self-contained Rmarkdown documents, that I should be able to run myself.

I will assign grades to each of you, independently, based on how well your
course work demonstrates completion of course goals.  
I will not assign grades for attendance, but class participation 
and group work will be important: please come.
The relative weights of each category will be:

- *short reports:* six, worth together 40% 
- *longer reports:* three, worth 20% each

Preliminary drafts of longer reports will be handed in for feedback partway through.

## Accessibility

I take seriously my responsibility to create inclusive learning environments.
Please notify me if there are aspects of the instruction or design of this
course that result in barriers to your participation! You are also encouraged
to contact the Accessible Education Center in 164 Oregon Hall at 541-346-1155
or uoaec@uoregon.edu.

## Course schedule

The schedule is available [here](schedule.html).

$.$
