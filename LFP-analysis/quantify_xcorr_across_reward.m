function  out = quantify_xcorr_across_reward(cdata,speed,xpos,ypos,t_neu,trials,thresh)

%
% inputs:
% cdata = session neural data (nsamp x nchan)
% speed = session speed
% xpos, ypos = x y corrdinates of position data for session
% t_neu = timestamp vector
% trials = trial table for this session
% thresh = structure containing analysis parameters
%   incl spout locations for this session (row extracted from spoutcoord table, could also input structure)
% 
% outputs: out - struct, one field per channel containing xcTbl - each row = 1 second of reward period
%
% Soraya Dunn 2021
%

atspout = find_indices_at_reward_spouts(xpos,ypos,thresh.scoord,thresh.spoutradius);

badchans  = all(isnan(cdata));
ntotchans = size(cdata,2);
spoutIDs  = [10,11,12,1,2];

celldata = cell(ntotchans,1);

parfor nc = 1:ntotchans
    if badchans(nc)
        continue
    end
    trialdata = cell(size(trials,1),1);
    for ntrial = 1:size(trials)
        
        trialrwdstart = trials.RespTime(ntrial);
        trialrwdwin   = interp1(t_neu,1:length(t_neu),trialrwdstart,'nearest');
        if trials.Correct
            spoutid = trials.TargetLocation(ntrial);
        else
            spoutid = trials.RespLocation(ntrial);
        end
        if ~any(ismember(spoutIDs,spoutid)) % skip trial if they've not reponded at the 5 rewarded spouts
            continue
        end
        trialxpos   = xpos(trialrwdwin);
        trialypos   = ypos(trialrwdwin);
        if isnan(trialxpos)||isnan(trialypos)
            continue
        end
        
        periodatspout = and(atspout.(['Spout' num2str(spoutid) '_indices'])(:,1) < trialrwdwin,atspout.(['Spout' num2str(spoutid) '_indices'])(:,2) > trialrwdwin);
        periodatspout = atspout.(['Spout' num2str(spoutid) '_indices'])(periodatspout,:);
        
        if isempty(periodatspout) % skip if x/y pos not at spout (found in one case where headstage has come off)
            continue
        end
        
        if periodatspout(3) < thresh.win_samples % skip trial if animal at stationary at spout for less time than analysis window
            continue
        end
        
        % extract speed and neural data for 
        rewardspeed = speed(periodatspout(1,1)-thresh.win_samples:periodatspout(1,2)); % shift back one window to get measure approaching run
        rewardneu   = cdata(periodatspout(1,1)-thresh.win_samples:periodatspout(1,2),nc);

        [rwdspeed_epochs,~] = buffer(rewardspeed,thresh.win_samples,thresh.win_samples - thresh.sliding_win_step ,'nodelay'); % sliding window
        [rwdneu_epochs,  ~] = buffer(rewardneu,  thresh.win_samples,thresh.win_samples - thresh.sliding_win_step ,'nodelay'); 
        
        nanidx = or(any(isnan(rwdspeed_epochs)),any(isnan(rwdneu_epochs)));

        rwdspeed  = mean(rwdspeed_epochs);
        [~,xcTbl] = quantify_xcorr_epochs(rwdneu_epochs, thresh.xcorr_freq_range,thresh.freqResolution);
        
        xcTbl(nanidx,:) = {NaN};
        xcTbl.Speed     = rwdspeed';
        xcTbl.Trial     = ntrial*ones(size(xcTbl,1),1);
        xcTbl.WinStartT = -1 + (0:0.1:0.1*(length(rwdspeed)-1))' ;  % time centred on rwd start
        xcTbl.Correct   = trials.Correct(ntrial)*ones(size(xcTbl,1),1);
        trialdata{ntrial,1} = xcTbl;
                      
    end
    celldata{nc,1} = vertcat(trialdata{:});
end

for nchan = 1:ntotchans % convert to struct for output (can't seem to do it in parfor loop)
   out.(['C' num2str(nchan)]) = celldata{nchan,1}; 
end
end



function atspout = find_indices_at_reward_spouts(xpos,ypos,scoord,spoutradius)

for n = [10,11,12,1,2] % spout ID labels
    [xc,yc] = plot_circle(scoord.(['Spout' num2str(n)])(1),scoord.(['Spout' num2str(n)])(2),spoutradius,0);
    atspout.(['Spout' num2str(n) '_circle'])(:,1)=xc;
    atspout.(['Spout' num2str(n) '_circle'])(:,2)=yc;
    atspout.(['Spout' num2str(n)]) = inpolygon(xpos,ypos,xc,yc);
    atspout.(['Spout' num2str(n) '_x'])=xpos;
    atspout.(['Spout' num2str(n) '_x'])(~atspout.(['Spout' num2str(n)]))=NaN;
    atspout.(['Spout' num2str(n) '_y'])=ypos;
    atspout.(['Spout' num2str(n) '_y'])(~atspout.(['Spout' num2str(n)]))=NaN;
    atspout.(['Spout' num2str(n) '_indices']) = find_true_indices(atspout.(['Spout' num2str(n)]));
end
end