function trackingOut = interp_tracking_to_neural_timeline(sessionref,metadata,trackingIn,t_tracking,t_neural)


switch sessionref.RecType{1}
    case 'T'
        % for tethered recordings, just interp over tethered timeline
        trackingOut = interp1(t_tracking,trackingIn,t_neural); % interpolate
       
    case 'W'
        % for wireless, MCS recordings start before and end after tracking, need to NaN pad start and end of speed trace
        % metadata contains startelay info 
        
        t_temp      = transpose(t_tracking(1) : 1/1000 : t_tracking(end));
        trackingOut = interp1(t_tracking,trackingIn,t_temp); % interpolate over temp timeline that has same SR as wireless rec
          
        startDelayIdx = interp1(t_neural,1:length(t_neural),metadata.MCS_startdelay+t_tracking(1),'nearest');  % add first tracking timestamp to shift as is not 0
        
        tline_diff = length(t_neural) - (length(trackingOut) + startDelayIdx);
        
        if tline_diff > 0
            trackingOut = [NaN(startDelayIdx,1); trackingOut; NaN(tline_diff,1)];
        elseif tline_diff < 0
            trackingOut = [NaN(startDelayIdx,1); trackingOut(1:end + tline_diff)];
            disp([sessionref.ExtractedFile{1} ' - had to cut a little bit of speed trace off end'])
        elseif tline_diff == 0
            trackingOut = [NaN(startDelayIdx,1); trackingOut];
        else 
            keyboard
        end
end


end