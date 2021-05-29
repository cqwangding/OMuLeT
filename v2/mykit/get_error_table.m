function get_error_table(predict, Y, predict_flag, opts)
%GET_ERROR_TABLE Summary of this function goes here
%   Detailed explanation goes here
    fprintf('-------------------- Prediction error for different lead times --------------------\n');
    for i=1:numel(predict)
        if isempty(predict(i).name)
            continue;
        end
        fprintf('%s & ',predict(i).name);
        opts.error_type = 1;
        [error_mean, errors] = get_error_leadtime(predict(i).tra, Y, predict_flag, opts);
        errors = errors(2:2:8);
        for j=1:length(errors)
            fprintf('%.2f',errors(j));
            if j < length(errors)
                fprintf(' & ');
            end
        end
        fprintf('\\\\ \\hline\n');
    end
end
