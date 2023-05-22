data {
  int<lower=0> N_observations;
  int<lower=0> N_players;
  array[N_observations] int player_idx; 
  vector[N_observations] rest_hours;
  array[N_observations] int pts;
}

parameters {
  // Average points per game per player
  vector[N_players] int_player;

  // Standard deviation points per game per player
  vector<lower=0>[N_players] sd_player;
  
  real beta_rest;
  
}

transformed parameters {
    // deterministic transformation of parameters and data
    vector[N_observations] mu_player = int_player[player_idx] + beta_rest * rest_hours ;// linear model
}




model {
  // Priors
  for (player in 1:N_players) {
    // Weakly informative. Vague. Based on assignment 7 logic.
    int_player[player] ~ normal(10, 100);
  }
  
  // Increase in points per hour rested. Is this ok?
  beta_rest ~ normal(0,10);
  

  // Likelihood
  for (obs in 1:N_observations) {
    pts[obs] ~ poisson(mu_player[obs]);
  }


  // Best practice would be to write the likelihood without the for loop as:
  // weight ~ normal(mean_diet[diet_idx], sd_diet[diet_idx]);
}

generated quantities {
  
  // As I don't have covariates I can just simulate one time per player.
  array[N_players] real pts_player = poisson_rng(int_player);

  // vector[N_observations] mu_pred = mean_player[player_idx];
  // vector[N_observations] mu_pred = mean_player[player_idx]  + beta_rest * rest_hours ;
  array[N_observations] real pts_pred = poisson_rng(to_array_1d(mu_player) );


  // For LOO
  vector[N_observations] log_lik;
  for (n in 1:N_observations) {
    log_lik[n] = poisson_lpmf(pts[n] | mu_player[n] );
    // log_lik[n] = normal_lpdf(pts[n] | mean_player[player_idx[n]] + beta_rest * rest_hours , sd_player[player_idx[n]]);
  }
}
