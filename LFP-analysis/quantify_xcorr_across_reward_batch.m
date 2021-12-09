function quantify_xcorr_across_reward_batch(saveFolder)

params = get_parameters;
load(fullfile(params.F.refPath,'spout_coordinates.mat'),'spoutcoords'); % load table of spout positions for each session

savePath = fullfile(params.F.processedDataPath,saveFolder);
if ~exist(savePath,'dir')
    mkdir(savePath)
end

% parameters for this analysis
thresh.win_samples      = params.xcorr.win_samples;
thresh.win_seconds      = params.xcorr.win_seconds;
thresh.sliding_win_step = 100; % samples
thresh.spoutradius      = 8; % cm
thresh.xcorr_freq_range = params.xcorr.F.freq_range;
thresh.freqResolution   = params.xcorr.freqResolution;
thresh.flt_desc         = {'1_highpass';'49_51_bandstop'};

ref = load_reference_table('F','incl','neu','level','L5|6');

for n = 1:size(ref,1)
    
    sessionref = ref(n,:);
    thresh.scoord = spoutcoords(contains(spoutcoords.ExtFile,sessionref.ExtractedFile{1}),:);
    thresh.sessionref = sessionref;
    
    % load session data
    mdata  = load_metadata(sessionref);
    if mdata.mapID==0 || mdata.mapID==-999 % only run for sessions with channel map
       if ~contains(sessionref.Modality,'atropine')
        continue
       end
    end
    cdata  = load_neural_mapped(sessionref,mdata,'all','cleansignal');
    for nf = 1:numel(thresh.flt_desc) % highpass then 50Hz notch
       [cdata, f_info] = cheby2_filtfilthd(cdata,thresh.flt_desc{nf},1000);
       thresh.filter_info{nf} = f_info;
    end
    t_neu  = load_neural_timeline(mdata);
    speed  = load_tracking_speed(sessionref,mdata,t_neu);
    [xpos,ypos] = load_tracking_location(sessionref,mdata,t_neu);
    trials = load_trials_table(sessionref,'clean');
    
    % main function
    out = quantify_xcorr_across_reward(cdata,speed,xpos,ypos,t_neu,trials,thresh);
    
    % save
    out.thresh = thresh;
    savename = [sessionref.ExtractedFolder{1} '_' saveFolder '.mat'];
    
    save(fullfile(savePath,savename),'-struct','out')
    
    disp([num2str(n) ' / ' num2str(size(ref,1))])    
end