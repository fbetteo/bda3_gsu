
data {
  int<lower=0> M;
  vector[M] x; // Dose predictor
  int N[M]; // N subjects
  int y[M]; // Deaths.
  
  
}

parameters {
    // intercept
    real alpha; 
    // slope
    real beta; 
}


transformed parameters {
    // deterministic transformation of parameters and data
    vector[M] logit_p = (alpha + beta * x) ;// linear model
}

model {
  vector[2] ab; // alpha and beta
  vector[2] mu; // prior mean
  matrix[2,2] Sigma = [[4,12], 
                      [12,100]]; // prior covariance matrix
  
  ab = [alpha, beta]';
  mu = [0,10]';
  
  ab ~ multi_normal(mu, Sigma); // prior on alpha and beta
  
  y ~ binomial_logit(N, logit_p); // likelihood
}

