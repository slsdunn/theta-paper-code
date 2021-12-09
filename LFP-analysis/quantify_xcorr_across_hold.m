function  out = quantify_xcorr_across_hold(cdata,speed,t_neu,trials,thresh)

%
% inputs:
% cdata = session neural data (nsamp x nchan)
% speed = session speed
% t_neu = timestamp vector
% trials = trial table for this session
% thresh = structure containing analysis parameters
%
% outputs: out - struct, one field per channel containing xcTbl - each row = 1 second of hold period
%
% Soraya Dunn 2021
%


badchans  = all(isnan(cdata));
ntotchans = size(cdata,2);

celldata = cell(ntotchans,1);

for nc = 1:ntotchans
    if badchans(nc)
        continue
    end
    trialdata = cell(size(trials,1),1);
    for ntrial = 1:size(trials)
        
        trialholdstart  = trials.HoldStart(ntrial)-1; % 1 second before hold start to get run comparison
        if trialholdstart<1
            continue
        end
        trialholdend    = trials.HoldEnd(ntrial);
        trialholdstarti = interp1(t_neu,1:length(t_neu),trialholdstart,'nearest');
        trialholdendi   = interp1(t_neu,1:length(t_neu),trialholdend,'nearest');
        % extract speed and neural data 
        holdspeed = speed(trialholdstarti:trialholdendi);
        holdneu   = cdata(trialholdstarti:trialholdendi,nc);
        
        [speed_epochs,~] = buffer(holdspeed,thresh.win_samples,thresh.win_samples - thresh.sliding_win_step ,'nodelay'); % sliding window
        [neu_epochs,  ~] = buffer(holdneu,  thresh.win_samples,thresh.win_samples - thresh.sliding_win_step ,'nodelay');
               
        nanidx = or(any(isnan(speed_epochs)),any(isnan(neu_epochs)));

        [~,xcTbl] = quantify_xcorr_epochs(neu_epochs, thresh.xcorr_freq_range,thresh.freqResolution);
        
        xcTbl(nanidx,:) = {NaN};
        xcTbl.Speed     = mean(speed_epochs)';
        xcTbl.Trial     = ntrial*ones(size(xcTbl,1),1);
        xcTbl.WinStartT = -1 + (0:0.1:0.1*(size(xcTbl,1)-1))' ;  % time centred on hold start
        xcTbl.HoldTime  = trials.HoldTime(ntrial)*ones(size(xcTbl,1),1);
        xcTbl.Correct   = trials.Correct(ntrial)*ones(size(xcTbl,1),1);
        trialdata{ntrial,1} = xcTbl;
        
    end
    celldata{nc,1} = vertcat(trialdata{:});
end

for nchan = 1:ntotchans % convert to struct for output (can't seem to do it in parfor loop)
    out.(['C' num2str(nchan)]) = celldata{nchan,1};
end
end

