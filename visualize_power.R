# visualize_power.R
# ---------------------------------------------------------
# Power Curve Visualization: Traditional vs. JMP Model
# Target Audience: Jasper Cooper (Behavioral Digital Twin Demo)
# ---------------------------------------------------------

# 加载依赖 (包含 ggplot2 和高级配色包)
suppressPackageStartupMessages({
  library(DeclareDesign)
  library(estimatr)
  library(ggplot2)
  library(dplyr)
  library(viridis)  # 提供高质量 Nature 级别配色
})

source("jmp_engine.R")

# ---------------------------------------------------------
# 1. 动态生成研究设计
# ---------------------------------------------------------
# 定义一个函数，用于快速构建不同折现模型下的 DeclareDesign
build_eval_design <- function(N_size, delta_val) {
  declare_model(
    N = N_size,
    # 控制组 (Z=0): 即时接种 (无等待)
    prob_0 = simulate_jmp_choices(
      data.frame(protection = rep(0.9, N), wait_time = rep(0, N)), 
      beta1 = 2.0, beta2_base = -0.4, delta = delta_val
    )$prob_choose,
    Y_Z_0 = rbinom(N, 1, prob_0),
    
    # 实验组 (Z=1): 延迟接种 (等待3个月)
    prob_1 = simulate_jmp_choices(
      data.frame(protection = rep(0.9, N), wait_time = rep(3, N)), 
      beta1 = 2.0, beta2_base = -0.4, delta = delta_val
    )$prob_choose,
    Y_Z_1 = rbinom(N, 1, prob_1)
  ) +
  declare_inquiry(ATE = mean(Y_Z_1 - Y_Z_0)) +
  declare_assignment(Z = complete_ra(N, prob = 0.5)) +
  declare_measurement(Y = reveal_outcomes(Y ~ Z)) +
  declare_estimator(Y ~ Z, model = lm_robust, inquiry = "ATE")
}

# ---------------------------------------------------------
# 2. 批量诊断与蒙特卡洛模拟
# ---------------------------------------------------------
cat("Simulating Power Curves. This takes about 10 seconds...\n")
set.seed(20260410)

# 定义要测试的样本量网格 (扩大范围以展示完整的 S 型曲线)
N_grid <- c(300, 500, 800, 1200, 1600, 2000)
results_list <- list()

for(n in N_grid) {
  # 传统模型 (delta = 0，线性成本)
  # 线性模型下，等待的惩罚被等比例放大，导致 ATE 巨大，极其容易显著
  trad_design <- build_eval_design(n, delta_val = 0.0)
  diag_trad <- diagnose_design(trad_design, sims = 300)
  pwr_trad <- diag_trad$diagnosands_df$power
  results_list[[length(results_list) + 1]] <- data.frame(N = n, Power = pwr_trad, Model = "Traditional Model (Linear, δ=0)")
  
  # JMP 模型 (delta = 0.16，双曲贴现)
  # JMP发现：等待时间拉长后，边际痛感钝化，导致实际 ATE 缩小，显著性极难捕捉
  jmp_design <- build_eval_design(n, delta_val = 0.16)
  diag_jmp <- diagnose_design(jmp_design, sims = 300)
  pwr_jmp <- diag_jmp$diagnosands_df$power
  results_list[[length(results_list) + 1]] <- data.frame(N = n, Power = pwr_jmp, Model = "JMP Model (Hyperbolic, δ=0.16)")
}

power_df <- bind_rows(results_list)

# ---------------------------------------------------------
# 3. 高级可视化 (ggplot2)
# ---------------------------------------------------------
cat("Generating high-end academic plot...\n")

p_power <- ggplot(power_df, aes(x = N, y = Power, color = Model, group = Model)) +
  # 绘制 80% Power 基准线
  geom_hline(yintercept = 0.80, linetype = "dashed", color = "gray50", linewidth = 0.8) +
  
  # 核心折线与数据点
  geom_line(linewidth = 1.5, alpha = 0.85) +
  geom_point(size = 4, shape = 21, fill = "white", stroke = 1.5) +
  
  # 审美注入: 采用 viridis 的 mako 色板 (深海色系，顶级期刊最爱，对色弱友好)
  scale_color_viridis_d(option = "mako", begin = 0.2, end = 0.7) + 
  
  # 坐标轴格式化
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), limits = c(0, 1.05), breaks = seq(0, 1, 0.2)) +
  scale_x_continuous(breaks = N_grid) +
  
  # 学术极简主题
  theme_minimal(base_size = 15) +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    legend.text = element_text(size = 13),
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 18, margin = margin(b = 8)),
    plot.subtitle = element_text(size = 13, color = "gray40", margin = margin(b = 20)),
    axis.title.x = element_text(margin = margin(t = 15), face = "bold"),
    axis.title.y = element_text(margin = margin(r = 15), face = "bold"),
    plot.margin = margin(20, 20, 20, 20)
  ) +
  
  # 标题与叙事
  labs(
    title = "Statistical Power: Traditional vs. JMP Behavioral Twin",
    subtitle = "Present bias (δ=0.16) attenuates the delayed wait penalty, shrinking the observable ATE.\nThis demonstrates why standard linear models dangerously overestimate statistical power.",
    x = "Sample Size (N)",
    y = "Statistical Power"
  ) +
  
  # 80% 线标注
  annotate("text", x = max(N_grid), y = 0.83, label = "80% Power Threshold", 
           hjust = 1, color = "gray50", fontface = "italic", size = 4.5)

# ---------------------------------------------------------
# 4. 输出图表
# ---------------------------------------------------------
ggsave("fig_power_comparison.pdf", plot = p_power, width = 10, height = 6.5, dpi = 300)
ggsave("fig_power_comparison.png", plot = p_power, width = 10, height = 6.5, dpi = 300, bg = "white")

cat("Done! Visualizations saved to 'fig_power_comparison.png/pdf'.\n")
