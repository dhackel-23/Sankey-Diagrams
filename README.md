# Sankey-Diagram Optimiser for Floweaver  
**Selective Flow Hiding and Metric-Based Layout Optimisation**

## 🔍 Project Overview

This project introduces a **systematic method for improving the readability of complex Sankey diagrams** by selectively hiding visually disruptive flows. Built on the open-source [Floweaver](https://github.com/ricklupton/floweaver) Python package, the optimiser evaluates layout quality using multiple visual clarity metrics and applies **Mixed-Integer Linear Programming (MILP)** for diagram structuring.

The method is especially useful for large, layered diagrams where overlapping or thin flows reduce interpretability.

---

## 🚀 Key Contributions

- **Selective Flow Hiding**: Developed a scoring system to identify and hide low-priority flows based on visual clutter metrics.
- **Visual Metrics for Layout Quality**:
  - Total number of crossings  
  - Sum of crossing area  
  - Vertical span (flow compactness)
- **Permutation-Based Optimisation**: Tested 100–200 randomised permutations at multiple hiding levels (10%, 25%, 40%) to balance flow retention and clarity.
- **Modular Workflow**: Includes reusable code for flow hiding, metric evaluation, layout optimisation, and result visualisation.

---

## 📁 Repository Contents
├── README.md # Project documentation
├── Smart_remover_test.ipynb # Flow hiding tests on small datasets
├── Smart_remover_fruit.ipynb # Full workflow using synthetic fruit dataset
├── diagram_optimisation.py # Core MILP layout optimiser (extended from Floweaver)
├── test_flows.csv # Basic test flows
├── test_processes.csv # Basic test processes
├── synthetic_fruit_flows.csv # Larger flow dataset
├── synthetic_fruit_processes.csv # Corresponding process dataset


---

## 🧪 Methodology Summary

- **Framework**: Python + Jupyter + Floweaver  
- **Flow Hiding Logic**: Redirects selected flows to a dummy `"HIDDEN"` node to reduce diagram clutter while preserving flow conservation.  
- **MILP Layout Optimisation**: Optimises node ordering and positioning via `diagram_optimisation.py`.  
- **Scoring & Evaluation**: Tracks metrics across multiple permutations, ranks outcomes based on a composite score.

---

## 📊 Key Results

- **10% Flow Hiding** led to:
  - **>90% reduction in crossings**
  - **Minimal visual distortion**
- **Top Scoring Layout** had a gain score of **16.2** at **9.17% flow removal**
- **Modular Evaluation** enables scaling to large datasets and higher trial counts

---

## 🛠 Installation & Requirements
**Python 3.8+**

** 📬 Contact**
Feel free to get in touch with any questions or suggestions:
📧 diegohackel8@gmail.com

** 📖 Citation**
If you use this project in academic research or presentations, please cite:
Hackel, Diego (2025). Optimising Sankey Diagram Readability Using Flow Hiding and MILP-Based Layout Scoring. Final Year Project, University of [Your Institution].
