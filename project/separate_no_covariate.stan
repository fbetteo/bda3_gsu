data {
  int<lower=0> N_observations;
  int<lower=0> N_players;
  array[N_observations] int player_idx; 
  vector[N_observations] pts;
}

parameters {
  // Average points per game per player
  vector[N_players] mean_player;

  // Standard deviation points per game per player
  vector<lower=0>[N_players] sd_player;
  
  
}

model {
  // Priors
  for (player in 1:N_players) {
    // Weakly informative. Vague. Based on assignment 7 logic.
    mean_player[player] ~ normal(10, 100);
    // is this ok?
    sd_player[player] ~ exponential(1);
  }
  

  // Likelihood
  for (obs in 1:N_observations) {
    pts[obs] ~ normal(mean_player[player_idx[obs]] , sd_player[player_idx[obs]]);
  }


  // Best practice would be to write the likelihood without the for loop as:
  // weight ~ normal(mean_diet[diet_idx], sd_diet[diet_idx]);
}

generated quantities {
  
  // As I don't have covariates I can just simulate one time per player.
  array[N_players] real pts_player = normal_rng(mean_player, sd_player);

  vector[N_observations] mu_pred = mean_player[player_idx];
  vector[N_observations] sd_pred = sd_player[player_idx];
  array[N_observations] real pts_pred = normal_rng(to_array_1d(mu_pred) , to_array_1d(sd_pred));


  // For LOO
  vector[N_observations] log_lik;
  for (n in 1:N_observations) {
    log_lik[n] = normal_lpdf(pts[n] | mean_player[player_idx[n]]  , sd_player[player_idx[n]]);
  }
}
