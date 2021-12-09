function [x,y,t] = load_tracking_location(sessionref, varargin)
 
warning('off','MATLAB:load:variableNotFound')

% parse inputs
if nargin == 1
    t_neural = [];
else
    metadata = varargin{1};
    t_neural = varargin{2};
end

params    = get_parameters;  % get path and file names
datapath  = fullfile(params.(sessionref.Species{1}).extDataPath, sessionref.ExtractedFolder{1});
trackfile = sessionref.TrackingFile{1};
    

if ~exist(fullfile(datapath,trackfile),'file')
    x = [];
    y = [];
    t = [];
    return
end

tracking = load(fullfile(datapath,trackfile),'x','y','tstamps','SR','offmazeidx');

x = tracking.x;
y = tracking.y;

if contains(sessionref.Species,'R')
    x(tracking.offmazeidx) = NaN;
    y(tracking.offmazeidx) = NaN;
end

t = tracking.tstamps(1): 1/tracking.SR : tracking.tstamps(2);

if size(t,1) == 1
    t = transpose(t);
end

if ~isempty(t_neural) % upsample to neural SR
    x = interp_tracking_to_neural_timeline(sessionref,metadata,x,t,t_neural);
    y = interp_tracking_to_neural_timeline(sessionref,metadata,y,t,t_neural);
end

end