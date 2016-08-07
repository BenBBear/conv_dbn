%%% add paths to matlab %%%
global crbm_cache_path root
paths = strsplit(genpath('.'),':');
root = pwd;
for i=1:numel(paths)
    p = paths{i};
    if ~strcmp(p,'')
        p = strrep(p,'.', root);
        addpath(p);
    end
end

%%% ENV variables %%%
crbm_cache_path = strcat(root, '/demo/cache/');
