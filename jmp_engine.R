# jmp_engine.R
# ---------------------------------------------------------
# Behavioral Digital Twin - Core Engine
# Project: Intertemporal Choice in Vaccination Timing
# Target Audience: Jasper Cooper (DeclareDesign Demonstration)
# ---------------------------------------------------------

#' Simulate JMP Choices with Hyperbolic Discounting (Present Bias)
#'
#' @param data A data.frame containing choice attributes (protection, wait_time)
#' @param beta1 Baseline utility weight for protection efficacy (default: 2.0)
#' @param beta2_base Baseline disutility for waiting time (default: -1.0)
#' @param delta Present bias parameter (JMP empirical finding: 0.16)
#' @return data.frame with calculated discounted beta2 and final utility
simulate_jmp_choices <- function(data, beta1 = 2.0, beta2_base = -1.0, delta = 0.16) {
  
  # ---------------------------------------------------------
  # 注入灵魂: 双曲贴现逻辑 (Hyperbolic Discounting)
  # beta_2 (等待成本) 随时间呈现非线性衰减。
  # 相比于线性惩罚，由于现时偏好 (delta=0.16)，人们对近期的等待极度敏感，
  # 但当等待时间已经很长时，边际等待痛苦反而会“钝化”。
  # Formula: beta_2(t) = beta2_base / (1 + delta * wait_time)
  # ---------------------------------------------------------
  
  data$beta2_discounted <- beta2_base / (1 + delta * data$wait_time)
  
  # ---------------------------------------------------------
  # Utility Calculation
  # U = beta1 * protection + beta2(t) * wait_time + epsilon
  # ---------------------------------------------------------
  
  # Type I Extreme Value (Gumbel) noise for Logit modeling
  # Setting seed locally if needed, but omitted for simulation randomness
  data$epsilon <- rlogis(nrow(data), location = 0, scale = 1)
  
  # Compute final utility
  data$utility <- (beta1 * data$protection) + 
                  (data$beta2_discounted * data$wait_time) + 
                  data$epsilon
                  
  # Calculate Choice Probability (Standard Softmax/Logit transformation)
  # exp(U) / (1 + exp(U)) comparing against an outside option normalized to U=0
  data$prob_choose <- exp(data$utility) / (1 + exp(data$utility))
  
  return(data)
}
