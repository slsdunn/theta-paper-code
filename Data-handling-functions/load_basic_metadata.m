function metadata = load_basic_metadata(sessionref)

%
% loads meta from a session
%
% inputs:
% sessionref = table row of session to be extracted 
%
%

try
    warning('off','MATLAB:load:variableNotFound')

    params   = get_parameters;  % get path and file names
    datapath = fullfile(params.(sessionref.Species{1}).extDataPath, sessionref.ExtractedFolder{1});
    datafile = sessionref.ExtractedFile{1};
    datafile = strrep(datafile,'CX','C1');
    datafp   = fullfile(datapath,strrep(datafile,'CX','C1'));

    params2load = {'ID','recside','rectype','extfile','extfolder','SR','units','timestamps','time_units','nChannelsTotal','siglength', 'inputRange_mV', 'session_tstamps','minT'};

    metadata = load(datafp,params2load{:});  % load metadata for this session

catch err
    parseError(err)
    keyboard
end
end