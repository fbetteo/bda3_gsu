data {
  int<lower=0> N_observations;
  int<lower=0> N_players;
  array[N_observations] int player_idx; 
  array[N_observations] int pts;
}

parameters {
  // Average points per game per player
  


  
  real<lower=0> alpha_general_1;
  real<lower=0> alpha_general_2;
  real<lower=1> beta_general_1;
  real<lower=1> beta_general_2;
  
  
  // lambda prior
  vector<lower=0>[N_players] alpha_player;
  vector<lower=0, upper=1>[N_players] beta_player;
}

model {
  
  // Hierarchical
     // Hierarchical
    alpha_general_1 ~ normal(7,10);
    alpha_general_2 ~ normal(10,10);
    beta_general_1 ~ normal(5,5);
    beta_general_2 ~ normal(5,5);
  
  
  
  // Priors
  for (player in 1:N_players) {
    // Weakly informative. Vague. Based on assignment 7 logic.
    alpha_player[player] ~ gamma(alpha_general_1, alpha_general_2);
    beta_player[player] ~ beta(beta_general_1, beta_general_2);
  }
  

  // Likelihood
  for (obs in 1:N_observations) {
    pts[obs] ~ neg_binomial(alpha_player[player_idx[obs]],  beta_player[player_idx[obs]]) ;
  }


  // Best practice would be to write the likelihood without the for loop as:
  // weight ~ normal(mean_diet[diet_idx], sd_diet[diet_idx]);
}

generated quantities {
  
  // As I don't have covariates I can just simulate one time per player.
  // array[N_players] real pts_player = normal_rng(mean_player, sd_player);

  vector[N_observations] alpha_pred = alpha_player[player_idx];
  vector[N_observations] beta_pred = beta_player[player_idx];
  array[N_observations] real pts_pred = neg_binomial_rng(to_array_1d(alpha_pred), to_array_1d(beta_pred));
  
  int mean_rookie;
  real<lower=0> alpha_rookie = gamma_rng(alpha_general_1, alpha_general_2);
  real<lower=0, upper=1> beta_rookie = beta_rng(beta_general_1, beta_general_2);
  mean_rookie = neg_binomial_rng(alpha_rookie, beta_rookie );


  // For LOO
  vector[N_observations] log_lik;
  for (n in 1:N_observations) {
    log_lik[n] = neg_binomial_lpmf(pts[n] | alpha_player[player_idx[n]], beta_player[player_idx[n]] );
  }
}

