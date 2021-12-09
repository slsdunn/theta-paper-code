function neural_cleaning_table = NL_neural_cleaning_batch

%
% Cleaning of LFP signals for data collected with neuralynx
% Soraya Dunn 2020
%

params = get_parameters;

% thresholds.ampThresh4psd1 = 1;       % mV, applied to abs(amp) of each channel for calc of channel PSDs optimising theta peak
% thresholds.ampThresh4psd2 = 0.5;     % mV, applied to mean(abs(amp)) of all channels for calc of channel PSDs optimising theta peak
% thresholds.thetaf1        = 3;       % frequency limits for psd peak power calculations
% thresholds.thetaf2        = 7;
% thresholds.hz50f1         = 49;
% thresholds.hz50f2         = 51;
% thresholds.psdnfft        = 4096;
% thresholds.thetaP         = 2;       % dB, minimum theta power for good channel
% thresholds.theta50ratio   = 1.5;     % if 50Hz noise power is 1.5 times larger than theta peak, channel is classed as bad
% %thresholds.hz50P          = 25;      % not currently in use. dB, maximum 50Hz power for good channels, also channels removed where 50Hz power > theta power
% thresholds.ampModeMult    = 10;      % mulitplier for mode of mean(abs(amp)) to finding threshold large amplitude artefacts across channels
% thresholds.ampThreshMin   = 1.25;    % mV, applied to mean(abs(amp)) of all good channels (bad removed by PSD thresholding)
% thresholds.ampThreshMax   = 5;       % highest value out of ampModeMult or ampThresh used to threshold signals
%

thresholds.scratch.f_order     = 500;
thresholds.scratch.f_width     = [6 13];
thresholds.scratch.SR          = 1000;
thresholds.scratch.ampModeMult = 3.5;

thresholds.ampThresh4psd1 = 1;     % mV, applied to abs(amp) of each channel for calc of channel PSDs optimising theta peak
thresholds.ampThresh4psd2 = 0.75;  % mV, applied to mean(abs(amp)) of all channels for calc of channel PSDs optimising theta peak
thresholds.thetaf1        = 5.5;   % frequency limits for psd peak power calculations
thresholds.thetaf2        = 12;
thresholds.hz50f1         = 49;
thresholds.hz50f2         = 51;
thresholds.psdnfft        = 2048;
thresholds.thetaP         = 4;     % dB, minimum theta power for good channel
thresholds.theta50ratio   = 5;     % if 50Hz noise power is 1.5 times larger than theta peak, channel is classed as bad
%thresholds.hz50P          = 25;    % dB, maximum 50Hz power for good channels, also channels removed where 50Hz power > theta power
thresholds.ampModeMult    = 10;    % mulitplier for mode of mean(abs(amp)) to finding threshold large amplitude artefacts across channels
thresholds.ampThresh      = 1.5;   % mV, applied to mean(abs(amp)) of all good channels (bad removed by PSD thresholding)
thresholds.ampThreshMin   = 1;
thresholds.ampThreshMax   = 4;     % highest value out of ampModeMult or ampThresh used to threshold signals
thresholds.minmaxWin      = 20;
thresholds.minmaxV        = 1.75;


refPath = params.R.refPath;
tblFp   = fullfile(refPath, 'neural_cleaning_table2.mat');

ref = load_reference_table('R','incl','neu');

if exist(tblFp , 'file')
    load(tblFp, 'neural_cleaning_table')
    rowNum      = size(neural_cleaning_table,1)+1;
    alreadydone = neural_cleaning_table.ExtractedFile;
else
    neural_cleaning_table = neural_cleaning_makeTable();
    rowNum = 1;
    alreadydone = {'none'};
    
end

for n = 1:size(ref,1)
    
    sessionref = ref(n,:);
    
    % skip if already added to table
    if any(contains(alreadydone, sessionref.ExtractedFile{1}))
        continue
    end
    
    disp(['Cleaning  ' num2str(n) '/' num2str(size(ref,1)) ': ' sessionref.ExtractedFile{1}])
       
    mdata = load_basic_metadata(sessionref);
    cdata = load_neural_data(sessionref,1:mdata.nChannelsTotal,'extsignal');
    
    thresholds.saturation = min(mdata.inputRange_mV);
    thresholds.saturation_margin = 0.05;
    thresholds.saturation_extension = 100;
    
    
    [cleanData,cleaningInfo] = NL_neural_cleaning(cdata,thresholds,0);
    
    [cleanData, cleaningInfo.scratch]= remove_scratching_artefacts(cleanData,thresholds.scratch,0);

    cleaningInfo.mdata = mdata;
    cleaningInfo.sessionref = sessionref;
    
    extractedfldPath = fullfile(params.R.extDataPath,sessionref.ExtractedFolder{1}); % folder where data is extracted
    saveinfopath = fullfile(params.R.preprocessingPath,'Neural_cleaning_info');
    saveinfoname = strrep(sessionref.ExtractedFile{1}, 'CX', 'neuralCleaningInfo');
    
    save(fullfile(saveinfopath, saveinfoname),'-struct','cleaningInfo')
    
    for nc = 1:mdata.nChannelsTotal
        cleansignal = cleanData(:,nc);
        if all(isnan(cleansignal))
            cleansignal = []; % save empty vector for bad channels
        end
        savename = strrep(sessionref.ExtractedFile{1}, 'CX', ['C' num2str(nc)]);
        save(fullfile(extractedfldPath, savename),'cleansignal','-append')
        disp(savename)
        
    end
    
    [neural_cleaning_table, rowNum]= add_to_neural_cleaning_table(sessionref,neural_cleaning_table, cleaningInfo,rowNum);
    save(tblFp, 'neural_cleaning_table')
end

end





function T = neural_cleaning_makeTable

%% Set up tables

% Suppress warnings about default row contents
warning('off', 'MATLAB:table:RowsAddedExistingVars');
warning('off','MATLAB:table:RowsAddedNewVars');

tableParams = {...
    cell(1),    'ID';...
    cell(1),    'ExtractedFolder';...
    cell(1),    'ExtractedFile';...
    cell(1),    'CleanChannelIdx';...
    NaN,        'NCleanChannels';...
    NaN,        'NBadChannels';...
    NaN,        'NChan';...
    cell(1),    'CleanChannels';...
    NaN,        'MeanPcCleaned';...
    NaN,        'AmpThreshUsed';...
    NaN,        'ScratchPcCleaned';...
    cell(1),    'Bad_PrePSD';...
%     cell(1),    'Bad_ThetaPeaks';...
    cell(1),    'Bad_ThetaPower';...
    cell(1),    'Bad_Theta50Ratio';...
    NaN,        'Check';...
    cell(1),    'Note';...
    };

T = table(tableParams{:,1});
T.Properties.VariableNames = tableParams(:,2);


end



function [cleaned, scratchinfo] = remove_scratching_artefacts(data, thresh, plotYN)

% data = 32 channels (n samp by 32 chan)
% thresholds
% plotYN = 0 or 1, to plot output of cleaning

% returns data with scratching artefacts and weird HVS cortical oscillation
% replaced with NaN across all channels

% find 6-13Hz power to ID scratching artefacts
%fo = 500;
%fw = [6 13];
% b  = fir1(thresh.f_order, thresh.f_width/thresh.SR,'bandpass');
% filt10hz = filtfilt(b,1,data);

nanidx = isnan(data);
data   = fillmissing(data,'linear','EndValues','nearest');

filt10hz        = filter_signal(data,thresh.SR,'BP',thresh.f_width,thresh.f_order);
filt10hz.signal = fillmissing(filt10hz.signal,'linear','EndValues','nearest');

a10hz = abs(hilbert(filt10hz.signal));
a10hz(nanidx) = NaN;

% find median 10Hz amplitude across top 10 channels
med10hz = nanmedian(a10hz(:,1:10),2);

% find a threshold for the 10Hz power
med10hz_threshold = find_thresholds_using_histogram(med10hz,thresh.ampModeMult,'median',plotYN);

% remove portions where the 10Hz power of the top 10 channels exceeds
% threshold
excl_idx = med10hz > med10hz_threshold.thresh;

cleaned = data;
cleaned(nanidx)     = NaN;
cleaned(excl_idx,:) = NaN;

scratchinfo.nSampRemoved = sum(excl_idx);
scratchinfo.pcRemoved    = percent_high(excl_idx);
scratchinfo.sampRemoved  = find(excl_idx);

disp(['Scratch cleaned = ' num2str(scratchinfo.pcRemoved)])

if plotYN
    figure
    subplot(511,'next','add')
    plot(med10hz,'k')
    plot(xlim,[ med10hz_threshold.thresh  med10hz_threshold.thresh],'r--')
    subplot(5,1,2:5,'next','add')
    sf = plot_trace_across_chans(gca,data,'color','r');
    plot_trace_across_chans(gca,cleaned,'scalefactor',sf);
    link_axes_in_figure(gcf,'x')
    
%     figure
%     subplot(511,'next','add')
%     plot(med10hz,'k')
%     plot(xlim,[ med10hz_threshold.thresh  med10hz_threshold.thresh],'r--')
%     subplot(5,1,2:5,'next','add')
%     sf2 = plot_trace_across_chans(gca,data,'color',[0.5 0.5 0.5 0.2]);
%     plot_trace_across_chans(gca,filt10hz.signal,'scalefactor',sf2);
%     plot_trace_across_chans(gca,a10hz,'color',[0 0.5 0 0.5],'scalefactor',sf2);
%     link_axes_in_figure(gcf,'x')
    
end

end



function [threshold, h] = find_thresholds_using_histogram(input, mult,thresh_method, plotYN)

fig = figure;
if ~plotYN
    set(fig, 'visible','off')
end

h = histogram(input);

switch thresh_method
    case 'median'
        
        threshold.param = nanmedian(input);
        threshold.mult = mult;
        threshold.thresh = threshold.param*mult;
        
        
    case 'mode'
        
        [~,mi]=max(h.Values);
        threshold.param = h.BinEdges(mi+1);
        threshold.mult = mult;
        threshold.thresh = threshold.param*mult;
        
    case 'neg_exp'
        pd = fitdist(input,'exponential');
        xx=1:10000;
        yy = exp(-xx/pd.mu);
        yyy = find(yy<0.000005);
        threshold.thresh = xx(yyy(1));
        
end

if ~plotYN
    close(fig)
else
    hold on
    yplot=ylim;
    yplot = [0.00000001 yplot(2)];
    plot([threshold.thresh, threshold.thresh],yplot)
end


end



function  [neural_cleaning_table, rowNum]= add_to_neural_cleaning_table(sessionref,neural_cleaning_table, cleaningInfo,rowNum)

% Suppress warnings about default row contents
warning('off', 'MATLAB:table:RowsAddedExistingVars');
warning('off','MATLAB:table:RowsAddedNewVars');

neural_cleaning_table.ID(rowNum,1)              = sessionref.ID;
neural_cleaning_table.ExtractedFolder(rowNum,1) = sessionref.ExtractedFolder;
neural_cleaning_table.ExtractedFile(rowNum,1)   = sessionref.ExtractedFile;
neural_cleaning_table.CleanChannelIdx(rowNum,1) = {cleaningInfo.cleanChanIdx};
neural_cleaning_table.NCleanChannels(rowNum,1)  = cleaningInfo.nCleanChans;
neural_cleaning_table.NBadChannels(rowNum,1)    = cleaningInfo.nBadChans;
neural_cleaning_table.NChan(rowNum,1)           = cleaningInfo.nTotChans;
neural_cleaning_table.CleanChannels(rowNum,1)   = {cleaningInfo.cleanChannels};
neural_cleaning_table.MeanPcCleaned(rowNum,1)   = mean(cleaningInfo.pcCleaned(cleaningInfo.cleanChanIdx));
neural_cleaning_table.AmpThreshUsed(rowNum,1)   = cleaningInfo.ampThreshUsed;
neural_cleaning_table.ScratchPcCleaned(rowNum,1)= cleaningInfo.scratch.pcRemoved;
neural_cleaning_table.Bad_PrePSD(rowNum,1)      = {find(cleaningInfo.removalIndices.prepsdidx)};
% neural_cleaning_table.Bad_ThetaPeaks(rowNum,1)  = {find(cleaningInfo.removalIndices.badThetaPeaks)};
neural_cleaning_table.Bad_ThetaPower(rowNum,1)  = {find(cleaningInfo.removalIndices.thetaPidx)};
neural_cleaning_table.Bad_Theta50Ratio(rowNum,1)= {find(cleaningInfo.removalIndices.compPidx)};

if cleaningInfo.nBadChans == cleaningInfo.nTotChans
    check = 0;
    note = 'cleaning removed all channels';
else
    check = 1;
    note = 'NA';
end

neural_cleaning_table.Note(rowNum,1)  = {note};
neural_cleaning_table.Check(rowNum,1) = check;

% neural_cleaning_table = sortrows(neural_cleaning_table, {'ID','ExtractedFile'});

rowNum = rowNum + 1;

end


