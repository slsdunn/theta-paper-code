function extrema = clean_peaks_and_troughs(signal, peaks,troughs)
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

