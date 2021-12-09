function dataOut = load_neural_mapped(sessionref, metadata, channel_desc, sig_type)

% outputs columnwise LFP data
%
% inputs:
% sessionref - row of reference table
% metadata structure
% channel_desc = 'all', 'CL', 'DG'
% sig_type = 'extsiganl', 'cleansignal'
%

% Soraya Dunn 2020


params = get_parameters;

map = metadata.map;
if contains(sig_type,'cleansignal')
    map(logical(metadata.badChanMapped)) = NaN; % flags bad channel for load_neural_data
end

if isnumeric(channel_desc)
    channels_to_load = map(channel_desc);
else
    switch channel_desc
        case 'all'
            channels_to_load = map;
        case 'oCL'
            channels_to_load = map(params.oCL.(sessionref.IDside{1}));
        case 'rCL'
            channels_to_load = map(params.rCL.(sessionref.IDside{1}));
    end
end

dataOut = load_neural_data(sessionref, channels_to_load, sig_type);