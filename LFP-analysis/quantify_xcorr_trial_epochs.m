function out = quantify_xcorr_trial_epochs(species,cdata,speed,ypos,t_neu,trials,thresh)


% find reward window starting point(sample number) using trial sensor data and speed trace
reward_win_start    = find_reward_window(species,trials,speed,ypos,t_neu,thresh.win_samples,thresh.win_seconds,thresh.imm_speed,thresh.R_maze_arm_ylim);
trials_with_rwd_idx = ~isnan(reward_win_start);
reward_win_start    = reward_win_start(trials_with_rwd_idx);

% extract trial epochs from speed trace (for hold and run extract all trials, for reward extract only reward windows)
hold_speed      = extract_epochs_from_signal(speed,t_neu,trials.HoldEnd-thresh.win_seconds-thresh.hold_shift,thresh.win_seconds);
hold_speed_nan  = any(isnan(squeeze(hold_speed(:,:,1))));
run_speed       = extract_epochs_from_signal(speed,t_neu,trials.RespTime-thresh.win_seconds,thresh.win_seconds);
run_speed_temp  = trim_epochs_based_on_RTs(squeeze(run_speed(:,:,1)),trials.ReactionTime,thresh.win_seconds,'start',0);
run_speed_nan   = any(isnan(squeeze(run_speed_temp)));
run_speed(:,:,1)= trim_epochs_based_on_RTs(squeeze(run_speed(:,:,1)),trials.ReactionTime,thresh.win_seconds,'start',NaN); % for reaction times <1 second
if ~all(trials_with_rwd_idx)
    rwd_speed       = zeros(size(hold_speed));
    rwd_speed(:,trials_with_rwd_idx,:) = extract_epochs_from_signal(speed,t_neu,t_neu(reward_win_start),thresh.win_seconds);
    rwd_speed_nan   = any(isnan(squeeze(rwd_speed(:,:,1))));
else
    rwd_speed = NaN(size(run_speed));
    rwd_speed_nan = true(size(run_speed_nan));
end
% metadata for output
out.ntrials        = size(trials,1);
out.ncorrecttrials = sum(trials.Correct);
out.nrewardwindows = sum(trials_with_rwd_idx);

switch species
    case 'F'
        trialdata    = trials(:,{'IDside','Level','Modality','TrialNum','CorrectionTrial','TargetLocation','HoldTime','HoldStart','HoldEnd','StimDuration','SNR','Difficulty','RespLocation','RespTime','ReactionTime','Correct'});
    case 'R'
        trialdata    = trials(:,{'ID','Level','Modality','TrialNum','TargetLocation','HoldTime','HoldStart','HoldEnd','StimDuration','SNR','Difficulty','RespLocation','RespTime','ReactionTime','Correct'});
end

nchan = size(cdata,2);
%preallocate
celldata = cell(nchan,1);

parfor (nc = 1:nchan)
    
    hold_neu    = extract_epochs_from_signal(cdata(:,nc),t_neu,trials.HoldEnd-thresh.win_seconds-thresh.hold_shift,thresh.win_seconds);
    hold_nanidx = any(isnan(squeeze(hold_neu(:,:,1)))) | hold_speed_nan;
    hold_neu(:,hold_nanidx,1) = 0;
    
    run_neu       = extract_epochs_from_signal(cdata(:,nc),t_neu,trials.RespTime-thresh.win_seconds,thresh.win_seconds);
    run_nanidx    = any(isnan(squeeze(run_neu(:,:,1)))) | run_speed_nan;
    run_neu(:,:,1)= trim_epochs_based_on_RTs(squeeze(run_neu(:,:,1)), trials.ReactionTime,thresh.win_seconds,'start',NaN);
    run_neu(:,run_nanidx,1) = 0;
    
    if ~all(trials_with_rwd_idx)
        rwd_neu = zeros(size(hold_neu));
        rwd_neu(:,trials_with_rwd_idx,:) = extract_epochs_from_signal(cdata(:,nc),t_neu,t_neu(reward_win_start),thresh.win_seconds);
        rwd_nanidx = any(isnan(squeeze(rwd_neu(:,:,1)))) | rwd_speed_nan;
        rwd_neu(:,rwd_nanidx,1) = 0;
    else
        rwd_neu    = NaN(size(run_neu));
        rwd_nanidx = true(size(run_nanidx));
    end
    remove_trial_idx = rwd_nanidx' | run_nanidx' | hold_nanidx';

    [~, xcTbl_rwd]  = quantify_xcorr_epochs(rwd_neu,thresh.refFreqRange,thresh.refFreqResolution);
      
    [~, xcTbl_run]  = quantify_xcorr_epochs(run_neu,thresh.refFreqRange,thresh.refFreqResolution);
    
    [~, xcTbl_hold]  = quantify_xcorr_epochs(hold_neu,thresh.refFreqRange,thresh.refFreqResolution);
    
    rwd_win_start = NaN(size(trials,1),1);
    rwd_win_start(trials_with_rwd_idx) = reward_win_start;
    hold_speed2 = hold_speed;
    hold_speed2(:,hold_nanidx,:) = 0;
    run_speed2 = run_speed;
    run_speed2(:,run_nanidx,:) = 0;
    rwd_speed2 = rwd_speed;
    rwd_speed2(:,rwd_nanidx,:) = 0;
    mholdspeed = mean(hold_speed2(:,:,1));
    mrunspeed  = mean(run_speed2(:,:,1));
    mrwdspeed  = mean(rwd_speed2(:,:,1));
    
    xcTbl_rwd.Properties.VariableNames = strcat('Rwd_',xcTbl_rwd.Properties.VariableNames);
    xcTbl_run.Properties.VariableNames = strcat('Run_',xcTbl_run.Properties.VariableNames);
    xcTbl_hold.Properties.VariableNames = strcat('Hold_',xcTbl_hold.Properties.VariableNames);
    fftTbl_rwd.Properties.VariableNames = strcat('Rwd_',fftTbl_rwd.Properties.VariableNames);
    fftTbl_run.Properties.VariableNames = strcat('Run_',fftTbl_run.Properties.VariableNames);
    fftTbl_hold.Properties.VariableNames = strcat('Hold_',fftTbl_hold.Properties.VariableNames);
    
    chanxcfft = table;
    chanxcfft.Hold_nan_idx  = hold_nanidx';
    chanxcfft.Run_nan_idx   = run_nanidx';
    chanxcfft.Rwd_nan_idx   = rwd_nanidx';
    chanxcfft.Rwd_win_idx   = trials_with_rwd_idx;
    chanxcfft.Rwd_win_start = rwd_win_start;
    chanxcfft.NaN_trial_idx = remove_trial_idx;
    chanxcfft.Hold_speed    = mholdspeed';
    chanxcfft.Run_speed     = mrunspeed';
    chanxcfft.Rwd_speed     = mrwdspeed';
    chanxcfft = horzcat(trialdata,chanxcfft,xcTbl_hold,xcTbl_run,xcTbl_rwd); %#ok<AGROW>
    
    celldata{nc,1} = chanxcfft;
    
end

for nc = 1:nchan % convert to struct for output (can't seem to do it in parfor loop)
    out.(['C' num2str(nc)]) = celldata{nc,1};
end

end





function datamat = trim_epochs_based_on_RTs(datamat,rts,win_seconds,which_bit_to_trim,replace_with)

trim_idx = rts<win_seconds;

if ~any(trim_idx)
    return;
end

epochs_to_trim = datamat(:,trim_idx);
trim_samples = ceil(1000*(win_seconds - rts(trim_idx)));

inputwin= size(datamat,1);

for n = 1:size(epochs_to_trim,2)
    tempepoch    = NaN(inputwin,1);
    tempepoch(:) = replace_with;
    
    switch which_bit_to_trim
        case 'start'
            epochdata = epochs_to_trim(trim_samples(n)+1:end,n);
            tempepoch(1:length(epochdata)) = epochdata;
        case 'end'
            epochdata = epochs_to_trim(1:end-trim_samples(n)-1:end,n);
            tempepoch(1:length(epochdata)) = epochdata;
    end
    epochs_to_trim(:,n) = tempepoch;
end


datamat(:,trim_idx) = epochs_to_trim;

end