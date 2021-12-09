function [ifreq,iphase,ipower,extrema,det_range] = calculate_peak_trough_signal_parameters(signalIn,thresh_pc,t)

%
% input
% signalIn  = data matrix, nSamp (rows) by nChan (cols)
% thresh_pc = value between 0-1, used in findMinMax to define yvalue range over which local extrema are detected (as % of signal median)
%		      chosen empirically, I typically use 0.25
% t = data time series
%
% output:
% instantaneous frequeny, phase, power, same format as signalIn
% extrema = cell array containing matrix of sample, value, designation
%           (1=peak, -1=trough) of extrema in each channel
% det_range = array of amplitude ranges used for each chan (as calc'd using thresh_pc)
%
% Soraya Dunn 2017
%

try
    
    if size(t,1) == 1
        t = transpose(t);
    end
    
    nsamps = size(signalIn,1);
    nchans = size(signalIn,2);
    
    ifreq     = NaN(nsamps,nchans);
    iphase    = NaN(nsamps,nchans);
    ipower    = NaN(nsamps,nchans);
    extrema   = cell(1,nchans);
    det_range = NaN(1,nchans);
    
    for n = 1:nchans
        
        signal = signalIn(:,n);
        nanidx = isnan(signal);
        
        if all(nanidx)
            continue
        end
        
        [peaks,troughs,minChange] = findMinMax(signal, thresh_pc);
        
        extrema_cleaned = cleanPeaksTroughs(signal,peaks,troughs);
        
        % [ind,t0,s0,~,~] = crossing(signal,t,0,'linear');
        %
        % z(:,1) = ind;
        % z(:,2) = s0;
        % z(:,3) = zeros(size(t0));
        % z(:,4) = t0;
        [instfreq,instphase, instpower] = calc_peak_trough_params(extrema_cleaned,t, nanidx);
        
        ifreq(:,n)     = instfreq(:,1);
        iphase(:,n)    = instphase(:,1);
        ipower(:,n)    = instpower(:,1);
        extrema{1,n}   = extrema_cleaned;
        det_range(1,n) = minChange;
    end
    
catch err
    parseError(err)
    keyboard
end

end


function extrema = cleanPeaksTroughs(signal,peaks,troughs)
%% identify any peak-peak/trough-trough and see if any missing
extrema(:,1) = [peaks(:,1); troughs(:,1)];
extrema(:,2) = [peaks(:,2); troughs(:,2)];
extrema(:,3) = [ones(size(peaks,1),1);-1*ones(size(troughs,1),1)];

remove_negative_peaks = and(extrema(:,2)<0,extrema(:,3)==1);
remove_pos_troughs    = and(extrema(:,2)>0,extrema(:,3)==-1);
extrema(or(remove_negative_peaks,remove_pos_troughs),:) = [];

extrema = sortrows(extrema);

hasbadpeaks =1; % 'bad peaks' is defined as two peaks or two troughs next to each other

while hasbadpeaks == 1
    
    baddetection = find(diff(extrema(:,3))==0); % check if two peaks/troughs are next to each other
    
    if isempty(baddetection)
        hasbadpeaks = 0;
        continue
    end
    
    baddet = extrema(baddetection(1):baddetection(1)+1,:);
    if all(baddet(:,3)==1) % two peaks detected
        seg = signal(baddet(1,1):baddet(2,1));
        [missed, missedi] = min(seg); % find min between them
        missedtype = -1;
        missedi = baddet(1,1) + missedi -1;
        if missed > 0 % just take max of the two peaks
            [~,which_to_remove] = min(baddet(:,2));
            extrema(extrema(:,1)==baddet(which_to_remove,1),:)=[];
            continue
        end
    elseif all(baddet(:,3) == -1) % two troughs detected
        seg = signal(baddet(1,1):baddet(2,1));
        [missed, missedi] = max(seg);
        missedtype = 1;
        missedi = baddet(1,1) + missedi -1;
        if missed < 0
            [~,which_to_remove] = max(baddet(:,2));
            extrema(extrema(:,1)==baddet(which_to_remove,1),:)=[];
            missedtype = [];
            missed = [];
            missedi = [];
            continue
        end
    else
        keyboard
    end
    row_no=baddetection(1)+1; %insert missed peak
    extrema(1:row_no-1,:) = extrema(1:row_no-1,:);
    tp =extrema(row_no:end,:);
    extrema(row_no,:)=[missedi,missed,missedtype];
    extrema(row_no+1:end+1,:) =tp;
end


end

function [instfreq,instphase,instpower] = calc_peak_trough_params(extrema,t,nanidx)

peaks = extrema(extrema(:,3)==1,:);
troughs = extrema(extrema(:,3)==-1,:);

% find time and frequency of peaks and troughs
peakt   = t(peaks(:,1));
trought = t(troughs(:,1));
peakf   = 1./diff(peakt);
troughf = 1./diff(trought);
%zerof   = 1./diff(t0);

% use midpoints between peak and trough as freq t to aviod lag
for npi = 1:size(peaks,1)
    if npi<size(peaks,1)
        fpeaksi(npi,1) = round(peaks(npi,1) + 0.5*(peaks(npi+1,1)-peaks(npi,1)));
    end
end
for nti = 1:size(troughs,1)
    if nti<size(troughs,1)
        ftroughsi(nti,1) = round(troughs(nti,1) + 0.5*(troughs(nti+1,1)-troughs(nti,1)));
    end
end

peakst = t(fpeaksi);
troughst = t(ftroughsi);

%zeroF = (interp1(t0(1:end-1),zerof,t)) ./2;
peaksF   = interp1(peakst,peakf,t);
troughsF = interp1(troughst,troughf,t);
recon_f  = nanmean([peaksF,troughsF],2);

instfreq = [recon_f,peaksF,troughsF];


% for signal power
peaksinterp   = interp1(peakt,peaks(:,2),t);
troughsinterp = interp1(trought,troughs(:,2),t);

% for phase
extrema(extrema(:,3)==1,4) = 180;
instphase = NaN(size(t));

for np = 1:size(extrema,1)-1
    p1 = extrema(np,4);
    p2 = extrema(np+1,4);
    i1 = extrema(np,1);
    i2 = extrema(np+1,1);
    if p1 == 0
        ip = interp1([i1 i2],[p1 p2],i1:i2);
    elseif p1 == 180
        ip = interp1([i1 i2],[p1 360],i1:i2);
    end
    instphase(i1:i2) = ip;  
end

% remove potion where signal = NaN
peaksinterp(nanidx)   = NaN;
troughsinterp(nanidx) = NaN;
A = nanmean([abs(peaksinterp),abs(troughsinterp)],2);

instpower(:,1) = A.^2;
instpower(:,2) = A;
instpower(:,3) = peaksinterp;
instpower(:,4) = troughsinterp;

instfreq(nanidx,:) = NaN;
instphase(nanidx)  = NaN;
end