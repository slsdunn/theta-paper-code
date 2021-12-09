function neural_cleaning_table = TDT_MCS_neural_cleaning_batch

%
% Cleaning of LFP signals for data collected with TDT or MCS systems
% Soraya Dunn 2020
%

params = get_parameters;

thresholds.ampThresh4psd1 = 1;       % mV, applied to abs(amp) of each channel for calc of channel PSDs optimising theta peak
thresholds.ampThresh4psd2 = 0.5;     % mV, applied to mean(abs(amp)) of all channels for calc of channel PSDs optimising theta peak
thresholds.thetaf1        = 3;       % frequency limits for psd peak power calculations
thresholds.thetaf2        = 7;
thresholds.hz50f1         = 49;
thresholds.hz50f2         = 51;
thresholds.psdnfft        = 4096;
thresholds.thetaP         = 2;       % dB, minimum theta power for good channel 
thresholds.theta50ratio   = 1.5;     % if 50Hz noise power is 1.5 times larger than theta peak, channel is classed as bad
%thresholds.hz50P          = 25;      % not currently in use. dB, maximum 50Hz power for good channels, also channels removed where 50Hz power > theta power
thresholds.ampModeMult    = 10;      % mulitplier for mode of mean(abs(amp)) to finding threshold large amplitude artefacts across channels 
thresholds.ampThreshMin   = 1.25;    % mV, applied to mean(abs(amp)) of all good channels (bad removed by PSD thresholding)
thresholds.ampThreshMax   = 5;       % highest value out of ampModeMult or ampThresh used to threshold signals
  

refPath = params.F.refPath;
tblFp   = fullfile(refPath, 'neural_cleaning_table2.mat');

ref = load_reference_table('F','incl','check|neu','modality','A|V');

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
    
    disp(['Cleaning  ' num2str(n) '/' num2str(size(ref,1))])
        
    mdata = load_basic_metadata(sessionref);
    cdata = load_neural_data(sessionref,1:mdata.nChannelsTotal,'extsignal');
    
    [cleanData,cleaningInfo] = neural_cleaning(cdata,thresholds,0);
    
    cleaningInfo.mdata = mdata;
    cleaningInfo.sessionref = sessionref;
    
    extractedfldPath = fullfile(params.F.extDataPath,sessionref.ExtractedFolder{1}); % folder where data is extracted
    saveinfoname = strrep(sessionref.ExtractedFile{1}, 'CX', 'neuralCleaningInfo');
   
    save(fullfile(params.F.preprocessingPath,'neural_cleaning_info', saveinfoname),'-struct','cleaningInfo')    
    
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
    cell(1),    'Block';...
    cell(1),    'RecType';...
    cell(1),    'ExtractedFolder';...
    cell(1),    'ExtractedFile';...
    cell(1),    'RecSide';...
    cell(1),    'CleanChannelIdx';...
    NaN,        'NCleanChannels';...  
    NaN,        'NBadChannels';... 
    NaN,        'NChan';...  
    cell(1),    'CleanChannels';...
    NaN,        'MeanPcCleaned';...
    NaN,        'AmpThreshUsed';...
    cell(1),    'Bad_PrePSD';...
    cell(1),    'Bad_ThetaPeaks';...
    cell(1),    'Bad_ThetaPower';...
    cell(1),    'Bad_Theta50Ratio';...
    NaN,        'Check';...
    cell(1),    'Note';...
    };

T = table(tableParams{:,1});
T.Properties.VariableNames = tableParams(:,2);


end



function  [neural_cleaning_table, rowNum]= add_to_neural_cleaning_table(sessionref,neural_cleaning_table, cleaningInfo,rowNum)

% Suppress warnings about default row contents
warning('off', 'MATLAB:table:RowsAddedExistingVars');
warning('off','MATLAB:table:RowsAddedNewVars');

neural_cleaning_table.ID(rowNum,1)              = sessionref.ID;
neural_cleaning_table.Block(rowNum, 1)          = sessionref.Block;
neural_cleaning_table.RecType(rowNum, 1)        = sessionref.RecType;
neural_cleaning_table.ExtractedFolder(rowNum,1) = sessionref.ExtractedFolder;
neural_cleaning_table.ExtractedFile(rowNum,1)   = sessionref.ExtractedFile;
neural_cleaning_table.RecSide(rowNum,1)         = sessionref.RecSide;
neural_cleaning_table.CleanChannelIdx(rowNum,1) = {cleaningInfo.cleanChanIdx};
neural_cleaning_table.NCleanChannels(rowNum,1)  = cleaningInfo.nCleanChans;
neural_cleaning_table.NBadChannels(rowNum,1)    = cleaningInfo.nBadChans;
neural_cleaning_table.NChan(rowNum,1)           = cleaningInfo.nTotChans;
neural_cleaning_table.CleanChannels(rowNum,1)   = {cleaningInfo.cleanChannels};
neural_cleaning_table.MeanPcCleaned(rowNum,1)   = mean(cleaningInfo.pcCleaned(cleaningInfo.cleanChanIdx));
neural_cleaning_table.AmpThreshUsed(rowNum,1)   = cleaningInfo.ampThreshUsed;
neural_cleaning_table.Bad_PrePSD(rowNum,1)      = {find(cleaningInfo.removalIndices.prepsdidx)};
neural_cleaning_table.Bad_ThetaPeaks(rowNum,1)  = {find(cleaningInfo.removalIndices.badThetaPeaks)};
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

neural_cleaning_table = sortrows(neural_cleaning_table, {'ID','ExtractedFile'});

rowNum = rowNum + 1;

end
    