function trialsTbl = load_trials_table(ref,varargin)

% varargin = 'raw' to get uncleaned trial data

if nargin == 2
    trials_type = varargin{1};
else 
    trials_type = 'clean';
end

params  = get_parameters;
species = ref.Species{1};

nsessions = size(ref,1);

trialscell = cell(nsessions,1);

for n = 1:nsessions

sessionref = ref(n,:);

trialspath = fullfile(params.(species).extDataPath,sessionref.ExtractedFolder{1});
trialsfile = strrep(sessionref.ExtractedFile{1},'CX','trials');
trialsFp    = fullfile(trialspath,trialsfile);

if ~exist(trialsFp,'file')
    trialsTbl = [];
    return
end

load(trialsFp,'trials')

trialscell(n,1) = {trials};
    
end

trialsTbl = vertcat(trialscell{:});


if contains(trials_type,'clean')
    if contains(species,'F')
        trialsTbl(trialsTbl.Set_off_early,:) = [];
    end
    if contains(species,'R')  % below indices found using flag_trials_with_sensor_errors_rat.m
        trialsTbl(trialsTbl.Sensor_return_activated,:)    = []; % remove trials when resp sensor only activated on way back from reward port
        trialsTbl(trialsTbl.Sensor_spurious_activation,:) = []; % remove trials with resp sensor error (activation when animal not at sensor)
    end
    trialsTbl(trialsTbl.Correct == -999,:)    = [];  % remove arduino errors (rat)
    trialsTbl(trialsTbl.Correct == -9999,:)   = [];  % remove aborted trials (rat)
    trialsTbl(trialsTbl.RespLocation == -1,:) = [];  % remove aborted trials (ferret)
    trialsTbl(trialsTbl.ReactionTime < 0,:)   = [];  % remove trials where RTs < 0 (ferret, 19 trials affected, mostly atropine sessions)
    trialsTbl(trialsTbl.Incl_Neural==0,:)     = [];  % use only trials with accompanying neural data 
    trialsTbl(trialsTbl.HoldTime<2500,:)      = [];  % remove low hold times (sometime introduced at start of sessions to encourage animal, esp for rats) 
    trialsTbl(isnan(trialsTbl.HoldStart),:)   = [];  % remove ferret trials with some info missing (eg from no wireless rec for that trial)
    trialsTbl(trialsTbl.HoldStart<0,:)        = [];  % remove ferret trials where hold start time < 0 (only seen once in ANI BlockA-14, other trials in that session seem fine) 

end


end