function [configure_all, filename_all] = get_configure(filename, configures)

% Read configures from txt file into map format
str=fileread(filename);
if nargin > 1
    str=[str ' ' configures];
end
pat='\s*(\S+)\s*=\s*(\S+)\s*';
kvs=regexpi(str,pat,'tokens');
keys=[];
values=[];
for i=1:length(kvs)
    keys=[keys;kvs{i}(1)];
    values=[values;kvs{i}(2)];
end
parameter_map = containers.Map(keys,values);

% Read and generate filenames
filename_all.base_dir = '';
if isKey(parameter_map,'base_dir')
    filename_all.base_dir = parameter_map('base_dir');
end

filename_all.data_dir = '';
if isKey(parameter_map,'data_dir')
    filename_all.data_dir = parameter_map('data_dir');
end

% Read configure filenames
filename_all.hurricane = [filename_all.data_dir, '/harricane.mat'];
filename_all.model = [filename_all.data_dir, '/model.mat'];
filename_all.forecast = [filename_all.data_dir, '/forecast.mat'];
configure_all=[];

end
