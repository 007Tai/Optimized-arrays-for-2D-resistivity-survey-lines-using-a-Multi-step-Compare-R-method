# Multi-Step Compare R Optimization for 2-D ERT Arrays

This repository provides a conceptual and simplified implementation of the multi-step Compare R optimization workflow for 2-D electrical resistivity tomography (ERT) array design.

The repository is intended to illustrate the main algorithmic pipeline of the proposed method, including initialization of the base data set, partitioning of candidate configurations into symmetric and asymmetric sets, ranking-based selection, orthogonality filtering, switching from the symmetric search space to the asymmetric search space, and output of the optimized array set.

Please note that this repository provides a lightweight workflow-level demonstration rather than the full production MATLAB/GPU implementation used in the manuscript. The full implementation depends on large precomputed Jacobian matrices, two-electrode sensitivity data, and hardware-specific acceleration procedures.

## Repository contents

- [Simplified pseudocode](./pseudocode.md)
- [Workflow demo script](./multi_step_CR_workflow.m)
- [Raw data folder](./supplementary-materials-data/)

## Workflow demo

The file [`demo_multi_step_CR_workflow.m`](./multi_step_CR_workflow.m) provides a simplified MATLAB mock-up of the proposed multi-step Compare R optimization workflow.

This script demonstrates:

1. Initialization of a base data set;
2. Construction of symmetric and asymmetric candidate sets;
3. Ranking-based selection of candidate arrays;
4. Orthogonality filtering;
5. Switching from the symmetric stage to the asymmetric stage;
6. Output of the optimized array set.

The script uses synthetic placeholder data and mock ranking functions to demonstrate the workflow. It is not intended to reproduce the full numerical results reported in the manuscript.

## How to run the demo

Open MATLAB and run:

```matlab
demo_multi_step_CR_workflow
