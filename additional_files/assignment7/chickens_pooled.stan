data {
  int<lower=0> N_observations;
  int<lower=0> N_diets;
  array[N_observations] int diet_idx; // Pair observations to their diets.
  vector[N_observations] weight;
}

parameters {
  // Average weight of chicks no matter the diet
  real mean_diet;

  // Standard deviation of weights observed among chicks no matter the diet.
  real<lower=0> sd_diet;
}

model {
  // Priors

    mean_diet ~ normal(670, 120);
    sd_diet ~ uniform(0,100);

  // Likelihood
    weight ~ normal(mean_diet, sd_diet);
  // Best practice would be to write the likelihood without the for loop as:
  // weight ~ normal(mean_diet[diet_idx], sd_diet[diet_idx]);
}

generated quantities {
  real weight_pred;
  real mean_five;

  // Sample from the (posterior) predictive distribution
  weight_pred = normal_rng(mean_diet, sd_diet);
}
