function out = quantify_xcorr_speed(cdata,speed,thresh)

nsegments    = floor(size(cdata,1)/thresh.win_samples);
speedepochs  = reshape(speed(1:thresh.win_samples*nsegments),thresh.win_samples,nsegments);
mspeedepochs = mean(speedepochs);
speednanidx  = isnan(mspeedepochs);

nchan = size(cdata,2);
%preallocate
celldata = cell(nchan,1);
parfor (nc = 1:nchan)
    
    dataepochs = reshape(cdata(1:thresh.win_samples*nsegments,nc),thresh.win_samples,nsegments);
    nanidx     = any(isnan(dataepochs)) | speednanidx;
    dataepochs(:,nanidx) = [];
    mspeed     = mspeedepochs(~nanidx);
    
    datahilb = hilbert(dataepochs);
    powervar = var(abs(datahilb));
    
    [~, xcTbl]  = quantify_xcorr_epochs(dataepochs,thresh.refFreqRange,thresh.refFreqResolution);
       
    chanxc = table;
    chanxc.Speed    = mspeed';
    chanxc.PowerVar = powervar';
    chanxc = horzcat(chanxc,xcTbl); %#ok<AGROW>
    
    celldata{nc,1} = chanxc;
end
for nc = 1:nchan % convert to struct for output (can't seem to do it in parfor loop)
    out.(['C' num2str(nc)]) = celldata{nc,1};
end
end