function get_forecast_online(opts)
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

    process = 'Run online multi-task forecasting';
    fprintf('---------- %s / Begin ----------\n', process);
    
    load(sprintf('%s/train_test_idx.mat',filename_all.data_dir));
    filename=sprintf('forecast_tensor_%d_%d',opts.t,opts.beta);
    load(sprintf('%s/%s.mat',filename_all.data_dir,filename));
    
    Omega = ones(length(opts.models),1); 
    t1=clock;
    idx_all=[train_idx,vali_idx,test_idx];
    num = length(idx_all);
    O_all=zeros(num,length(opts.models));
    for p=1:num
        h=idx_all(p);
        if mod(p,20)==0
            t2=clock;
            fprintf('%s / Runs:%d/%d / Timeleft:%s\n', process, p, num, get_timeleft(p,num,t1,t2));
        end
        n = length(forecast_tensor(h).models);
        [~, idx_models] = ismember(forecast_tensor(h).models, opts.models);
        O = Omega(idx_models);
        ratio=sum(O);
        O = O/ratio;
        U = zeros(n,1);
        V = zeros(n,opts.beta);
        L = zeros(opts.beta,opts.beta);
        L(1,1)=1;
        L(opts.beta,opts.beta)=1;
        for ii=2:opts.beta-1
            L(ii,ii)=2;
        end
        for ii=1:opts.beta-1
            L(ii,ii+1)=-1;
            L(ii+1,ii)=-1;
        end
        U_r = U;
        V_r = V;
        for t=1:size(forecast_tensor(h).X,4)
            U = U_r;
            V = V_r;
            for t_r=max(1,t-opts.beta):t-1
                idx=sum(forecast_tensor(h).X_flag(:,:,t_r),2);
                if sum(idx)==0
                    if t_r == max(1,t-opts.beta+1)
                        U_r=U;
                        V_r=V;
                    end
                    continue;
                end
                delta = zeros(opts.beta,1);
                M = zeros(n,n,opts.beta);
                M2 = zeros(n,n);
                C = zeros(n,opts.beta);
                C2 = zeros(n,1);
                for tau=1:opts.alpha
                    X_flag=forecast_tensor(h).X_flag(:,tau,t_r);
                    W=O+U+V(:,tau);
                    if forecast_tensor(h).label(tau,t_r)>0 && sum(X_flag)>=opts.models_min && sum(W(X_flag))>0
                        delta(tau)=1;
                        r=1/sum(W(X_flag));
                        X=forecast_tensor(h).X(:,:,tau,t_r);
                        X(:,~X_flag)=0;
                        L=forecast_tensor(h).label(tau,t_r);
                        Y=forecast_tensor(h).Y(:,L);
                        X=X*r;
                        X=[X(1,:); X(2,:)*cosd(Y(1))];
                        Y=[Y(1); Y(2)*cosd(Y(1))];
                        M(:,:,tau)=opts.gamma^tau*X'*X;
                        M2=M2+M(:,:,tau);
                        C(:,tau)=opts.gamma^tau*X'*(X*W-Y);
                        C2=C2+C(:,tau);
                    end
                end
                A=zeros((n+1)*(opts.beta+1),(n+1)*(opts.beta+1));
                b=zeros((n+1)*(opts.beta+1),1);
                A(1:n,1:n)=M2+opts.mu*eye(n);
                b(1:n)=-C2;
                for tau=1:opts.beta
                    A(1:n,tau*n+1:tau*n+n)=delta(tau)*M(:,:,tau);
                    A(tau*n+1:tau*n+n,1:n)=delta(tau)*M(:,:,tau);
                    if tau==1
                        A(tau*n+1:tau*n+n,tau*n+1:tau*n+n)=delta(tau)*M(:,:,tau)+(opts.omega+opts.eta+opts.nu)*eye(n);
                        A(tau*n+1:tau*n+n,tau*n+n+1:tau*n+2*n)=-opts.omega*eye(n);
                        b(tau*n+1:tau*n+n)=-delta(tau)*C(:,tau)-(opts.omega+opts.eta)*V_r(:,tau)+opts.omega*V_r(:,tau+1);
                    elseif tau==opts.beta
                        A(tau*n+1:tau*n+n,tau*n+1:tau*n+n)=delta(tau)*M(:,:,tau)+(opts.omega+opts.eta+opts.nu)*eye(n);
                        A(tau*n+1:tau*n+n,tau*n-n+1:tau*n)=-opts.omega*eye(n);
                        b(tau*n+1:tau*n+n)=-delta(tau)*C(:,tau)-(opts.omega+opts.eta)*V_r(:,tau)+opts.omega*V_r(:,tau-1);
                    else
                        A(tau*n+1:tau*n+n,tau*n+1:tau*n+n)=delta(tau)*M(:,:,tau)+(2*opts.omega+opts.eta+opts.nu)*eye(n);
                        A(tau*n+1:tau*n+n,tau*n+n+1:tau*n+2*n)=-opts.omega*eye(n);
                        A(tau*n+1:tau*n+n,tau*n-n+1:tau*n)=-opts.omega*eye(n);
                        b(tau*n+1:tau*n+n)=-delta(tau)*C(:,tau)-(2*opts.omega+opts.eta)*V_r(:,tau)+opts.omega*V_r(:,tau-1)+opts.omega*V_r(:,tau+1);
                    end
                end
                for tau=1:opts.beta+1
                    A(opts.beta*n+n+tau,tau*n-n+1:tau*n)=1;
                    A(tau*n-n+1:tau*n,opts.beta*n+n+tau)=-1;
                end            
                k=A\b;
                U=U+k(1:n);
                V=V+reshape(k(n+1:n*opts.beta+n),n,opts.beta);
                if t_r == max(1,t-opts.beta+1)
                    U_r=U;
                    V_r=V;
                end
            end
            % predict
            for tau=1:opts.beta
                X_flag=forecast_tensor(h).X_flag(:,tau,t);
                if forecast_tensor(h).label(tau,t)>0 && sum(X_flag)>=opts.models_min
                    W=O+U+V(:,tau);
                    r=1/sum(W(X_flag));
                    X=forecast_tensor(h).X(:,:,tau,t);
                    X(:,~X_flag)=0;
                    X=X*r;
                    forecast_tensor(h).predict(:,tau,t)=X*W;
                end
            end
        end
        % renew Omega
        [~, idx_models] = ismember(forecast_tensor(h).models, opts.models);
        O = O+opts.rho*U;
        O(O<=0)=0;
        O=O./sum(O);
        Omega(idx_models)=O*ratio;
        O_all(p,:)=Omega;
    end
    save(sprintf('%s/%s.mat',filename_all.data_dir,filename),'forecast_tensor');
end
