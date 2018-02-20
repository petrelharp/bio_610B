###
# Diabetes analysis
# Week 7 homework
###

# set-up
library(matrixStats)
library(parallel)
library(rstan)
num_cores <- parallel::detectCores()
options(mc.cores = num_cores)

# make randomness reproducible
set.seed(125)

# Data obtained from https://www4.stat.ncsu.edu/~boos/var.select/diabetes.tab.txt
# with column names adjusted from lars::diabetes
# Originally described (sketchily) in
#     Efron, Hastie, Johnstone and Tibshirani (2003) "Least Angle
#     Regression" (with discussion) _Annals of Statistics_

diabetes <- read.table("data/diabetes.tab.txt", sep='\t', header=TRUE)

## describe data

# numbers
summary(diabetes)

# pairwise interactions
# ... any outliers?
pairs(diabetes, col=adjustcolor(diabetes$sex, 0.25), pch=20)


# zoom in on response variable:
# ... any outliers?
hist(diabetes$y, breaks=30, main="diabetes, response")

qqnorm(diabetes$y)
qqline(diabetes$y)

## look at OLS residuals to check for Normal-ness
full_ols <- lm(y ~ ., data=diabetes)

plot(diabetes$y, resid(full_ols), xlab='observed response',
     ylab='residual, OLS')

###
# Model fit and comparison
#  ... we'll compare OLS and the Horseshoe
# with five-fold crossvalidation
###

# the Stan model
horseshoe_block <- "
data {
    int N;
    int p;
    vector[N] y;
    matrix[N,p] x;
}
parameters {
    real b0;
    vector[p] d_beta;
    vector[p] d_a;
    vector<lower=0>[p] d_b;
    real<lower=0, upper=1> tau;
    real<lower=0> sigma;
    real<lower=0> nu;
}
transformed parameters {
    vector[p] beta;
    beta = d_beta .* d_a .* sqrt(d_b) * tau;
}
model {
    y ~ normal(b0 + x * beta, sigma);
    // HORSESHOE PRIOR:
    d_beta ~ normal(0, 1);
    d_a ~ normal(0, 1);
    d_b ~ inv_gamma(0.5 * nu, 0.5 * nu);
    // tau ~ uniform(0, 1); // uniform
    // priors on noise distribution:
    sigma ~ normal(0, 10);
    // prior on shape parameter for horseshoe prior
    nu ~ normal(0, 20);
}"


#### Process the data
# rescale data
vars <- setdiff(names(diabetes), "y")
x <- diabetes[,c("y",vars)]
var_centers <- colMedians(as.matrix(x))
var_scales <- colMads(as.matrix(x))
names(var_centers) <- names(var_scales) <- colnames(x)
var_scales['sex'] <- 1.0  # don't scale sex
for (k in 1:ncol(x)) {
    x[[k]] <- (x[[k]] - var_centers[k])/var_scales[k]
}

# add interactions
for (i in 1:length(vars)) {
    for (j in i:length(vars)) {
        x <- cbind(x, x[[vars[i]]] * x[[vars[j]]])
        colnames(x)[ncol(x)] <- paste(vars[i], vars[j], sep=":")
    }
}
# the interaction term for sex doesn't do anything
x <- x[,setdiff(colnames(x), 'sex:sex')]


##### Fit models

fit_models <- function (use_these, ...) {
    # fit the models on everything NOT marked by use_these
    test_d <- x[use_these,]
    training_d <- x[!use_these,]

    ## OLS
    ols <- lm(y ~ ., data=training_d)


    # horseshoe
    horseshoe <- stan(model_code=horseshoe_block,
                          data=list(N=nrow(training_d),
                                    p=ncol(training_d)-1,
                                    y=training_d$y,
                                    x=as.matrix(training_d[,-1])),
                          iter=1000, ...,
                          control=list(adapt_delta=0.999,
                                       max_treedepth=15))

    return(list(ols=ols, 
                horseshoe=horseshoe,
                test_d=test_d,
                training_d=training_d))
}

# this will compute crossvalidation error
predict_models <- function (m) {

    samples <- extract(m$horseshoe, pars=c("b0", "sigma", "beta"))

    post_med_intercept <- median(samples$b0)
    post_med_sigma <- median(samples$sigma)
    post_med_slopes <- colMedians(samples$beta)

    ols_pred <- predict(m$ols, newdata=m$test_d)
    ols_mse_pred <- sqrt(mean((ols_pred - m$test_d$y)^2))
    ols_mse_fit <- sqrt(mean(resid(m$ols)^2))

    pred_stan <- function (x) {
        post_med_intercept + as.matrix(x[,setdiff(colnames(x),"y")]) %*% post_med_slopes
    }
    horseshoe_mse_pred <- sqrt(mean((m$test_d$y - pred_stan(m$test_d))^2))
    horseshoe_mse_fit <- sqrt(mean((m$training_d$y - pred_stan(m$training_d))^2))

    return( c("ols_pred"=ols_mse_pred, 
              "horseshoe_pred"=horseshoe_mse_pred, 
              "ols_fit"=ols_mse_fit, 
              "horseshoe_fit"=horseshoe_mse_fit) )
}

# set up crossvalidation
test_indices <- sample.int(5, length(diabetes$y), replace=TRUE)

# cache expensive result
if (!file.exists("data/diabetes_crossval_fits.RData")) {
    crossval_fits <- mclapply(1:5, function (k) {
                        use_these <- (test_indices == k)
                        return( fit_models(use_these, chains=1) )
                      }, mc.cores=num_cores )
    save(crossval_fits, file="data/diabetes_crossval_fits.RData")
} else {
    load("data/diabetes_crossval_fits.RData")
}


# Compare crossvalidation results across the five crossvalidation runs
# *_pred is the important information, giving the root-mean-square error
#   for predicting to the *test* dataset;
# *_fit gives the RMS residuals for the training data
(mse_table <- sapply(crossval_fits, predict_models))


###
# full data fit
if (!file.exists("data/diabetes_big_fit.RData")) {
    big_fit <- fit_models(rep(FALSE,nrow(x)))
    save(big_fit, file="data/diabetes_big_fit.RData")
} else {
    load("data/diabetes_big_fit.RData")
}

ols_ses <- summary(big_fit$ols)$coefficients[,2]

summary(big_fit)

# although some of the auxillary parameters (d_b) don't mix well,
# what matters - beta - does mix well enough:

(horseshoe_summary <- summary(big_fit$horseshoe, pars=c("b0", "tau", "sigma", "nu", "beta"))$summary)



## plot coefficients

slope_names <- sprintf("beta[%d]",1:64)

layout(t(1:2))
plot(coef(big_fit$ols), xlab="coefficient", 
     ylab="estimate", main="OLS", pch=20)
segments(x0=1:65,
         y0=coef(big_fit$ols) - 2 * ols_ses,
         y1=coef(big_fit$ols) + 2 * ols_ses,
         col=adjustcolor("black", 0.5))
plot(horseshoe_summary[c("b0",slope_names),"50%"],
     xlab='coefficient', ylab="estimate",
     pch=20, main="sparse")
segments(x0=1, 
         y0=horseshoe_summary["b0","2.5%"],
         y1=horseshoe_summary["b0","97.5%"])
segments(x0=2:65, 
         y0=horseshoe_summary[slope_names,"2.5%"],
         y1=horseshoe_summary[slope_names,"97.5%"])


## tables of coefficients:
# compare OLS coefficents to horseshoe coefficients
# and see which are significant predictors

options(scipen=3)
coef_df <- data.frame(ols=coef(big_fit$ols), stan=horseshoe_summary[c("b0",slope_names), "50%"])
coef_df[c(1,1+order(abs(coef_df$ols[-1]), decreasing=TRUE)),]
coef_df[c(1,1+order(abs(coef_df$stan[-1]), decreasing=TRUE)),]

plot(coef_df, type='n', xlab='OLS coefficients (scaled)', ylab='horseshoe coefficients (scaled)')
text(coef_df, labels=rownames(coef_df))
abline(0,1)


## Produce a predictive model

nonzeros <- ((horseshoe_summary[,"2.5%"] > 0) | (horseshoe_summary[,"97.5%"] < 0))
horseshoe_summary[nonzeros,]

# hm, no interactions are significantly nonzero!
hs <- horseshoe_summary[nonzeros,c(1,3:8)]
nonzero_names <- intersect(rownames(hs), slope_names)
nonzero_vars <- colnames(x)[1+match(nonzero_names, slope_names)]
rownames(hs)[rownames(hs) %in% nonzero_names] <- nonzero_vars

# predictive model:
predict_y <- function (sex, bmi, bp, ltg) {
    sex <- (sex - var_centers['sex']) / var_scales['sex']
    bmi <- (bmi - var_centers['bmi']) / var_scales['bmi']
    bp <- (bp - var_centers['bp']) / var_scales['bp']
    ltg <- (ltg - var_centers['ltg']) / var_scales['ltg']
    z <- (sex * hs["sex","mean"] +
          bmi * hs["bmi","mean"] +
          bp * hs["bp","mean"] +
          ltg * hs["ltg","mean"])
    out <- var_centers['y'] + var_scales['y'] * z
    return(out)
}

with(diabetes, plot(y, predict_y(sex, bmi, bp, ltg),
                    xlab='observed value',
                    ylab='predicted value'))
abline(0,1)
