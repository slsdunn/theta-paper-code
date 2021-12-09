function out = quantify_xcorr_other_immobility(cdata,speed,xpos,ypos,thresh)

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

% find periods of "other" immobility (ie not at centre or peripheral spouts)
otherINDs = find_other_immobility_indices(speed,xpos,ypos,thresh);

% extract speed data in segments of uniform length
speedepochs = extract_other_epochs_from_data(speed,otherINDs,thresh);
speednan = any(isnan(speedepochs)); % ID NaNs

% extract neural data in segments from each channel
% then quantify xcorr
nchannels  = size(cdata,2);
xcTbls = cell(1,nchannels); % preallocate

parfor nchan = 1:nchannels
    
    otherepochs = extract_other_epochs_from_data(cdata(:,nchan),otherINDs,thresh);
    othernan    = any(isnan(otherepochs)); % ID NaNs
    nanidx      = or(speednan,othernan);
    
    otherepochs(:,nanidx) = [];
    speedepochs1 = speedepochs;
    speedepochs1(:,nanidx) = [];
    mspeed = mean(speedepochs1);
    
    [~,xcTbl] = quantify_xcorr_epochs(otherepochs,thresh.xcorr_freq_range,thresh.freqResolution);
    xcTbl.Speed = mspeed';
      
    xcTbls(1,nchan) = {xcTbl};
end

for nchan = 1:nchannels % convert to struct for output (can't seem to do it in parfor loop)
   out.(['C' num2str(nchan)]) = xcTbls{nchan}; 
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


function otherepochs = extract_other_epochs_from_data(chandat,otherINDs,thresh)

ntotsamp   = sum(otherINDs(:,3));
estnepochs = ceil(ntotsamp/thresh.win_samples);
nothers    = size(otherINDs,1);

otherepochs = NaN(thresh.win_samples,estnepochs); % preallocate

idx1 = 1;
for no=1:nothers % for each immobile epoch
    otherdat = chandat(otherINDs(no,1):otherINDs(no,2)); % extract data
    [otherepoch,~] = buffer(otherdat,thresh.win_samples,0); % put into segments of uniform length
    idx2 = idx1+size(otherepoch,2)-1;
    otherepochs(:,idx1:idx2) = otherepoch;  % add to preallocated output
    idx1 = idx2+1;
end

end