function TDT_MCS_neural_cleaning_plot_output(sessionref)

    try
    mdata   = load_metadata(sessionref);
    catch
    mdata   = load_basic_metadata(sessionref);
    end
    extdata = load_neural_data(sessionref,1:mdata.nChannelsTotal,'extsignal');
    cdata   = load_neural_data(sessionref,1:mdata.nChannelsTotal,'cleansignal');
    
    params   = get_parameters;  % get path and file names
    %datapath = fullfile(params.(sessionref.Species{1}).extDataPath, sessionref.ExtractedFolder{1});
    datafile = sessionref.ExtractedFile{1};
    cleaningfile   = strrep(datafile,'CX','neuralCleaningInfo');
    cleaningpath = fullfile(params.F.preprocessingPath,'neural_cleaning_info');
    cleaningfp = fullfile(cleaningpath,cleaningfile);
    
    cleaningInfo = load(cleaningfp);  % load cleaningInfo for this session




%% plot PSDs (area)
nchan = size(extdata,2);
[peakax,bgax] = neural_cleaning_psd_figure;
delete_bgax_ticklabels(bgax)
set(bgax,'Visible','off')

axes(peakax(1))
plot_lines_with_color_gradient(peakax(1),cleaningInfo.pxx1,'x',cleaningInfo.fxx)
xlim(peakax(1),[0 65])
ylabel(peakax(1),'Power (dB/Hz)')
xlabel(peakax(1),'Frequency (Hz)')
title(peakax(1),'PSDs of all channels','Position',[0.5 0.9])

chans = datasample(1:size(extdata,2),4,'Replace',false);
for n = 1:4
    axes(peakax(n+1))
    chn = chans(n);
    plot(gca,cleaningInfo.fxx,cleaningInfo.pxx1(:,chn))
    plot(gca,[cleaningInfo.fxx(cleaningInfo.psdIdx.theta1) cleaningInfo.fxx(cleaningInfo.psdIdx.theta2)],[cleaningInfo.pxx1(cleaningInfo.psdIdx.theta1,chn) cleaningInfo.pxx1(cleaningInfo.psdIdx.theta2,chn)],'r')
    text(gca,cleaningInfo.fxx(cleaningInfo.psdIdx.theta2)+1, cleaningInfo.pxx1(cleaningInfo.psdIdx.theta1,chn)+5,[num2str(round(cleaningInfo.thetaP(chn),2)) ' dB'])
    
    plot(gca,[cleaningInfo.fxx(cleaningInfo.psdIdx.hz49) cleaningInfo.fxx(cleaningInfo.psdIdx.hz51)],[cleaningInfo.pxx1(cleaningInfo.psdIdx.hz49,chn) cleaningInfo.pxx1(cleaningInfo.psdIdx.hz51,chn)],'r')
    text(gca,cleaningInfo.fxx(cleaningInfo.psdIdx.hz51)+1, cleaningInfo.pxx1(cleaningInfo.psdIdx.hz49,chn)+5,[num2str(round(cleaningInfo.hz50P(chn),2)) ' dB'])
    xlim([0 60])
    set(gca,'ytick',[],'xtick',[])
    title(peakax(n+1),['Chan ' num2str(chans(n))],'Position',[0.7 0.8])
    set(peakax(n+1),'ytick',[],'xtick',[])
end

axes(peakax(6))
scatter(peakax(6),cleaningInfo.thetaP,cleaningInfo.hz50P)
scatter(peakax(6),cleaningInfo.thetaP(cleaningInfo.removalIndices.thetaPidx),cleaningInfo.hz50P(cleaningInfo.removalIndices.thetaPidx),'MarkerEdgeColor','r')
scatter(peakax(6),cleaningInfo.thetaP(cleaningInfo.removalIndices.compPidx),cleaningInfo.hz50P(cleaningInfo.removalIndices.compPidx),'MarkerEdgeColor','r')
scatter(peakax(6),cleaningInfo.thetaP(cleaningInfo.removalIndices.badThetaPeaks),cleaningInfo.hz50P(cleaningInfo.removalIndices.badThetaPeaks),'Marker','x','MarkerEdgeColor','r')
scatter(peakax(6),cleaningInfo.thetaP(cleaningInfo.removalIndices.prepsdidx),cleaningInfo.hz50P(cleaningInfo.removalIndices.prepsdidx),'Marker','+','MarkerEdgeColor','r')
scatter(peakax(6),cleaningInfo.thetaP(cleaningInfo.removalIndices.psdinfidx),cleaningInfo.hz50P(cleaningInfo.removalIndices.psdinfidx),'Marker','+','MarkerEdgeColor','c')

plot(peakax(6),[cleaningInfo.threshold.thetaP cleaningInfo.threshold.thetaP],[-1 max(cleaningInfo.thetaP)],'r--')
%plot(peakax(6),[-1 60],[thresholds.hz50P thresholds.hz50P],'r--')
plot(peakax(6),[0 max([max(cleaningInfo.thetaP) max(cleaningInfo.hz50P)])],[0  1.5*max([max(cleaningInfo.thetaP) max(cleaningInfo.hz50P)])],'r--')
title(peakax(6),'')
xlabel(peakax(6),'theta power (dB)')
ylabel(peakax(6),'50Hz power (dB)')
axis tight

pxxClean = cleaningInfo.pxx1;
pxxClean(:,cleaningInfo.removalIndices.psdidx) = NaN;

pxxBad = cleaningInfo.pxx1;
pxxBad(:,~cleaningInfo.removalIndices.psdidx) = NaN;

axes(peakax(7))
plot_lines_with_color_gradient(peakax(7),pxxClean,'x',cleaningInfo.fxx)
xlim(peakax(7),[0 65])
ylabel(peakax(7),'Power (dB/Hz)')
xlabel(peakax(7),'Frequency (Hz)')
title(peakax(7),'PSDs of clean channels','Position',[0.5 0.9])

axes(peakax(8))
plot_lines_with_color_gradient(peakax(8),pxxBad,'x',cleaningInfo.fxx)
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
    plot(gca,cleaningInfo.fxx,cleaningInfo.pxx1(:,n))
    plot(gca,[cleaningInfo.fxx(cleaningInfo.psdIdx.theta1) cleaningInfo.fxx(cleaningInfo.psdIdx.theta2)],[cleaningInfo.pxx1(cleaningInfo.psdIdx.theta1,n) cleaningInfo.pxx1(cleaningInfo.psdIdx.theta2,n)],'r')
    text(gca,cleaningInfo.fxx(cleaningInfo.psdIdx.theta2)+1, cleaningInfo.pxx1(cleaningInfo.psdIdx.theta1,n)+5,[num2str(round(cleaningInfo.thetaP(n),2)) ' dB'])
    
    plot(gca,[cleaningInfo.fxx(cleaningInfo.psdIdx.hz49) cleaningInfo.fxx(cleaningInfo.psdIdx.hz51)],[cleaningInfo.pxx1(cleaningInfo.psdIdx.hz49,n) cleaningInfo.pxx1(cleaningInfo.psdIdx.hz51,n)],'r')
    text(gca,cleaningInfo.fxx(cleaningInfo.psdIdx.hz51)+1, cleaningInfo.pxx1(cleaningInfo.psdIdx.hz49,n)+5,[num2str(round(cleaningInfo.hz50P(n),2)) ' dB'])
    xlim([0 60])
    set(gca,'ytick',[],'xtick',[])
end

%% plot cleaned signal
t = 0 : size(extdata,1)-1;
figure;
axsig(1) = subplot(511,'next','add');
plot(axsig(1),t,cleaningInfo.ampIdx*3,'k')
plot(axsig(1),[t(1) t(end)],[cleaningInfo.ampThreshUsed cleaningInfo.ampThreshUsed],'r--')
title('All Channels')

axsig(2) = subplot(5,1,2:5,'next','add');
sf  = plot_trace_across_chans(axsig(2),cdata,'xvec',t);
[~] =  plot_trace_across_chans(axsig(2),extdata,'xvec',t,'scalefactor',sf, 'col',[1 0 0 0.3]);
chH = get(axsig(2),'Children');
set(axsig(2),'Children',flipud(chH))
xlabel('Samples')
ylabel('Channel')
linkaxes(axsig,'x')

% plot cleaned signal (but only clean channels)
figure
axsig(1) = subplot(611,'next','add');
axsig(2) = subplot(612,'next','add');
axsig(3) = subplot(6,1,3:6,'next','add');
        
abovethr = cleaningInfo.meanAmp;
abovethr(~cleaningInfo.ampIdx) = NaN;
        
plot(axsig(1),t,cleaningInfo.meanAmp,'k')
plot(axsig(1),t,abovethr, 'p','color','r')
plot(axsig(1),[t(1) t(end)],[cleaningInfo.ampThreshUsed cleaningInfo.ampThreshUsed],'r--')
title('Clean channels')

 plot(axsig(2),t,cleaningInfo.zIdx,'g')
 plot(axsig(2),t,cleaningInfo.MaxMinIdx,'b')
 legend(axsig(2),{'zeros','maxmin'})
        
extdata(:,cleaningInfo.badChanIdx) = NaN;
sf  = plot_trace_across_chans(axsig(3),cdata,'xvec',t);
[~] =  plot_trace_across_chans(axsig(3),extdata,'xvec',t,'scalefactor',sf, 'col',[1 0 0 0.3]);
chH = get(axsig(3),'Children');
set(axsig(3),'Children',flipud(chH))
xlabel('Samples')
ylabel('Channel')
linkaxes(axsig,'x')

%% replot PSDs
plot_lines_with_color_gradient([],cleaningInfo.pxxClean,'x',cleaningInfo.fxx)
title('PSDs for clean channels')
xlabel('Frequency (Hz)')
ylabel('Power (dB/Hz)')