addpath('mykit');
clear;

cd experiments
run_baselines
run_PA
run_ORION
run_OMuLeT
cd ..

plot_table
