function error = get_forecast_online_error(opts)
%   Detailed explanation goes here
    if nargin<1
        fprintf('Not enough input arguments!\n');
        return;
    end
    if ~isfield(opts, 'config_filename')
        fprintf('Configure Filename Not Found!\n');
        return;
    end
    if isfield(opts, 'config_add')
        [configure_all, filename_all] = get_configure(opts.config_filename, opts.config_add);
    else
        [configure_all, filename_all] = get_configure(opts.config_filename);
    end

    process = 'Calculate prediction error';
    fprintf('---------- %s / Begin ----------\n', process);
    
    load(sprintf('%s/hurricane.mat',filename_all.data_dir));
    load(sprintf('%s/train_test_idx.mat',filename_all.data_dir));
    filename=sprintf('forecast_tensor_%d_%d',opts.t,opts.beta);
    load(sprintf('%s/%s.mat',filename_all.data_dir,filename));
    
    for ii=1:4
        if ii==1
            current_idx=train_idx;
        elseif ii==2
            current_idx=vali_idx;
        elseif ii==3
            current_idx=[train_idx vali_idx];
        else
            current_idx=test_idx;
        end
        error_mean=zeros(opts.beta,1);
        error_median=zeros(opts.beta,1);
        error_online=zeros(opts.beta,1);
        error_nhc=zeros(opts.beta,1);
        counts=zeros(opts.beta,1);
        t1=clock;
        num = length(current_idx);
        for p=1:num
            h=current_idx(p);
            n = length(forecast_tensor(h).models);
            for t=1:size(forecast_tensor(h).X,4)
                for tau=1:opts.beta
                    if forecast_tensor(h).label(tau,t)>0
                        X=forecast_tensor(h).X(:,:,tau,t);
                        X_flag=forecast_tensor(h).X_flag(:,tau,t);
                        nhc=forecast_tensor(h).nhc(:,tau,t);
                        Y=forecast_tensor(h).Y(:,t+tau);
                        label=forecast_tensor(h).label(tau,t);
                        if label==0 || sum(X_flag)<opts.models_min || sum(nhc==-1000)>0
                            continue;
                        end
                        predict_mean=mean(X(:,X_flag),2);
                        predict_median=median(X(:,X_flag),2);
                        predict_online=forecast_tensor(h).predict(:,tau,t);
                        predict_nhc=forecast_tensor(h).nhc(:,tau,t);
                        error_mean(tau)=error_mean(tau)+get_distance(Y,predict_mean);
                        error_median(tau)=error_median(tau)+get_distance(Y,predict_median);
                        error_online(tau)=error_online(tau)+get_distance(Y,predict_online);
                        error_nhc(tau)=error_nhc(tau)+get_distance(Y,predict_nhc);
                        counts(tau)=counts(tau)+1;
                    end
                end
            end
        end
        error_mean=error_mean./counts/1.6;
        error_median=error_median./counts/1.6;
        error_online=error_online./counts/1.6;
        error_nhc=error_nhc./counts/1.6;

        if ii==1
            fprintf('Training trajectory data\n');
        elseif ii==2
            fprintf('Validation trajectory data\n');
        elseif ii==3
            fprintf('Training + Validation trajectory data\n');
        else
            fprintf('Testing trajectory data\n');
        end
        fprintf('$Ens_{mean}$ & ');
        for k=2:2:opts.beta
            fprintf('%.2f ',error_mean(k));
            if k<opts.beta
                fprintf(' & ');
            else
                fprintf(' \\\\\\hline');
            end
        end
        fprintf('\n');
        fprintf('$NHC$ & ');
        for k=2:2:opts.beta
            fprintf('%.2f ',error_nhc(k));
            if k<opts.beta
                fprintf(' & ');
            else
                fprintf(' \\\\\\hline');
            end
        end
        fprintf('\n');
        fprintf('$OMuLeT$ & ');
        for k=2:2:opts.beta
            fprintf('%.2f ',error_online(k));
            if k<opts.beta
                fprintf(' & ');
            else
                fprintf(' \\\\\\hline');
            end
        end
        fprintf('\n');
        error(ii) = mean(error_online(2:2:opts.beta));    
    end   
end
