function quantify_xcorr_speed_batch(species,saveFolder)


try
    params    = get_parameters;
    savepath = fullfile(params.(species).processedDataPath,saveFolder);
    if~exist(savepath,'dir')
        mkdir(savepath)
    end
    
    % parameters for this analysis
    thresh.params       = params;
    thresh.runstart     = datetime;
    thresh.win_samples  = params.xcorr.win_samples;
    thresh.win_seconds  = params.xcorr.win_seconds;
    thresh.refFreqRange = params.xcorr.(species).freq_range;
    thresh.refFreqResolution = 0.1;
    thresh.R_maze_arm_ylim = params.trial_ext.R_rwd_ylim;
    thresh.flt_desc        = 'cheby2';
    
    ref       = load_reference_table(species,'incl','neu','level','L5|6');
    nsessions = size(ref,1);
    
    
    switch species
        case 'F'
            thresh.flt_desc = {'1_highpass';'49_51_bandstop'};
        case 'R'
            thresh.flt_desc = {'2_highpass';'49_51_bandstop'};
    end
    
    for n = 1:nsessions
        
        % load data
        sessionref = ref(n,:);
        mdata      = load_metadata(sessionref);      
        if mdata.mapID==0 || mdata.mapID==-999 % skip if no map (for non atropine sessions)
            if ~contains(sessionref.Modality,'atropine')
                continue
            end
        end
        
        cdata  = load_neural_mapped(sessionref,mdata,'all','cleansignal');
        t_neu  = load_neural_timeline(mdata);
        speed  = load_tracking_speed(sessionref,mdata,t_neu);
        
        for nf = 1:numel(thresh.flt_desc) % highpass then 50Hz notch
            [cdata, f_info] = cheby2_filtfilthd(cdata,thresh.flt_desc{nf},1000);
            thresh.filter_info{nf} = f_info;
        end
        
        % main function
        out = quantify_fft_xcorr_speed(cdata,speed,thresh);
        
        % save
        savename = [sessionref.ExtractedFolder{1} '_' saveFolder '.mat'];
        thresh.savename   = savename;
        thresh.sessionref = sessionref;
        out.thresh = thresh;
        
        save(fullfile(savepath,savename),'-struct','out')
        
        disp([num2str(n) '/' num2str(nsessions)])
    end
    
    
catch err
    parseError(err)
    keyboard
end


end


