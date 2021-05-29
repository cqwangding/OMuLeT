addpath('mykit');
clear;

opts.config_filename='uwm.config';

opts.time_train=datenum('201401010000','yyyymmddHHMM');
opts.time_vali=datenum('201501010000','yyyymmddHHMM');
% subset of models
% NVGM NVGI AVNO AVNI EGRI EGR2 CMC CMCI HWRF HWFI CTCX CTCI HMON HMNI AEMN AEMI TVCN TVCA TVCN TVCE TVCX RVCN CLP5 OCD5 OCD5 TCLP DRCL SHIP DSHP LGEM
opts.models = [2 3 8 9 10 11 15 17 22 23 25 26 26 47 50 52 59 67 71 72 72 76 77 80 106 107 108 109 111 117];
opts.models_min=1;

opts.t=6;  % time interval
opts.s=2;  % window size
opts.alpha=8;  % forcasted
opts.beta=8;  % forcast
opts.f=2;  % feature number

para=[0.5    0.8    0.1  450    1.6    0.3];
opts.rho=para(1);
opts.gamma=para(2);
opts.omega=para(3);
opts.mu=para(4);
opts.nu=para(5);
opts.eta=para(6);

locations = {'AL & EP', 'AL', 'EP'};
for i = 1:3
    fprintf('Experiments for location: %s\n', locations{i});
    opts.location = i-1; % 0 for all, 1 for al, 2 for ep
    get_hurricane_split(opts);
    % get_forecast_error(opts);
    get_forecast_online(opts);
    get_forecast_online_error(opts);
    fprintf('----------------------------------------------------------------------\n')
end
