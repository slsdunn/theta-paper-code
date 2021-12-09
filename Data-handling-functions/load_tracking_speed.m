function [speed, t_speed] = load_tracking_speed(sessionref, varargin)

 warning('off','MATLAB:load:variableNotFound')

% parse inputs
if nargin == 1
    t_neural = [];
else
    metadata = varargin{1};
    t_neural = varargin{2};
end

params   = get_parameters;  % get path and file names
datapath = fullfile(params.(sessionref.Species{1}).extDataPath, sessionref.ExtractedFolder{1});
trackfile = sessionref.TrackingFile{1};

if ~exist(fullfile(datapath,trackfile),'file')
    speed = [];
    t_speed = [];
    return
end
    
tracking = load(fullfile(datapath,trackfile),'speed','tstamps','SR','offmazeidx');

speed = tracking.speed;
if size(speed,1) == 1
    speed = transpose(speed);
end

if contains(sessionref.Species,'R')
    speed(tracking.offmazeidx(1:end-1)) = NaN;
end

t_speed = tracking.tstamps(1): 1/tracking.SR : tracking.tstamps(2);
t_speed = t_speed(1:end-1);

if size(t_speed,1) == 1
    t_speed = transpose(t_speed);
end

if ~isempty(t_neural) % upsample to neural SR
   speed = interp_tracking_to_neural_timeline(sessionref,metadata,speed,t_speed,t_neural);
end

end