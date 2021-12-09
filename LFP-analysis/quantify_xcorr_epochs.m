function [XC, xcTbl] = quantify_xcorr_epochs(data_epochs,freq_range,freq_resolution)
try
nepochs   = size(data_epochs,2);
winlength = size(data_epochs,1);

% preallocate
XC        = NaN(winlength*2-1,nepochs);
mindist   = NaN(nepochs,1);
mindisti  = NaN(nepochs,1);
xcvals    = NaN(3,nepochs);
xcIdx     = NaN(3,nepochs);
peak1rangeED     = NaN(nepochs,1);
normpeak1rangeED = NaN(nepochs,1);
skipped = false(nepochs,1);
% create referene sine xcorr bank
ref_freqs = freq_range(1):freq_resolution:freq_range(2);
[refXC, refED, refRange,refP1range, refT1range, refT2range] = create_sine_ref_xcorrs(ref_freqs,size(data_epochs,1));

for n = 1:nepochs
    
    dataepoch = data_epochs(~isnan(data_epochs(:,n)),n);
    
    if numel(dataepoch)==1 % skip if only 1 data point
        mindisti(n) = 1; % so doesn't throw error below
        skipped(n)  = true;
        continue
    end
    
    xc = xcorr(dataepoch,dataepoch); % calc autocorrelation
    xc = xc ./ max(xc); 
    XC(1:length(xc),n) = xc;
     
    %% eucdist method 
     % find matching sine with min ED
    XC1 = repmat(XC(:,n),1,size(refXC,2));
    ED  = naneucdist(XC1',refXC');
    normED = ED./refED';
    [md,mi]= min(normED); 

    mindist(n)  = md;
    mindisti(n) = mi;
    
    % find peak range of data autocorr
    % find value at peak max
    [peakmax,peakmaxi] = max(XC1(refP1range(1,mi):refP1range(2,mi)));
    peakmaxi = peakmaxi + refP1range(1,mi)-1;
    % find min in trough before peak
    [trough1min,trough1mini] = min(XC1(refT1range(1,mi):refT1range(2,mi)));
    trough1mini = trough1mini + refT1range(1,mi)-1;   
    % find min in trough after peak
    [trough2min,trough2mini] = min(XC1(refT2range(1,mi):refT2range(2,mi)));
    trough2mini = trough2mini + refT2range(1,mi)-1;   
    
    xcvals(1,n) = peakmax;
    xcvals(2,n) = trough1min;
    xcvals(3,n) = trough2min;
    
    xcIdx(1,n) =  peakmaxi;
    xcIdx(2,n) =  trough1mini;
    xcIdx(3,n) =  trough2mini;
    
    peak1rangeED(n) = peakmax - mean([trough1min,trough2min]);
    normpeak1rangeED(n) = peak1rangeED(n)/refRange(mi);   % normalise by peakrange of reference sine

    
end


% table output
xcTbl = table;

xcTbl.EDmin         = mindist;
xcTbl.freq          = ref_freqs(mindisti)';
xcTbl.freq(skipped) = NaN;
xcTbl.peak1         = xcvals(1,:)';
xcTbl.peak1i        = xcIdx(1,:)';
xcTbl.trough1       = xcvals(2,:)';
xcTbl.trough1i      = xcIdx(2,:)';
xcTbl.trough2       = xcvals(3,:)';
xcTbl.trough2i      = xcIdx(3,:)';
xcTbl.peakrange     = peak1rangeED;
xcTbl.peakrangenorm = normpeak1rangeED;


catch err
    parseError(err)
    keyboard
end


end



function [refXC, refED, refRange, refP1range, refT1range, refT2range] = create_sine_ref_xcorrs(ref_freqs,datsize)

reft = 0:1/1000:(datsize-1)/1000;

refXC      = NaN(length(reft)*2-1,length(ref_freqs)); % preallocate
refRange   = NaN(numel(ref_freqs),1);
refPTIdx   = NaN(3,numel(ref_freqs));
refP1range = NaN(2,numel(ref_freqs));
refT1range = NaN(2,numel(ref_freqs));
refT2range = NaN(2,numel(ref_freqs));

for n = 1:numel(ref_freqs) % for each frequency
    refsig = sin(2*pi*ref_freqs(n)*reft);  % calc sine
    refxc = xcorr(refsig,refsig);          % autocorrelogram of sine
    refxc = refxc./max(refxc);
    refXC(:,n) = refxc;
    
    %% find peak range for reference sine autocorrelogram
    [maxP,minP] = findMinMax(refxc,0.05,'fixed');   % find extrema

    midpeaki = find(maxP(:,1)==datsize);  % find peak/troughs of interest (first peak after centre)
    peak1 = maxP(midpeaki+1,:);
    trough1i = find(minP(:,1)<peak1(1));
    trough1i = trough1i(end);
    trough2i = find(minP(:,1)>peak1(1));
    trough2i = trough2i(1);
    trough1 = minP(trough1i,:);
    trough2 = minP(trough2i,:);
    
    refRange(n) = peak1(2) - mean([trough1(2),trough2(2)]); % find peak range for sine autocorrelogram
    
    refPTIdx(1,n) = trough1(1);
    refPTIdx(2,n) = peak1(1);
    refPTIdx(3,n) = trough2(1);   
    
    %% find regions over which max/min of data autocorr will be found
    interceptpoints = zero_crossings(refxc);
    belowt1 =interceptpoints(interceptpoints < trough1(1));
    abovet2 =interceptpoints(interceptpoints > trough2(1));
    abovep1 =interceptpoints(interceptpoints > peak1(1));
    belowp1 =interceptpoints(interceptpoints < peak1(1));
    
    refP1range(1,n) = round(belowp1(end));
    refP1range(2,n) = round(abovep1(1));
    refT1range(1,n) = round(belowt1(end));
    refT1range(2,n) = round(belowp1(end));
    refT2range(1,n) = round(abovep1(1));
    refT2range(2,n) = round(abovet2(1));
    
end
refED = vecnorm(refXC); % calc euc. dist of each ref sine AC
end