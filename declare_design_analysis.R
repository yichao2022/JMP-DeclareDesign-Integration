# declare_design_analysis.R
# ---------------------------------------------------------
# DeclareDesign Analysis Framework
# Target Audience: Jasper Cooper & DeclareDesign Core Team
# Project: Behavioral Digital Twin (Intertemporal Choice in Vaccination)
# ---------------------------------------------------------

library(DeclareDesign)
library(estimatr)
source("jmp_engine.R")

# ---------------------------------------------------------
# 1. Base Design Declaration (Standardized DD Pipeline)
# ---------------------------------------------------------
jmp_design <- 
  # Step 1: Model (Data Generating Process)
  declare_model(
    N = 1000,
    # 抽取 JMP Engine 生成潜在结果 (Potential Outcomes)
    # Z = 0: 即时接种 (0个月等待，假设保护率 0.9 控制变量不变)
    prob_0 = simulate_jmp_choices(
      data.frame(protection = rep(0.9, N), wait_time = rep(0, N)), 
      beta1 = 2.0, beta2_base = -1.5, delta = 0.16
    )$prob_choose,
    Y_Z_0 = rbinom(N, 1, prob_0),
    
    # Z = 1: 延迟接种 (等待 3 个月)
    prob_1 = simulate_jmp_choices(
      data.frame(protection = rep(0.9, N), wait_time = rep(3, N)), 
      beta1 = 2.0, beta2_base = -1.5, delta = 0.16
    )$prob_choose,
    Y_Z_1 = rbinom(N, 1, prob_1)
  ) +
  
  # Step 2: Inquiry (Estimand)
  # ATE: 等待成本对接种意愿的边际影响 (Marginal impact of wait time)
  declare_inquiry(ATE = mean(Y_Z_1 - Y_Z_0)) +
  
  # Step 3: Assignment
  # 完全随机分配，50% 概率进入延迟组
  declare_assignment(Z = complete_ra(N, prob = 0.5)) +
  
  # Step 4: Measurement
  # 现实观测值 Y = Z * Y_Z_1 + (1 - Z) * Y_Z_0
  declare_measurement(Y = reveal_outcomes(Y ~ Z)) +
  
  # Step 5: Estimator
  # 使用 OLS 带有稳健标准误 (lm_robust from estimatr) 来估计 ATE
  declare_estimator(Y ~ Z, model = lm_robust, inquiry = "ATE", label = "OLS_Robust")

# ---------------------------------------------------------
# 2. Redesign: Varying Sample Sizes (N)
# ---------------------------------------------------------
# 测试我们在 N=800, 1200, 2000 下的设计稳健性
designs_to_test <- redesign(jmp_design, N = c(800, 1200, 2000))

# ---------------------------------------------------------
# 3. Diagnosis: Monte Carlo Simulation
# ---------------------------------------------------------
# 运行 500 次模拟计算 Statistical Power, Bias, RMSE 等诊断指标
cat("\n[1/2] Initiating Monte Carlo Diagnosis (sims = 500)...\n")
set.seed(20260410)
diagnosis_results <- diagnose_designs(designs_to_test, sims = 500)

cat("\n[2/2] Diagnosis Complete. Extracting Statistical Power:\n")
# 打印核心诊断结果 (我们只聚焦在 Power 和 ATE 上)
summary_table <- diagnosis_results$diagnosands_df
power_report <- summary_table[, c("design_label", "inquiry", "estimator", "power", "mean_estimand", "mean_estimate")]
print(power_report)

# 将诊断结果保存为 RDS 供后续绘图或 Dashboard 调用
saveRDS(diagnosis_results, "diagnosis_results.rds")
cat("\nResults saved to 'diagnosis_results.rds'. Ready for Jasper's review.\n")
