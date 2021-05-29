function get_hurricane_split(opts)
%READKML Summary of this function goes here
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

    process = 'Split hurricane to train set and test set';
    fprintf('---------- %s / Begin ----------\n', process);
    
    load(sprintf('%s/hurricane.mat',filename_all.data_dir));
    num=numel(hurricane);
    start_time=extractfield(hurricane,'start_time');
    location=extractfield(hurricane,'location');
    [start_time,idx]=sort(start_time);
    train_idx=false(1,num);
    t1=-1;
    t2=-1;
    for h=1:num
        if start_time(h)>=opts.time_train && t1==-1
            t1=h;
        elseif start_time(h)>=opts.time_vali && t2==-1
            t2=h;
        end
    end
    train_idx=idx(1:t1-1);
    vali_idx=idx(t1:t2-1);
    test_idx=idx(t2:end);
    if opts.location==1
        idx=location(train_idx)==1;
        train_idx=train_idx(idx);
        idx=location(test_idx)==1;
        test_idx=test_idx(idx);
        idx=location(vali_idx)==1;
        vali_idx=vali_idx(idx);
    elseif opts.location==2
        idx=location(train_idx)==2;
        train_idx=train_idx(idx);
        idx=location(test_idx)==2;
        test_idx=test_idx(idx);
        idx=location(vali_idx)==2;
        vali_idx=vali_idx(idx);
    end
    fprintf('Training:%d Validation:%d Testing:%d\n', length(train_idx), length(vali_idx), length(test_idx));
    save(sprintf('%s/train_test_idx.mat',filename_all.data_dir),'train_idx','test_idx','vali_idx');

    fprintf('---------- %s / End ----------\n', process);
end
