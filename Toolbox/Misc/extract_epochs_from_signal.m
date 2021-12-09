function [extracted_epochs, overlapping_idx] = extract_epochs_from_signal(signal, t, win_start, win_length)

%
% extracts epochs from an input signal. Works with time or indices
%
% inputs:
% signal (can be single vector or matrix where each column is a signal)
% t = time vector for signal (or vector of indices)
% win_start  = start time of windows of interest (in seconds or as indices)
% win_length = length of window (in seconds or samples)
%
% returns:
% extracted_epochs   = matrix where each column is an extracted epoch of signal,
%                      multiple input signals separated in 3rd dimension, 
%                      extracted time in last poisition in stack
%
% for windows out of range, extracted epoch will be all NaNs.
%
%overlap
%
try
    if isempty(win_start)
        extracted_epochs = [];
        overlapping_idx  = [];
        return
    end
    
[win_start2,extracted_idx] = check_win_in_range(win_start,win_length, t(end));   % removes any windows out of range 

win_indices(:,1) = interp1(t, 1:length(t),win_start2,'nearest');            % find the indices of the events (so start of the windows of interest)
win_indices(:,2) = interp1(t, 1:length(t),win_start2+win_length,'nearest'); % find the indices of the end of the window


n_events    = length(win_start2);
w = unique(win_indices(:,2)-win_indices(:,1)); % window length in samples; there should only be one output from this otherwise a sampling error has occured
w = w + 1;                                     % plus 1 because adding window length to start index

idx = logical_index_from_PAL_indices(win_indices,length(t));  % create a logical index that can index the input signal

signal = [signal t];

extracted   = signal(idx,:);        % extract windows from signal

% %sanity check plot extracted and expected windows
% figure('WindowStyle', 'docked');
% n = 1;
% subplot(211,'next','add')
% plot(extracted(:,n),'k')
% start_index = @(n,w)((n-1)*(w-1) + (n-1) +1);
% plot(ones(2,n_events).*(start_index(1:n_events,w)),[zeros(1,n_events); ones(1,n_events)]*max(extracted(:,n)),'r--')
% xlabel('Time (s)')
% title('Pre window fix (black = extracted epochs, red = expected window start)')

[extracted,overlapidx] = fix_window_overlap(win_indices,extracted);

% % sanity check plot extracted and expected windows
% n = 1;
% subplot(212,'next','add')
% plot(extracted(:,n),'b')
% plot(ones(2,n_events).*(start_index(1:n_events,w)),[zeros(1,n_events); ones(1,n_events)]*max(extracted(:,n)),'r--')
% title('Post window fix (black = extracted epochs, red = expected window start)')
% xlabel('Time (s)')
% link_axes_in_figure(gcf,'x')


extracted   = reshape(extracted,w,n_events,[]);  % reshape into distinct epochs

% % sanity check plot signal and windows and extracted versions
% n = 1;
% figure('WindowStyle', 'docked');
% subplot(211,'next','add')
% plot(t,signal(:,n),'k')
% plot(t,idx*max(signal(:,n)),'b')
% plot([win_start win_start]',[zeros(length(win_start),1) ones(length(win_start),1)*max(signal(:,n))]','r--')
% xlabel('Time (s)')
% title('black = signal, red = window start, blue = window')
% subplot(212,'next','add')
% plot(extracted(:,:,end),extracted(:,:,n),'k')
% plot([win_start win_start]',[zeros(length(win_start),1) ones(length(win_start),1)*max(max(extracted(:,:,n)))]','r--')
% link_axes_in_figure(gcf,'x')

extracted_epochs = NaN(size(extracted,1), length(win_start),size(extracted,3));  % so output has same number as windows as input
extracted_epochs(:,extracted_idx,:) = extracted;                                 % epochs that could not be extracted are replaced with all NaNs

overlapping_idx = false(length(win_start),1); % so output has same number of elements as input
overlapping_idx(extracted_idx) = overlapidx;
catch err
    parseError(err)
    keyboard
end
    
end




function [win_start, extracted_idx] = check_win_in_range(win_start,win_length,t_end)

check1 = win_start < 0;           % any indices less than zero?
check2 = win_start + win_length > t_end ; % any windows finsh after end of signal?
check3 = isnan(win_start);                % any indices NaN?

not_extracted = check1 | check2 | check3;      % either of above will not be extracted

win_start(not_extracted,:) = [];       % remove windows out of range

extracted_idx = not(not_extracted);

end


function [extracted,check]  = fix_window_overlap(win_indices,extracted)

overlap = win_indices(2:end,1)-win_indices(1:end-1,2);   % (start of window n+1) - (end of window n)

check = overlap <= 0;    % above should be positive if no overlap, gives index of window "n" as defined in line above i.e. first window in overlap
check = [check; false];      % so same length input

if ~any(check)  % return here if no overlap
    return
end

win_overlap_n = find(check); % gives row number of first window in overlapping pairs

w = unique(win_indices(:,2)-win_indices(:,1));  % window length in samples; there should only be one output from this otherwise a sampling error has occured
if numel(w) > 1
    disp('extract_epochs_from_signal.m - window lengths not consistent')
    keyboard
end

w = w + 1;    % plus 1 because adding window length to start index

start_index = @(n,w)((n-1)*(w-1) + (n-1) +1);

for n = 1:length(win_overlap_n)    % brute force fix, overlap by overlap
    
    wins_indicesOI        = win_indices(win_overlap_n(n):win_overlap_n(n)+1,:);  % windows of interest for this loop  
    length_of_joined_wins = wins_indicesOI(2,2) - wins_indicesOI(1,1);
        
    win1_startidx = start_index(win_overlap_n(n),w);     % this is relative to extracted vector
    win1_endidx   = win1_startidx + w - 1;
    win2_endidx   = win1_startidx + length_of_joined_wins;
    win2_startidx = win2_endidx - w + 1;

    missing_segment   = extracted(win2_startidx:win1_endidx,:);
    
    extracted   = [extracted(1:win1_endidx,:)  ; missing_segment;   extracted(win1_endidx+1 : end,:)];

end



end