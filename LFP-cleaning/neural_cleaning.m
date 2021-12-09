function [signal, metadata] = neural_cleaning(signal, thresholds,plotYN)

%
% signal = extracted signal in mV
% thresholds for cleaning (in get_parameters.m)
% plotYN = 1 to plot output of cleaning
%
% Soraya Dunn 2020
%

try
    
    warning('off','MATLAB:plot:IgnoreImaginaryXYPart')
    
    rawsignal = signal;
    nchan     = size(signal,2);
    
    %% step 1 - remove saturation points/lost signals and ID large artifacts that cross both + and - 2mV simultaneously
    idx.zidx = diff(signal) == 0;
    idx.zidx(end+1,:) = idx.zidx(end,:); % so same size as signal
    idx.zidx = extend_logical_indices(idx.zidx,100);
    
    idx.overallzIdx = any(idx.zidx');
    
    signal(idx.zidx) = NaN;
    
    if all(all(isnan(signal)))
        metadata.note = 'all channels NaN after first cleaning step';
        
        metadata.threshold   = thresholds;
        metadata.zIdx        = idx.overallzIdx;
        metadata.MaxMinIdx   = idx.overallMaxMinIdx;
        metadata.pxx1        = [];
        metadata.pxxClean    = [];
        metadata.fxx         = [];
        metadata.psdnfft     = [];
        metadata.psdIdx      = [];
        metadata.thetaP      = [];
        metadata.hz50P       = [];
        metadata.thetaPclean = [];
        
        metadata.ampThreshUsed = [];
        metadata.ampHistThresh = [];
        metadata.ampIdx        = [];
        metadata.meanAmp       = [];
        
        metadata.badChanIdx     = true(1,nchan);
        metadata.badChannels    = 1:nchan;
        metadata.removalIndices = [];
        metadata.cleanChanIdx   = false(1,32);
        metadata.cleanChannels  = [];
        metadata.pcCleaned      = 100*ones(1,nchan);
        metadata.nCleanChans    = 0;
        metadata.nBadChans      = nchan;
        metadata.nTotChans      = nchan;
        
        return
    end
   
    flt = filter_signal(signal,1000,'HP',1,2000);
    
    thresholds.minmaxWin = 20;
    thresholds.minmaxV   = 1.75;
    
    mmax = movmax(flt.signal,thresholds.minmaxWin);
    mmin = movmin(flt.signal,thresholds.minmaxWin);
    
    idx.mmax = mmax > thresholds.minmaxV;
    idx.mmin = mmin <-thresholds.minmaxV;
    
    idx.maxmin = and(idx.mmax,idx.mmin);    
    idx.overallMaxMinIdx = any(idx.maxmin');
    
    %% step 2 - remove bad channels using PSDs
    sig4psd = signal;
    
    idx.ampIdx4psd1 = abs(signal) > thresholds.ampThresh4psd1;  % really harsh thresholds to get best theta signal both across and within chans
    idx.ampidx4psd1 = extend_logical_indices(idx.ampIdx4psd1,500);
    
    sig4psd(idx.ampIdx4psd1) = NaN;
    
    totAmp4psd      = nanmean(abs(sig4psd),2);
    idx.ampIdx4psd2 = totAmp4psd > thresholds.ampThresh4psd2;
    idx.ampIdx4psd2 = extend_logical_indices(idx.ampIdx4psd2,500);
    
    sig4psd(idx.ampIdx4psd2,:) = NaN;
    
    badchans.prepsdidx = transpose(all(isnan(sig4psd))); % if total chan removed in prep for PSD, is a bad channel
    
    %nfft = 2^(nextpow2(4000));  % calculate PSDs
    win  = hanning(thresholds.psdnfft);
    [pxx,fxx] = pwelch(fillmissing(sig4psd,'linear','EndValues','nearest'),win,[],thresholds.psdnfft,1000);
    pxx = 10*log10(pxx);
    
    badchans.psdinfidx = transpose(all(isinf(pxx)));   % in cases where signal is all zeros, psd is inf- remove these
    
    psdIdx.theta1 = interp1(fxx,1:length(fxx),thresholds.thetaf1,'nearest');
    psdIdx.theta2 = interp1(fxx,1:length(fxx),thresholds.thetaf2,'nearest');
    psdIdx.hz49 = interp1(fxx,1:length(fxx),thresholds.hz50f1,'nearest');
    psdIdx.hz51 = interp1(fxx,1:length(fxx),thresholds.hz50f2,'nearest');
    
    
    [thetaP, badchans.badThetaPeaks] = find_area_under_peak(pxx,[psdIdx.theta1 psdIdx.theta2],plotYN);
    [hz50P, ~]  = find_area_under_peak(pxx,[psdIdx.hz49 psdIdx.hz51],plotYN);
    
    
    badchans.thetaPidx = transpose(thetaP < thresholds.thetaP);
    badchans.compPidx  = transpose(thetaP*thresholds.theta50ratio < hz50P);
    badchans.psdidx   =  badchans.badThetaPeaks | badchans.thetaPidx | badchans.prepsdidx | badchans.compPidx | badchans.psdinfidx;
    
    %badchans.hz50Pidx  = transpose(hz50P  > thresholds.hz50P);
    %badchans.psdidx   =  badchans.badThetaPeaks | badchans.thetaPidx | badchans.hz50Pidx | badchans.prepsdidx | badchans.compPidx | badchans.psdinfidx;
    
    
    pxxClean = pxx; % area peak method
    pxxClean(:,badchans.psdidx) = NaN;
    
    pxxBad = pxx;
    pxxBad(:,~badchans.psdidx) = NaN;
    
    signal(:,badchans.psdidx)     = NaN;
    
    %% step 3 - remove large artefacts common to all channels
    meanAmp = nanmean(abs(signal),2);
    ampHistThresh = find_thresholds_using_histogram([],meanAmp,[],thresholds.ampModeMult,'mode',0);
    
    ampThreshUsed = max([thresholds.ampThreshMin ampHistThresh.thresh]);  % use higher value out of two
    ampThreshUsed = min([thresholds.ampThreshMax ampThreshUsed]);         % and the lower value of these (ampThresh bounded between ~1.25 and 5 mV - in params)
    
    idx.ampIdx = meanAmp > ampThreshUsed;
    idx.ampIdx = extend_logical_indices(idx.ampIdx,100);
    
    signal(idx.ampIdx,:) = NaN;
    signal(idx.maxmin)   = NaN;
    
    %% collate metadata
    cleaningIdx = isnan(signal);
    
    removedChannels = all(isnan(signal));
    
    ncleanchans = sum(~removedChannels);
    nbadchans = sum(removedChannels);
    pcleaned = (sum(cleaningIdx)/size(cleaningIdx,1)) *100;
    
    disp(['n clean channels = ' num2str(ncleanchans)])
    disp(['Percent cleaned = ' num2str(round(pcleaned,3)) '%'])
    
    pxxClean2 = NaN(size(pxx));
    thetaP2   = NaN(size(thetaP));
    if ~all(removedChannels)
    [pxxClean2(:,~removedChannels),~] = pwelch(fillmissing(signal(:,~removedChannels),'linear','endvalues','nearest'),win,[],thresholds.psdnfft,1000); % recalc PSDs for clean channe;s
    pxxClean2    = 10*log10(pxxClean2);
    [thetaP2, ~] = find_area_under_peak(pxxClean2,[psdIdx.theta1 psdIdx.theta2],plotYN);
    end
    
    
    metadata.threshold   = thresholds;
    metadata.zIdx        = idx.overallzIdx;
    metadata.MaxMinIdx   = idx.overallMaxMinIdx;
    metadata.pxx1        = pxx;
    metadata.pxxClean    = pxxClean2;
    metadata.fxx         = fxx;
    metadata.psdnfft     = thresholds.psdnfft;
    metadata.psdIdx      = psdIdx;
    metadata.thetaP      = thetaP;
    metadata.hz50P       = hz50P;
    metadata.thetaPclean = thetaP2;
    
    metadata.ampThreshUsed = ampThreshUsed;
    metadata.ampHistThresh = ampHistThresh;
    metadata.ampIdx        = idx.ampIdx;
    metadata.meanAmp       = meanAmp;
    
    metadata.badChanIdx     = removedChannels;
    metadata.badChannels    = find(removedChannels);
    metadata.removalIndices = badchans;
    metadata.cleanChanIdx   = not(removedChannels);
    metadata.cleanChannels  = find(~removedChannels);
    metadata.pcCleaned      = pcleaned;
    metadata.nCleanChans    = ncleanchans;
    metadata.nBadChans      = nbadchans;
    metadata.nTotChans      = nchan;
    
    
    
    %% plot output if requested
    if plotYN
        
        % plot trace used for PSD calculation
        plot_trace_across_chans([],sig4psd);
        
        %% plot PSDs (area)
        [peakax,bgax] = neural_cleaning_psd_figure;
        delete_bgax_ticklabels(bgax)
        set(bgax,'Visible','off')
        
        axes(peakax(1))
        plot_lines_with_color_gradient(peakax(1),pxx,'x',fxx)
        xlim(peakax(1),[0 65])
        ylabel(peakax(1),'Power (dB/Hz)')
        xlabel(peakax(1),'Frequency (Hz)')
        title(peakax(1),'PSDs of all channels','Position',[0.5 0.9])
        
        chans = datasample(1:size(signal,2),4,'Replace',false);
        for n = 1:4
            axes(peakax(n+1))
            chn = chans(n);
            plot(gca,fxx,pxx(:,chn))
            plot(gca,[fxx(psdIdx.theta1) fxx(psdIdx.theta2)],[pxx(psdIdx.theta1,chn) pxx(psdIdx.theta2,chn)],'r--')
            text(gca,fxx(psdIdx.theta2)+1, pxx(psdIdx.theta1,chn)+5,[num2str(round(thetaP(chn),2)) ' dB'])
            
            plot(gca,[fxx(psdIdx.hz49) fxx(psdIdx.hz51)],[pxx(psdIdx.hz49,chn) pxx(psdIdx.hz51,chn)],'r--')
            text(gca,fxx(psdIdx.hz51)+1, pxx(psdIdx.hz49,chn)+5,[num2str(round(hz50P(chn),2)) ' dB'])
            xlim([0 60])
            set(gca,'ytick',[],'xtick',[])
            title(peakax(n+1),['Chan ' num2str(chans(n))],'Position',[0.7 0.8])
            set(peakax(n+1),'ytick',[],'xtick',[])
        end
        
        axes(peakax(6))
        scatter(peakax(6),thetaP,hz50P)
        scatter(peakax(6),thetaP(badchans.thetaPidx), hz50P(badchans.thetaPidx),'MarkerEdgeColor','r')
        scatter(peakax(6),thetaP(badchans.compPidx), hz50P(badchans.compPidx),'MarkerEdgeColor','r')
        scatter(peakax(6),thetaP(badchans.badThetaPeaks), hz50P(badchans.badThetaPeaks),'Marker','x','MarkerEdgeColor','r')
        scatter(peakax(6),thetaP(badchans.prepsdidx), hz50P(badchans.prepsdidx),'Marker','+','MarkerEdgeColor','r')
        scatter(peakax(6),thetaP(badchans.psdinfidx), hz50P(badchans.psdinfidx),'Marker','+','MarkerEdgeColor','c')


        plot(peakax(6),[thresholds.thetaP thresholds.thetaP],[-1 max(thetaP)],'r--')
        %plot(peakax(6),[-1 60],[thresholds.hz50P thresholds.hz50P],'r--')
        plot(peakax(6),[0 max([max(thetaP) max(hz50P)])],[0  max([max(thetaP) max(hz50P)])],'r--')
        title(peakax(6),'')
        xlabel(peakax(6),'theta power (dB)')
        ylabel(peakax(6),'50Hz power (dB)')
        axis tight
        
        axes(peakax(7))
        plot_lines_with_color_gradient(peakax(7),pxxClean,'x',fxx)
        xlim(peakax(7),[0 65])
        ylabel(peakax(7),'Power (dB/Hz)')
        xlabel(peakax(7),'Frequency (Hz)')
        title(peakax(7),'PSDs of clean channels','Position',[0.5 0.9])
        
        axes(peakax(8))
        plot_lines_with_color_gradient(peakax(8),pxxBad,'x',fxx)
        xlim(peakax(8),[0 65])
        ylabel(peakax(8),'Power (dB/Hz)')
        xlabel(peakax(8),'Frequency (Hz)')
        title(peakax(8),'PSDs of bad channels','Position',[0.5 0.9])
        
        font_size_and_color(gcf,12)
        
        
        %% plot all channel PSDs
        figure
        for n = 1:nchan
            if nchan == 32
                subplot(4,8,n,'next','add')
            elseif nchan == 16
                subplot(2,8,n,'next','add')
            end
            plot(gca,fxx,pxx(:,n))
            plot(gca,[fxx(psdIdx.theta1) fxx(psdIdx.theta2)],[pxx(psdIdx.theta1,n) pxx(psdIdx.theta2,n)],'r')
            text(gca,fxx(psdIdx.theta2)+1, pxx(psdIdx.theta1,n)+5,[num2str(round(thetaP(n),2)) ' dB'])
            
            plot(gca,[fxx(psdIdx.hz49) fxx(psdIdx.hz51)],[pxx(psdIdx.hz49,n) pxx(psdIdx.hz51,n)],'r')
            text(gca,fxx(psdIdx.hz51)+1, pxx(psdIdx.hz49,n)+5,[num2str(round(hz50P(n),2)) ' dB'])
            xlim([0 60])
            set(gca,'ytick',[],'xtick',[])
        end
        
        %% plot cleaned signal
        t = 0 : size(signal,1)-1;
        figure;
        axsig(1) = subplot(511,'next','add');
        axsig(2) = subplot(5,1,2:5,'next','add');
        
        % total mean amp
        abovethr = meanAmp;
        abovethr(~idx.ampIdx) = NaN;
        
        plot(axsig(1),t,meanAmp,'k')
        plot(axsig(1),[t(1) t(end)],[ampHistThresh.thresh ampHistThresh.thresh],'b--')
        plot(axsig(1),[t(1) t(end)],[thresholds.ampThreshMin thresholds.ampThreshMin],'b--')
        plot(axsig(1),[t(1) t(end)],[ampThreshUsed ampThreshUsed],'r--')
        plot(axsig(1),t,abovethr, 'p','color','r')
        ylabel(axsig(1),'mean abs(amplitude)')
        set(axsig(1),'XTick',[])
        
        sf  = plot_trace_across_chans(axsig(2),signal,'xvec',t);
        [~] =  plot_trace_across_chans(axsig(2),rawsignal,'xvec',t,'scalefactor',sf, 'col',[1 0 0 0.3]);
        chH = get(axsig(2),'Children');
        set(axsig(2),'Children',flipud(chH))
        linkaxes(axsig,'x')
        
        % plot cleaned signal (but only clean channels)
        figure;
        axsig(1) = subplot(611,'next','add');
        axsig(2) = subplot(612,'next','add');
        axsig(3) = subplot(6,1,3:6,'next','add');
        
        % total mean amp
        abovethr = meanAmp;
        abovethr(~idx.ampIdx) = NaN;
        
        plot(axsig(1),t,meanAmp,'k')
        plot(axsig(1),[t(1) t(end)],[ampHistThresh.thresh ampHistThresh.thresh],'b--')
        plot(axsig(1),[t(1) t(end)],[thresholds.ampThreshMin thresholds.ampThreshMin],'b--')
        plot(axsig(1),[t(1) t(end)],[ampThreshUsed ampThreshUsed],'r--')
        plot(axsig(1),t,abovethr, 'p','color','r')
        ylabel(axsig(1),'mean abs(amplitude)')
        set(axsig(1),'XTick',[])
        
        plot(axsig(2),t,idx.overallzIdx,'g')
        plot(axsig(2),t,idx.overallMaxMinIdx,'b')
        legend(axsig(2),{'zeros','maxmin'})
        
        rawsignal(:,removedChannels) = NaN;
        
        sf  = plot_trace_across_chans(axsig(3),signal,'xvec',t);
        [~] =  plot_trace_across_chans(axsig(3),rawsignal,'xvec',t,'scalefactor',sf, 'col',[1 0 0 0.3]);
        chH = get(axsig(3),'Children');
        set(axsig(3),'Children',flipud(chH))
        linkaxes(axsig,'x')
        
        
        %% replot PSDs
        plot_lines_with_color_gradient([],pxxClean2,'x',fxx)
    end
    
catch err
    err
    parseError(err)
    keyboard
end
end

function [peakP, badidx] = find_area_under_peak(pxx,fidx, plotYN)

peaks  = pxx(fidx(1):fidx(2),:);
nchan  = size(pxx,2);
base   = NaN(size(peaks,1),nchan); 

for n = 1 :nchan
    base(:,n) = linspace(peaks(1,n),peaks(end,n),size(peaks,1));
end

totP  = trapz(peaks);
baseP = trapz(base);
peakP = totP - baseP;

% find bad peaks (where the peak is shifted too far right eg KIW B10-86,118)
peakNorm = peaks - peaks(1,:);
peakNorm(peakNorm < 0) = 0;

half1 = peakNorm(1:round(0.5*size(peakNorm,1)),:);
half2 = peakNorm(round(0.5*size(peakNorm,1))+1:end,:);

half1P = trapz(half1);
half2P = trapz(half2);

badidx = transpose(half1P*2 < half2P);


if plotYN
    
    figure
    plot(peakNorm)
    figure
    nrow = nchan/8;
    for n = 1:nchan
        subplot(nrow,8,n,'next','add')
        plot(peaks(:,n))
        plot(base(:,n))
        title([num2str(round(peakP(n),2)) ' dB'])
    end
end

end
% 
% function [peakP, badidx] = find_area_under_peak(pxx,fidx,plotYN)
% 
% peak = pxx(fidx(1):fidx(2),:);
% peakNorm = peak - peak(1,:);
% peakNorm(peakNorm < 0) = 0;
% 
% endpoint = peakNorm(end,:);
% maxpoint = max(peakNorm);
% 
% badidx = transpose(endpoint == maxpoint);
% 
% peakP = trapz(peakNorm);
% 
% if plotYN
% figure
% plot(peakNorm)
% end
% end