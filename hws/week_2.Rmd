# Longer report #1: Ancient DNA

In this lab you'll be analyzing the nature of genotyping error 
in high-throughput sequencing of ancient DNA.
The DNA comes from two species of ancient hominids,
both recovered from [a cave in Siberia](https://en.wikipedia.org/wiki/Denisova_Cave):
a [Denisovan](http://www.eva.mpg.de/denisova/index.html), from about 75,000 years ago,
and a [Neanderthal](http://www.eva.mpg.de/neandertal/index.html), from about 50,000 years ago.
(*Note:* our species interbred with theirs,
so it is likely that both of these individuals (or, at least, their family members)
are direct ancestors of yours.)

There are a number of contributions to this error, primarily:
(a) DNA damage,
(b) contamination from modern human DNA,
and (c) Illumina sequencing error.
You won't be disentangling these three (unless you're ambitious?), 
but rather characterizing the error, and what it depends on.

**Data:** 
To keep the amount of data reasonable,
I've extracted read count data from the mitochondria
and from some mitochondria-sized regions of the nuclear DNA (on Chromosome 21).
These are available in these four files:

- [Altai Neanderthal](data/altai.counts.gz)
- [Denisovan](data/denisova.counts.gz)

Each file has five columns,
first giving the region (either "mt" for mitochondria, or a number)
and then the number of sequenced `A`, `T`, `C`, and `G` bases, in that order.
In making these files, I have *removed* any sites where the individual was called heterozygous.
So, for our purposes here, 
**you may assume that the most commonly sequenced base at each site is the "correct"**.

*Note:*  
The mitochondria are sequenced at higher read depth
because, well, each cell has more copies of mitochondrial than nuclear DNA in it.


You should address the following **questions** in your report:


A. What is the overall error rate?

B. Do the two samples (Neanderthal and Denisovan) have different error rates?

C. Does the error rate differ by base?  
   In other words, is an `A` more likely to be recorded in error than a `C` is?
   (You don't need to ask whether an `A->T` error is more likely than a `A->G` error.)

D. Does the *pattern* of error rates differ by region -- especially, in the mitochondria?



**Outline:**

1. Read in, and describe the data.  How many sites?  What is the typical coverage?  
   How does this break down by region?  Discard any problematic sites.
   Compute a table of mean error rates, separated by individual, mitochondria/nuclear, and base.
   For instance, out of sites where the true base is `A` 
   in the Denisovan individual's mitochondrial genome,
   what fraction of the sequenced bases showed a `T`? 
   -- and likewise for the other possible combinations.


2. Simulate data similar to the real data, but where you know the truth,
   using data from (1) to pick appropriate amounts of error.


3. *(Methodological set-up)*  To fit a model in which every site has the *same* probability of error,
   you only need to know the *total* coverage and the *total* number of bases that were in error.
   Then, Stan will only need to compute a single likelihood, 
   rather than one for each of the 3 million sites.
   Explain intuitively why this is true.

    Example: the two Stan programs do the same thing, but the second is much faster if `N` is large:
```
data {
    int N;
    int z[N];
    int n[N];
}
parameters {
    real<lower=0, upper=1> theta;
}
model {
    for (k in 1:N) {
        z[k] ~ binomial(n[k], theta);
    }
}
```
and
```
data {
    int N;
    int z[N];
    int n[N];
}
transformed data {
    int z_total;
    int n_total;
    z_total = sum(z);
    n_total = sum(n);
}
parameters {
    real<lower=0, upper=1> theta;
}
model {
    z_total ~ binomial(n_total, theta);
}
```


4. For each question above, formulate a model and explain the motivation behind it,
   test it on the simulated data, then apply it to the real data.
   Use the observation in (3) to do this.


5. Describe your conclusions.


