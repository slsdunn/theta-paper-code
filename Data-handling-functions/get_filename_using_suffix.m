function fn = get_filename_using_suffix(folderpath,suffix)

if iscell(folderpath)
    folderpath = folderpath{1};
end

fdir = dir(fullfile(folderpath,['*' suffix '.mat']));
fn = fdir.name;