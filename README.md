# Lifted Causal Inference

This repository contains a proof of concept of the lifted causal inference
algorithm that has been presented in the paper
"Lifted Causal Inference in Relational Domains" by
Malte Luttermann, Mattis Hartwig, Tanya Braun, Ralf Möller, and Marcel Gehrke
(CLeaR 2024).

> Note that the lifted causal inference algorithm is not fully implemented in
> this repository. The source code provided here is just a proof of concept
> which calls the lifted variable elimination algorithm on a modified model.
> However, the modification of an initially given model is not part of the
> implementation yet.

## Computing Infrastructure and Required Software Packages
The experimental environment runs Julia version 1.8.1 to start the algorithms.
We use openjdk version 11.0.20 to run the (lifted) inference algorithms, which
are integrated via `instances/ljt-v1.0-jar-with-dependencies.jar`.
Moreover, we run Python version 3.9.13 to run the propositional inference
algorithms.

Python dependencies:
- `pgmpy` (we used version 0.1.24)

## Instance Generation
Go into the directory `src` and run `julia blog_generator.jl` as well as
`python3 bn_generator.py` to generate the instances.
All instances are then stored in the directory `instances/`.

## Running the Experiments
After generating the instances, run `julia run_eval.jl` to start the
experiments.
The results are written to the `results/` directory.
To create the plot, switch into `results/`, run `julia prepare_plot.jl`
and afterwards execute the R script `plot.r`.