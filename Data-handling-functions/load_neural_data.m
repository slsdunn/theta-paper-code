function dataOut = load_neural_data(sessionref, channels_to_load, sig_type)

%
% loads neural traces of particular channels from a session
% (can be extracted or cleaned signal)
%
% inputs:
% sessionref = table of session to be extracted 
% channels_to_load = vector of channels to load eg 1:32
% sig_type = 'extsignal', 'cleansignal'
%
% outputs:
% dataOut = matrix of neural data
%

warning('off','MATLAB:load:variableNotFound')

try
    
    params   = get_parameters;  % get path and file names
    datapath = fullfile(params.(sessionref.Species{1}).extDataPath, sessionref.ExtractedFolder{1});
    datafile = sessionref.ExtractedFile{1};
    
    load(fullfile(datapath,strrep(datafile,'CX','C1')),'siglength');  % load siglength for this session
    
    nchans = numel(channels_to_load);
    
    dataOut = NaN(siglength,nchans); % preallocate
    
    for n = 1 : nchans
        
        chan = channels_to_load(n);
        
        if isnan(chan) % marker for bad channel, leave channel as NaNs
            continue
        else
            
            chanfile = strrep(datafile,'CX', ['C' num2str(chan)]);
            chandata = load(fullfile(datapath,chanfile), sig_type);
                                  
            signal   = chandata.(sig_type);
            if isempty(signal)
                continue
            end
            
            if size(signal,1) == 1  % shouldn't be necessary but just in case
                signal = transpose(signal);
            end           
        end
        
        dataOut(:,n) = signal;
    end
    
catch err
    parseError(err)
    keyboard
end
end
