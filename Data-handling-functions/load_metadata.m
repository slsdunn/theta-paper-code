function mdata = load_metadata(sessionref)

%
% loads metadata for a session
%
% inputs:
% sessionref = reference table of session to be extracted
%
% outputs:
% meta data for session (eg number of channels, SR, timestamps, bad
% channel index from cleaning, neural mapping info) 
%

params = get_parameters;

species = sessionref.Species{1};

mdataPath = fullfile(params.(species).extDataPath,sessionref.ExtractedFolder{1});
mdataFile = strrep(sessionref.ExtractedFile{1},'CX','metadata');

mdata = load(fullfile(mdataPath,mdataFile));
