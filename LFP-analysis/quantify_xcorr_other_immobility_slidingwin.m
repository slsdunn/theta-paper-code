function out = quantify_xcorr_other_immobility_slidingwin(cdata,speed,xpos,ypos,thresh)

%
% inputs:
% cdata = session neural data (nsamp x nchan)
% speed = session speed
% xpos, ypos = x y corrdinates of position data for session
% thresh = structure containing analysis parameters
%   incl spout locations for this session (row extracted from spoutcoord table, could also input structure)
% 
% outputs: out - struct, xcTbl for each neural channel
%
% Soraya Dunn 2021
%

badchans  = all(isnan(cdata));
ntotchans = size(cdata,2);

% find periods of "other" immobility (ie not at centre or peripheral spouts)
otherINDs = find_other_immobility_indices(speed,xpos,ypos,thresh);


celldata = cell(ntotchans,1);

for nc = 1:ntotchans
    if badchans(nc)
        continue
    end
    celldata2 = cell(size(otherINDs,1),1);
    for n = 1:size(otherINDs,1)
        
        starti = otherINDs(n,1)-1000; % take 1 s before for mov comparison
        if starti<1
            continue
        end
        endi   = otherINDs(n,2);
        
        % extract speed and neural data 
        immspeed = speed(starti:endi);
        immneu   = cdata(starti:endi,nc);
        
        [speed_epochs,~] = buffer(immspeed,thresh.win_samples,thresh.win_samples - thresh.sliding_win_step ,'nodelay'); % sliding window
        [neu_epochs,  ~] = buffer(immneu,  thresh.win_samples,thresh.win_samples - thresh.sliding_win_step ,'nodelay');
               
        nanidx = or(any(isnan(speed_epochs)),any(isnan(neu_epochs)));

        [~,xcTbl] = quantify_xcorr_epochs(neu_epochs, thresh.xcorr_freq_range,thresh.freqResolution);
        
        xcTbl(nanidx,:) = {NaN};
        xcTbl.Speed     = mean(speed_epochs)';
        xcTbl.WinStartT = -1 + (0:0.1:0.1*(size(xcTbl,1)-1))' ;  % time centred on imm start
        xcTbl.ImmIdx    = otherINDs(n,1)*ones(size(xcTbl,1),1);
        xcTbl.ImmNum    = n*ones(size(xcTbl,1),1);
        celldata2{n,1}  = xcTbl;
        
    end
    celldata{nc,1} = vertcat(celldata2{:});
end

for nchan = 1:ntotchans % convert to struct for output (can't seem to do it in parfor loop)
    out.(['C' num2str(nchan)]) = celldata{nchan,1};
end
end







function inds = find_other_immobility_indices(speed,xpos,ypos,thresh)

% find indices for immobile epochs longer than 1 second
immINDs = find_true_indices(speed<thresh.imm_speed,'>',thresh.min_imm_samp);

% find the x,y positions for the immobile epochs
immpos = NaN(size(immINDs,1),2);
for ni = 1:size(immINDs,1)
    immpos(ni,1) = mean(xpos(immINDs(ni,1):immINDs(ni,2)));
    immpos(ni,2) = mean(ypos(immINDs(ni,1):immINDs(ni,2)));
end

% using previously determined spout positions, identify immobile epochs
% within radius of spouts
[xspout.c, yspout.c] =  plot_circle(thresh.scoord.CentreSpout(1),thresh.scoord.CentreSpout(2),thresh.spoutradius,0);
immposidx.c = inpolygon(immpos(:,1),immpos(:,2),xspout.c,yspout.c);
for nsp = [10 11 12 1 2]
    [xspout.(['s' num2str(nsp)]),yspout.(['s' num2str(nsp)])] = plot_circle(thresh.scoord.(['Spout' num2str(nsp)])(1),thresh.scoord.(['Spout' num2str(nsp)])(2),thresh.spoutradius,0);
    immposidx.(['s' num2str(nsp)]) = inpolygon(immpos(:,1),immpos(:,2),xspout.(['s' num2str(nsp)]),yspout.(['s' num2str(nsp)]));
end

% other immobility is outside of spout locations
immposidx.other = ~(immposidx.c | immposidx.s10 | immposidx.s11 | immposidx.s12 | immposidx.s1 | immposidx.s2 );
inds = immINDs(immposidx.other,:);

end
