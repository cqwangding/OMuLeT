addpath('mykit');
clear;

load("data/model.mat");
load("data/forecasts_tra.mat");
load("data/predict.mat");
load("data/predict_flag.mat");

opts.range = [time(splits(3,1),1), time(splits(3,2),2)];
opts.unit_change = 1.852;

get_error_table(predict, Y(:,2:end,:), predict_flag(2:end,:), opts);
