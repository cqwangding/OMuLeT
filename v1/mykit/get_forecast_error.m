function get_forecast_error(opts)
% get ensemble median mean for AP and CP
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

    process = 'Get forecast error';
    fprintf('---------- %s / Begin ----------\n', process);
    
    filename=sprintf('forecast_tensor_%d_%d',opts.t,opts.beta);
    load(sprintf('%s/%s.mat',filename_all.data_dir,filename));
    load(sprintf('%s/hurricane.mat',filename_all.data_dir));
    load(sprintf('%s/model.mat',filename_all.data_dir));
    load(sprintf('%s/train_test_idx.mat',filename_all.data_dir));
    
    num_model = length(opts.models);
    
    error=zeros(num_model,opts.beta);
    count=zeros(num_model,opts.beta);
    
    forecast_tensor = forecast_tensor(test_idx);
    num = numel(forecast_tensor);
    
    t1=clock;
    for h=1:num
        if mod(h,20)==0
            t2=clock;
            fprintf('%s / Runs:%d/%d / Timeleft:%s\n', process, h, num, get_timeleft(h,num,t1,t2));
        end
        fc=forecast_tensor(h);
        [~,idx]=ismember(fc.models,opts.models);
        for t=1:size(fc.X,4)
            for tau=1:size(fc.X,3)
                X=fc.X(:,:,tau,t);
                X_flag=fc.X_flag(:,tau,t);
                Y=fc.Y(:,t+tau);
                label=fc.label(tau,t);
                if label && sum(X_flag)>0
                    dis=get_distance(X,Y)';
                    error(idx(X_flag),tau)=error(idx(X_flag),tau)+dis(X_flag);
                    count(idx(X_flag),tau)=count(idx(X_flag),tau)+1;
                end
            end
        end
    end
    error=error./count/1.6;
    for r=1:size(error,1)
        fprintf('%s\n',model(opts.models(r)).id);
        for c=2:2:size(error,2)
            fprintf('%.2f & ',error(r,c));
        end
        fprintf('\n');
    end
    
    fprintf('---------- %s / End ----------\n', process);
end
