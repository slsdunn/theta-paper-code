function central_tendency_measures_across_channels_batch(species, savename, sigtype)

%
% calcs averages for power, freq at different speeds (immobile, moving, "control")
% for each channel across all sessions
% saves output in table
% 
% Soraya Dunn 2020
%

try
params = get_parameters;
ref    = load_reference_table(species,'incl','neu','level','L5|6');
CTM    = table;

stop_table_warnings;

nrow = 1;

for n = 1:size(ref,1)
    
    sessionref = ref(n,:);
    
    mdata = load_metadata(sessionref); % load channels
    cdata = load_neural_mapped(sessionref,mdata,'all',sigtype);
%     remove_duplicate_channel_from_tethered_rec(cdata,sessionref.RecType{1},mdata.recDevice,mdata.map,[]);
    
    t_neu = load_neural_timeline(sessionref);
    speed = load_tracking_speed(sessionref,mdata,t_neu);
    
    theta = filter_signal(cdata,1000,'BP',params.(species).theta_bandwidth,params.(species).theta_filtOrder);
    
    [ifreq,~,ipower,~, ~] = calculate_peak_trough_signal_parameters(theta.signal,params.PT_thresh_pc,t_neu);
    ipowerdB = 10*log10(ipower);
    ipowerz  = nanzscore(ipower,1);
    
    movIdx  = speed > params.speedThresh.moving;
    immIdx  = speed < params.speedThresh.immobile;
    movIdx2 = and(speed > params.speedThresh.movControl(1), speed < params.speedThresh.movControl(2));
    
    movP   = ipower(movIdx,:);
    movPz  = ipowerz(movIdx,:);
    movPdB = ipowerdB(movIdx,:);
    movF   = ifreq(movIdx,:);
    movS   = speed(movIdx);
    immP   = ipower(immIdx,:);
    immPz  = ipowerz(immIdx,:);
    immPdB = ipowerdB(immIdx,:);
    immF   = ifreq(immIdx,:);
    immS   = speed(immIdx);
    contP  = ipower(movIdx2,:);
    contPz = ipowerz(movIdx2,:);
    contPdB= ipowerdB(movIdx2,:);
    contF  = ifreq(movIdx2,:);
    contS  = speed(movIdx2);
    
    % find mean, stdev, sterr,  median, iqr for different conditions
    
    CTM.Species{nrow,1}       = sessionref.Species{1};
    CTM.ID{nrow,1}            = sessionref.ID{1};
    CTM.RecSide{nrow,1}       = sessionref.RecSide{1};
    CTM.IDside{nrow,1}        = sessionref.IDside{1};
    CTM.RecType{nrow,1}       = sessionref.RecType{1};
    CTM.Date{nrow,1}          = sessionref.Date{1};
    CTM.ExtractedFile{nrow,1} = sessionref.ExtractedFile{1};
    CTM.Level(nrow,1)         = sessionref.Level(1);
    CTM.Modality(nrow,1)      = sessionref.Modality(1);
    CTM.NChannels(nrow,1)     = mdata.nChannelsTotal;
    CTM.SigLength(nrow,1)     = size(cdata,1);
    CTM.MapID(nrow,1)         = mdata.mapID;
    
    CTM.MovProp(nrow,1)       = sum(movIdx)/length(movIdx);
    CTM.ImmProp(nrow,1)       = sum(immIdx)/length(immIdx);
    CTM.ContProp(nrow,1)      = sum(movIdx2)/length(movIdx2);
    
    CTM.MovPMean{nrow,1}      = nanmean(movP);
    CTM.MovPVar{nrow,1}       = var(movP,'omitnan');
    CTM.MovPStdev{nrow,1}     = nanstd(movP);
    CTM.MovPStderr{nrow,1}    = nanstd(movP)/sqrt(size(movP,1));
    CTM.MovPMedian{nrow,1}    = nanmedian(movP);
    CTM.MovPIQR{nrow,1}       = iqr(movP);
    CTM.MovPpct25{nrow,1}     = prctile(movP,25);
    CTM.MovPpct75{nrow,1}     = prctile(movP,75);
    CTM.MovPpct5{nrow,1}      = prctile(movP,5);
    CTM.MovPpct95{nrow,1}     = prctile(movP,95);
    CTM.MovPpct9{nrow,1}      = prctile(movP,9);
    CTM.MovPpct91{nrow,1}     = prctile(movP,91);

    CTM.MovPzMean{nrow,1}     = nanmean(movPz);
    CTM.MovPzVar{nrow,1}      = var(movPz,'omitnan');
    CTM.MovPzStdev{nrow,1}    = nanstd(movPz);
    CTM.MovPzStderr{nrow,1}   = nanstd(movPz)/sqrt(size(movPz,1));
    CTM.MovPzMedian{nrow,1}   = nanmedian(movPz);
    CTM.MovPzIQR{nrow,1}      = iqr(movPz);
    CTM.MovPzpct25{nrow,1}    = prctile(movPz,25);
    CTM.MovPzpct75{nrow,1}    = prctile(movPz,75);
    CTM.MovPzpct5{nrow,1}     = prctile(movPz,5);
    CTM.MovPzpct95{nrow,1}    = prctile(movPz,95);
    CTM.MovPzpct9{nrow,1}     = prctile(movPz,9);
    CTM.MovPzpct91{nrow,1}    = prctile(movPz,91);

    CTM.MovPdBMean{nrow,1}    = nanmean(movPdB);
    CTM.MovPdBVar{nrow,1}     = var(movPdB,'omitnan');
    CTM.MovPdBStdev{nrow,1}   = nanstd(movPdB);
    CTM.MovPdBStderr{nrow,1}  = nanstd(movPdB)/sqrt(size(movPdB,1));
    CTM.MovPdBMedian{nrow,1}  = nanmedian(movPdB);
    CTM.MovPdBIQR{nrow,1}     = iqr(movPdB);
    CTM.MovPdBpct25{nrow,1}   = prctile(movPdB,25);
    CTM.MovPdBpct75{nrow,1}   = prctile(movPdB,75);
    CTM.MovPdBpct5{nrow,1}    = prctile(movPdB,5);
    CTM.MovPdBpct95{nrow,1}   = prctile(movPdB,95);
    CTM.MovPdBpct9{nrow,1}    = prctile(movPdB,9);
    CTM.MovPdBpct91{nrow,1}   = prctile(movPdB,91);    
    
    CTM.MovFMean{nrow,1}      = nanmean(movF);
    CTM.MovFVar{nrow,1}       = var(movF,'omitnan');
    CTM.MovFStdev{nrow,1}     = nanstd(movF);
    CTM.MovFStderr{nrow,1}    = nanstd(movF)/sqrt(size(movF,1));
    CTM.MovFMedian{nrow,1}    = nanmedian(movF);
    CTM.MovFIQR{nrow,1}       = iqr(movF);
    CTM.MovFpct25{nrow,1}     = prctile(movF,25);
    CTM.MovFpct75{nrow,1}     = prctile(movF,75);
    CTM.MovFpct5{nrow,1}      = prctile(movF,5);
    CTM.MovFpct95{nrow,1}     = prctile(movF,95);
    CTM.MovFpct9{nrow,1}      = prctile(movF,9);
    CTM.MovFpct91{nrow,1}     = prctile(movF,91);
    
    CTM.MovSMean{nrow,1}      = nanmean(movS);
    CTM.MovSVar{nrow,1}       = var(movS,'omitnan');
    CTM.MovSStdev{nrow,1}     = nanstd(movS);
    CTM.MovSStderr{nrow,1}    = nanstd(movS)/sqrt(size(movS,1));
    CTM.MovSMedian{nrow,1}    = nanmedian(movS);
    CTM.MovSIQR{nrow,1}       = iqr(movS);
    CTM.MovSpct25{nrow,1}     = prctile(movS,25);
    CTM.MovSpct75{nrow,1}     = prctile(movS,75);
    CTM.MovSpct5{nrow,1}      = prctile(movS,5);
    CTM.MovSpct95{nrow,1}     = prctile(movS,95);
    CTM.MovSpct9{nrow,1}      = prctile(movS,9);
    CTM.MovSpct91{nrow,1}     = prctile(movS,91);
    
    CTM.ImmPMean{nrow,1}      = nanmean(immP);
    CTM.ImmPVar{nrow,1}       = var(immP,'omitnan');
    CTM.ImmPStdev{nrow,1}     = nanstd(immP);
    CTM.ImmPStderr{nrow,1}    = nanstd(immP)/sqrt(size(immP,1));
    CTM.ImmPMedian{nrow,1}    = nanmedian(immP);
    CTM.ImmPIQR{nrow,1}       = iqr(immP);
    CTM.ImmPpct25{nrow,1}     = prctile(immP,25);
    CTM.ImmPpct75{nrow,1}     = prctile(immP,75);
    CTM.ImmPpct5{nrow,1}      = prctile(immP,5);
    CTM.ImmPpct95{nrow,1}     = prctile(immP,95);
    CTM.ImmPpct9{nrow,1}      = prctile(immP,9);
    CTM.ImmPpct91{nrow,1}     = prctile(immP,91);

    CTM.ImmPzMean{nrow,1}     = nanmean(immPz);
    CTM.ImmPzVar{nrow,1}      = var(immPz,'omitnan');
    CTM.ImmPzStdev{nrow,1}    = nanstd(immPz);
    CTM.ImmPzStderr{nrow,1}   = nanstd(immPz)/sqrt(size(immPz,1));
    CTM.ImmPzMedian{nrow,1}   = nanmedian(immPz);
    CTM.ImmPzIQR{nrow,1}      = iqr(immPz);
    CTM.ImmPzpct25{nrow,1}    = prctile(immPz,25);
    CTM.ImmPzpct75{nrow,1}    = prctile(immPz,75);
    CTM.ImmPzpct5{nrow,1}     = prctile(immPz,5);
    CTM.ImmPzpct95{nrow,1}    = prctile(immPz,95);
    CTM.ImmPzpct9{nrow,1}     = prctile(immPz,9);
    CTM.ImmPzpct91{nrow,1}    = prctile(immPz,91);

    CTM.ImmPdBMean{nrow,1}    = nanmean(immPdB);
    CTM.ImmPdBVar{nrow,1}     = var(immPdB,'omitnan');
    CTM.ImmPdBStdev{nrow,1}   = nanstd(immPdB);
    CTM.ImmPdBStderr{nrow,1}  = nanstd(immPdB)/sqrt(size(immPdB,1));
    CTM.ImmPdBMedian{nrow,1}  = nanmedian(immPdB);
    CTM.ImmPdBIQR{nrow,1}     = iqr(immPdB);
    CTM.ImmPdBpct25{nrow,1}   = prctile(immPdB,25);
    CTM.ImmPdBpct75{nrow,1}   = prctile(immPdB,75);
    CTM.ImmPdBpct5{nrow,1}    = prctile(immPdB,5);
    CTM.ImmPdBpct95{nrow,1}   = prctile(immPdB,95);
    CTM.ImmPdBpct9{nrow,1}    = prctile(immPdB,9);
    CTM.ImmPdBpct91{nrow,1}   = prctile(immPdB,91);    
    
    
    CTM.ImmFMean{nrow,1}      = nanmean(immF);
    CTM.ImmFVar{nrow,1}       = var(immF,'omitnan');
    CTM.ImmFStdev{nrow,1}     = nanstd(immF);
    CTM.ImmFStderr{nrow,1}    = nanstd(immF)/sqrt(size(immF,1));
    CTM.ImmFMedian{nrow,1}    = nanmedian(immF);
    CTM.ImmFIQR{nrow,1}       = iqr(immF);
    CTM.ImmFpct25{nrow,1}     = prctile(immF,25);
    CTM.ImmFpct75{nrow,1}     = prctile(immF,75);
    CTM.ImmFpct5{nrow,1}      = prctile(immF,5);
    CTM.ImmFpct95{nrow,1}     = prctile(immF,95);
    CTM.ImmFpct9{nrow,1}      = prctile(immF,9);
    CTM.ImmFpct91{nrow,1}     = prctile(immF,91);
    
    CTM.ImmSMean{nrow,1}      = nanmean(immS);
    CTM.ImmSVar{nrow,1}       = var(immS,'omitnan');
    CTM.ImmSStdev{nrow,1}     = nanstd(immS);
    CTM.ImmSStderr{nrow,1}    = nanstd(immS)/sqrt(size(immS,1));
    CTM.ImmSMedian{nrow,1}    = nanmedian(immS);
    CTM.ImmSIQR{nrow,1}       = iqr(immS);
    CTM.ImmSpct25{nrow,1}     = prctile(immS,25);
    CTM.ImmSpct75{nrow,1}     = prctile(immS,75);
    CTM.ImmSpct5{nrow,1}      = prctile(immS,5);
    CTM.ImmSpct95{nrow,1}     = prctile(immS,95);
    CTM.ImmSpct9{nrow,1}      = prctile(immS,9);
    CTM.ImmSpct91{nrow,1}     = prctile(immS,91);
    
    CTM.ContPMean{nrow,1}     = nanmean(contP);
    CTM.ContPVar{nrow,1}      = var(contP,'omitnan');
    CTM.ContPStdev{nrow,1}    = nanstd(contP);
    CTM.ContPStderr{nrow,1}   = nanstd(contP)/sqrt(size(contP,1));
    CTM.ContPMedian{nrow,1}   = nanmedian(contP);
    CTM.ContPIQR{nrow,1}      = iqr(contP);
    CTM.ContPpct25{nrow,1}    = prctile(contP,25);
    CTM.ContPpct75{nrow,1}    = prctile(contP,75);
    CTM.ContPpct5{nrow,1}     = prctile(contP,5);
    CTM.ContPpct95{nrow,1}    = prctile(contP,95);
    CTM.ContPpct9{nrow,1}     = prctile(contP,9);
    CTM.ContPpct91{nrow,1}    = prctile(contP,91);
    
    CTM.ContPzMean{nrow,1}     = nanmean(contPz);
    CTM.ContPzVar{nrow,1}      = var(contPz,'omitnan');
    CTM.ContPzStdev{nrow,1}    = nanstd(contPz);
    CTM.ContPzStderr{nrow,1}   = nanstd(contPz)/sqrt(size(contPz,1));
    CTM.ContPzMedian{nrow,1}   = nanmedian(contPz);
    CTM.ContPzIQR{nrow,1}      = iqr(contPz);
    CTM.ContPzpct25{nrow,1}    = prctile(contPz,25);
    CTM.ContPzpct75{nrow,1}    = prctile(contPz,75);
    CTM.ContPzpct5{nrow,1}     = prctile(contPz,5);
    CTM.ContPzpct95{nrow,1}    = prctile(contPz,95);
    CTM.ContPzpct9{nrow,1}     = prctile(contPz,9);
    CTM.ContPzpct91{nrow,1}    = prctile(contPz,91);

    CTM.ContPdBMean{nrow,1}    = nanmean(contPdB);
    CTM.ContPdBVar{nrow,1}     = var(contPdB,'omitnan');
    CTM.ContPdBStdev{nrow,1}   = nanstd(contPdB);
    CTM.ContPdBStderr{nrow,1}  = nanstd(contPdB)/sqrt(size(contPdB,1));
    CTM.ContPdBMedian{nrow,1}  = nanmedian(contPdB);
    CTM.ContPdBIQR{nrow,1}     = iqr(contPdB);
    CTM.ContPdBpct25{nrow,1}   = prctile(contPdB,25);
    CTM.ContPdBpct75{nrow,1}   = prctile(contPdB,75);
    CTM.ContPdBpct5{nrow,1}    = prctile(contPdB,5);
    CTM.ContPdBpct95{nrow,1}   = prctile(contPdB,95);
    CTM.ContPdBpct9{nrow,1}    = prctile(contPdB,9);
    CTM.ContPdBpct91{nrow,1}   = prctile(contPdB,91);    
    
    
    CTM.ContFMean{nrow,1}     = nanmean(contF);
    CTM.ContFVar{nrow,1}      = var(contF,'omitnan');
    CTM.ContFStdev{nrow,1}    = nanstd(contF);
    CTM.ContFStderr{nrow,1}   = nanstd(contF)/sqrt(size(contF,1));
    CTM.ContFMedian{nrow,1}   = nanmedian(contF);
    CTM.ContFIQR{nrow,1}      = iqr(contF);
    CTM.ContFpct25{nrow,1}    = prctile(contF,25);
    CTM.ContFpct75{nrow,1}    = prctile(contF,75);
    CTM.ContFpct5{nrow,1}     = prctile(contF,5);
    CTM.ContFpct95{nrow,1}    = prctile(contF,95);
    CTM.ContFpct9{nrow,1}     = prctile(contF,9);
    CTM.ContFpct91{nrow,1}    = prctile(contF,91);
    
    CTM.ContSMean{nrow,1}     = nanmean(contS);
    CTM.ContSVar{nrow,1}      = var(contS,'omitnan');
    CTM.ContSStdev{nrow,1}    = nanstd(contS);
    CTM.ContSStderr{nrow,1}   = nanstd(contS)/sqrt(size(contS,1));
    CTM.ContSMedian{nrow,1}   = nanmedian(contS);
    CTM.ContSIQR{nrow,1}      = iqr(contS);
    CTM.ContSpct25{nrow,1}    = prctile(contS,25);
    CTM.ContSpct75{nrow,1}    = prctile(contS,75);
    CTM.ContSpct5{nrow,1}     = prctile(contS,5);
    CTM.ContSpct95{nrow,1}    = prctile(contS,95);
    CTM.ContSpct9{nrow,1}     = prctile(contS,9);
    CTM.ContSpct91{nrow,1}    = prctile(contS,91);
    
    nrow = nrow+1;
    
    disp([sessionref.ExtractedFile{1} '- ' num2str(n) '/' num2str(size(ref,1))])
    save(fullfile(params.(species).processedDataPath,savename), 'CTM', 'params')

end



catch err
    parseError(err)
    keyboard
end



