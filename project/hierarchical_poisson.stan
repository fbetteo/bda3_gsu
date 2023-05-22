data {
  int<lower=0> N_observations;
  int<lower=0> N_players;
  array[N_observations] int player_idx; 
  array[N_observations] int pts;
}

parameters {
  // Average points per game per player
  


  
  real<lower=0> shape_general;
  real<lower=0> scale_general;
  
  
  // lambda prior
  vector<lower=0>[N_players] lambda_player;
}

model {
  
  // Hierarchical
     // Hierarchical
    shape_general ~ normal(5,20);
    scale_general ~ normal(2,10);
  
  
  
  // Priors
  for (player in 1:N_players) {
    // Weakly informative. Vague. Based on assignment 7 logic.
    lambda_player[player] ~ gamma(shape_general, scale_general);
  }
  

  // Likelihood
  for (obs in 1:N_observations) {
    pts[obs] ~ poisson(lambda_player[player_idx[obs]] ) ;
  }


  // Best practice would be to write the likelihood without the for loop as:
  // weight ~ normal(mean_diet[diet_idx], sd_diet[diet_idx]);
}

generated quantities {
  
  // As I don't have covariates I can just simulate one time per player.
  // array[N_players] real pts_player = normal_rng(mean_player, sd_player);

  vector[N_observations] lambda_pred = lambda_player[player_idx];
  array[N_observations] real pts_pred = poisson_rng(to_array_1d(lambda_pred));
  
  
  int mean_rookie;
  real lambda_rookie = gamma_rng(shape_general, scale_general);
  mean_rookie = poisson_rng(lambda_rookie);


  // For LOO
  vector[N_observations] log_lik;
  for (n in 1:N_observations) {
    log_lik[n] = poisson_lpmf(pts[n] | lambda_player[player_idx[n]]);
  }
}

