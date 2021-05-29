clear;

%% load data
load("../data/forecasts_tra.mat");

%% get predict flags
predict_flag = get_predict_flag(X, Y, NHC);
save("../data/predict_flag.mat", "predict_flag");
% load("../data/predict.mat");

%% get baselines
[m,d,T,N] = size(X);
predict(1).name = "Ensemble Mean";
predict(1).tra = nan(d,T-1,N);
predict(2).name = "Persistence";
predict(2).tra = nan(d,T-1,N);
predict(3).name = "NHC";
predict(3).tra = nan(d,T-1,N);

X_flag = get_missing_flag(X, 2, 1);
Y_flag = get_missing_flag(Y, 1, 1);
h=1;
for t=1:N
    for tau=2:T
        if predict_flag(tau,t)
            x=X(:,:,tau,t);
            nhc=NHC(:,tau,t);
            idx=X_flag(:,tau,t);
            predict(1).tra(:,tau-1,t)=mean(x(idx,:),1)';
            predict(3).tra(:,tau-1,t)=nhc;
            if t>time(h,2)
                h=h+1;
            end
            if t>time(h,1) && Y_flag(1,t-1)
                speed = Y(:,1,t) - Y(:,1,t-1);
                pers = Y(:,1,t) + speed*(tau-1);
                predict(2).tra(:,tau-1,t)=pers;   
            end
        end
    end
end

save('../data/predict.mat','predict');
