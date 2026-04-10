# JMP-DeclareDesign: Integrating Behavioral Digital Twins into Experimental Diagnosis

## Motivation: The Limits of Static Power Analysis

Traditional experimental power analysis relies on static assumptions: fixed effect sizes, homogeneous treatment uptake, and exogenous compliance rates. However, human decision-making—particularly in public health interventions such as vaccination timing—is fundamentally dynamic. It is governed by intertemporal tradeoffs, heterogeneous trust levels, and varying sensitivities to waiting costs. 

When traditional frameworks ignore these structural behavioral parameters, they risk overestimating statistical power and misdiagnosing the viability of the experimental design, as they fail to account for the "Marginal Compliers" who swing based on temporal frictions.

## The Paradigm Shift: JMP + DeclareDesign

This repository introduces a novel methodological bridge between **Structural Behavioral Economics** and **Experimental Diagnosis**, leveraging the robust MIDA (Model, Inquiry, Data Strategy, Answer Strategy) framework from `DeclareDesign`. 

Instead of drawing outcomes from simple statistical distributions, we construct **Behavioral Digital Twins** calibrated from our Discrete Choice Experiment (DCE) data. This allows us to:
1. **Simulate the DGP Mechanistically:** Generate patient compliance endogenously through an intertemporal utility function.
2. **Capture Dynamic Attrition:** Model how waiting costs disproportionately deter low-trust populations, creating endogenous selection bias.
3. **Conduct Realistic Pre-Experiment Evaluation:** Diagnose both naive Intent-to-Treat (ITT) estimators and Structurally-Adjusted estimators to see which design holds up against real-world behavioral noise.

By diagnosing the experiment through the lens of a structural model, we ensure the experimental design is not just statistically powered, but *behaviorally resilient*.

## Repository Structure

The simulation suite consists of three modular components:

*   `jmp_engine.R`: **The Behavioral DGP.** Simulates a population of Digital Twins with assigned intertemporal preferences, trust levels, and structural utility maximization behavior.
*   `declare_design_analysis.R`: **The MIDA Implementation.** Formally declares the design (Model, Inquiry, Data Strategy, Answer Strategy) and conducts the Monte Carlo diagnosis.
*   `visualize_power.R`: **The Diagnostic Visualizer.** Compares the diagnostic metrics (Power, Bias, RMSE) across varying sample sizes, contrasting standard ITT approaches against structural adjustment.

## Quick Start

```bash
# 1. Install dependencies
install.packages(c("DeclareDesign", "tidyverse", "ggplot2", "broom"))

# 2. Run the diagnostic pipeline and generate power curves
Rscript visualize_power.R
```

## 📖 Call to Action: Full Diagnostic Report

The code above provides the computational engine, but the true value lies in the synthesis of structural modeling and experimental design. 

**👉 Please view the rendered Quarto Report (`DeclareDesign_JMP_Report.html` / `.pdf`)** for:
*   The complete mathematical intuition behind the intertemporal utility function.
*   In-depth discussion of the MIDA declarations.
*   High-resolution diagnostic plots and strategic takeaways for experimental deployment.
