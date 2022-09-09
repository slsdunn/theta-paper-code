function fullpath = get_full_path(root,fn)

% only works for files with unique filenames

filedir  = dir(fullfile(root, ['**\*' fn]));

if size(filedir,1) == 0
    disp(['no files found with name: ' fn '  in ' root])
    fullpath = [];
elseif size(filedir,1) == 1
    fullpath = fullfile(filedir.folder,fn);
else
    disp(['mutliple files found with name: ' fn])
    disp(['using: ' fullfile(filedir(1).folder,fn)])
    
    fullpath = fullfile(filedir(1).folder,fn);
    
end
end