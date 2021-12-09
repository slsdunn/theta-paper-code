function out = filter_signal(signal, SR, ftype, fw, f_order)
%
% filters trace using 1D fir filter 
% vector/matrix containing signal (channel per column)
% SR = signal sample rate 
% ftype = 'HP','LP' or 'BP'
% fw = filter width eg [5 12]
% f_order = filter order, input [] for default which is SR/2
%

if size(signal,1) == 1
  signal = transpose(signal);
end

if strcmp(f_order,'6c') % filter order so contains 6 cycles
    %f_order = round(SR/2);
    f_order = round(6*SR/fw(1));
end

switch ftype
    case 'BP'
        b = fir1(f_order,fw/(SR/2),'bandpass');
    case 'BS'
        b = fir1(f_order,fw/(SR/2),'stop');      
    case 'HP'
        b = fir1(f_order, fw/(SR/2),'high');
    case 'LP'
        b = fir1(f_order, fw/(SR/2),'low');
end

%fvtool(b,1)  % view filter
flt = filter(b,1,signal);

filterDelay = mean(grpdelay(b));  % https://uk.mathworks.com/help/signal/ug/compensate-for-delay-and-distortion-introduced-by-filters.html

flt(1:round(filterDelay),:) = [];          % delete first part so zero lag (done as described on page above)
flt(size(flt,1)+1:size(signal,1),:) = NaN; % NaN pad so same length as input

nanidx = isnan(flt); % remove any potential edge artefacts by removing window of length fitler order from any discontinuites
nanidx(1,:)   = 1;   % to get edges
nanidx(end,:) = 1;
nanidx2 = extend_logical_indices(nanidx,f_order/2); % filter already extends NaNs by forder/2 so just need to remove another f_order/2

flt(nanidx2) = NaN;

out.fw      = fw;
out.f_order = f_order;
out.f_type  = ftype;
out.signal  = flt;
out.SR      = SR;
out.f_delay = filterDelay;
