data {
  int<lower=0> N_observations;
  int<lower=0> N_players;
  array[N_observations] int player_idx; 
  array[N_observations] real rest_hours;
  vector[N_observations] pts;
}

parameters {
  // Average points per game per player
  vector<lower=0>[N_players] mean_player;

  // Standard deviation points per game per player
  vector<lower=0>[N_players] sd_player;
  
  vector<lower=0>[N_players] beta_rest;
  
  
  real<lower=0> mean_general;
  real<lower=0> sd_general;
  real<lower=0> mean_rest;
  real<lower=0> sd_rest;
}



transformed parameters {
  
    vector[N_observations] mu_player;
    // deterministic transformation of parameters and data
    for (obs in 1:N_observations) {
      mu_player[obs] = mean_player[player_idx[obs]] + beta_rest[player_idx[obs]] * rest_hours[obs] ;// linear model
    }
}

model {
  
    // Hierarchical
    mean_general ~ normal(10,20);
    sd_general ~ normal(0,30);
    
    mean_rest ~ normal(0,1);
    sd_rest ~ normal(0,1);
    
  
  // Priors
  for (player in 1:N_players) {
    // Weakly informative. Vague. Based on assignment 7 logic.
    mean_player[player] ~ normal(mean_general, sd_general);
    // is this ok?
    sd_player[player] ~ exponential(0.3);
    
    beta_rest[player] ~ normal(mean_rest, sd_rest);
  }
  

  // Likelihood
  for (obs in 1:N_observations) {
    // pts[obs] ~ normal(mean_player[player_idx[obs]] + beta_rest[player_idx[obs]] , sd_player[player_idx[obs]]) T[0,];
    pts[obs] ~ normal(mu_player[obs] , sd_player[player_idx[obs]]) ;
  }


}

generated quantities {
  
  vector[N_observations] mu_pred;
  array[N_players] real pts_player = normal_rng(mean_player + beta_rest*48, sd_player);
  
  for (n in 1:N_observations) {
    mu_pred[n] = mean_player[player_idx[n]] + beta_rest[player_idx[n]]*rest_hours[n];
  }
  vector[N_observations] sd_pred = sd_player[player_idx];
  array[N_observations] real pts_pred = normal_rng(to_array_1d(mu_pred) , to_array_1d(sd_pred));
  
  
  real mean_rookie;
  mean_rookie = normal_rng(mean_general + mean_rest*48, sd_general);


  // For LOO
  vector[N_observations] log_lik;
  for (n in 1:N_observations) {
    log_lik[n] = normal_lpdf(pts[n] | mean_player[player_idx[n]] + beta_rest[player_idx[n]]*rest_hours[n]  , sd_player[player_idx[n]]);
  }
}

