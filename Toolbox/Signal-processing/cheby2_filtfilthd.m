function [flt, f_info] = cheby2_filtfilthd(signal,flt_desc,edge_remove)

%
% flt_desc = '1_highpass', '2_highpass', '2_8_bandpass', '4_13_bandpass',
% '49_51_bandstop', '48_52_bandstop'
% Filters made with MATLAB filter designer
%

% create filter
[Hd, f_info] = eval(['cheby2_' flt_desc]);

if ~isstable(Hd)
    disp('unstable IIR filter')
    keyboard
end

% prep data
if size(signal,1) == 1
  signal = transpose(signal);
end
nanidx = isnan(signal);
signal = fillmissing(signal,'linear','EndValues','nearest');

% filter using filtfilthd
flt = filtfilthd(Hd,signal);

% check power (if unstable eg with filtfilt error, filtered signal will
% have more power than raw signal)
% p1 = mean(signal.^2);
% p2 = mean(flt.^2);

% if any(p2>p1)
%     disp('something suspicious with cheby2')
%     keyboard
% end

% remove interps and edges (if requested)
if ~isempty(edge_remove)
    nanidx(1,:)   = 1;   % to get edges
    nanidx(end,:) = 1;
    nanidx = extend_logical_indices(nanidx,edge_remove); % filter already extends NaNs by forder/2 so just need to remove another f_order/2
    f_info.edge_remove = edge_remove;
end
flt(nanidx) = NaN;