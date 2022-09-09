function  motion_vs_signal = motion_vs_signal_across_channels(species,speed_or_acc,savename)
try
    
    ref      = load_reference_table(species,'incl','neu','level','L5|6');
    params   = get_parameters;
    savepath = params.(species).processedDataPath;
    
    motion_vs_signal = table;
    nrow = 1;
    
    stop_table_warnings;
    
    for ns = 1:size(ref,1)
        
        sessionref = ref(ns,:);
        
        %% load data
        mdata = load_metadata(sessionref);
        cdata = load_neural_mapped(sessionref,mdata,'all','cleansignal');
        flt   = filter_signal(cdata,1000,'BP',params.(species).theta_bandwidth, params.(species).theta_filtOrder);
        t_neu = load_neural_timeline(sessionref);
        speed = load_tracking_speed(sessionref,mdata,t_neu);
        acc   = diff(speed) / (1/1000);  % in cm/s^2 (deltaV/deltaT, speed above upsampled to 1k (to match neural))
        
        %% for each channel, compare speed (or acceleration) with signal
        nchans = size(cdata,2);
        
        switch speed_or_acc
            case 'acc'
                discretize_step = 10;
                motion_range = -10000:discretize_step:10000;       % wide enough to definitely contain all values
                varnames = {'Acc','Speed','Freq','P','Pz','PdB'};
            case 'speed'
                discretize_step = 5;
                motion_range = 0:discretize_step:1000;
                varnames = {'Speed','Acc','Freq','P','Pz','PdB'};
        end
        
        params.motion_discretize_step = discretize_step;
        params.motion_type = speed_or_acc;
        
        [ifreq,~,ipower,~, ~] = calculate_peak_trough_signal_parameters(flt.signal,params.PT_thresh_pc,t_neu);
        ipowerZ  = nanzscore(ipower,1);
        ipowerdB = 10*log10(ipower);
        
        for nc = 1: nchans
            
            if all(isnan(flt.signal(:,nc)))
                continue
            end
            
            svs_in = sort_out_trace_length_and_put_in_matrix(speed,acc,ifreq(:,nc),ipower(:,nc),ipowerZ(:,nc),ipowerdB(:,nc),speed_or_acc);
            
            if isempty(svs_in)
                continue
            end
            
            binned = bin_data_wrt_first_col(svs_in, motion_range, varnames);
            
            motion_vs_signal.ID(nrow,1)           = sessionref.ID;
            motion_vs_signal.RecSide(nrow,1)      = sessionref.RecSide;
            motion_vs_signal.IDside(nrow,1)       = sessionref.IDside;
            motion_vs_signal.RecType(nrow,1)      = sessionref.RecType;
            motion_vs_signal.MapID(nrow,1)        = mdata.mapID;
            motion_vs_signal.ExtFile(nrow,1)      = sessionref.ExtractedFile;
            motion_vs_signal.ChannelData(nrow,nc) = {binned};
            
        end
        
        nrow = nrow+1;
        disp([sessionref.ExtractedFile{1} ': ' num2str(ns) '/' num2str(size(ref,1))])
       
    end
    
    save(fullfile(savepath, savename),'params','motion_vs_signal')
    
catch err
    err
    keyboard
end
end




function out = sort_out_trace_length_and_put_in_matrix(speed,acc,F,P1,P2,P3,speed_or_acc)
switch speed_or_acc
    case 'speed'
        out(:,1) = speed(1:end-1);
        out(:,2) = acc;
    case 'acc'
        out(:,1) = acc;
        out(:,2) = speed(1:end-1);
end
out(:,3) = F(1:end-1);
out(:,4) = P1(1:end-1);
out(:,5) = P2(1:end-1);
out(:,6) = P3(1:end-1);

end

