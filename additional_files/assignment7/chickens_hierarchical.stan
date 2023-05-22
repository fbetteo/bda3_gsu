data {
  int<lower=0> N_observations;
  int<lower=0> N_diets;
  array[N_observations] int diet_idx; // Pair observations to their diets.
  vector[N_observations] weight;
}

parameters {
  // Average weight of chicks with a given diet.
  vector[N_diets] mean_diet;

  // Standard deviation of weights observed among chicks sharing a diet. Shared deviation for all diets.
  real<lower=0> sd_diet;
  
  real<lower=0> mean_general;
  real<lower=0> sd_general;
  
}

model {
  // Priors

    mean_general ~ normal(0,400);
    sd_general ~ normal(0,200);
    sd_diet ~ normal(0,400);
    
  for (diet in 1:N_diets) {
    mean_diet[diet] ~ normal(mean_general, sd_general);
  }

  // Likelihood
  for (obs in 1:N_observations) {
    weight[obs] ~ normal(mean_diet[diet_idx[obs]], sd_diet);
  }

  // Best practice would be to write the likelihood without the for loop as:
  // weight ~ normal(mean_diet[diet_idx], sd_diet[diet_idx]);
}

generated quantities {
  real weight_pred;
  real mean_five;

  // Sample from the (posterior) predictive distribution of the fourth diet.
  weight_pred = normal_rng(mean_diet[4], sd_diet);

  // Construct samples of the mean of the fifth diet.
  mean_five = normal_rng(mean_general, sd_general);
}
