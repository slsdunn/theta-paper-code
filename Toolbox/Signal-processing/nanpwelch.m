function [pxx, fxx] = nanpwelch(signal,window,noverlap,Fs)

%
% [pxx, fxx] = nanpwelch(signal,window,noverlap,Fs)
%
% signal = real vector/matrix (matrix input calc PSD for each column)
% window = eg hanning(1024)
% noverlap = proportion of overlap (between 0&1)
% Fs = sample frequency of signal
%
% nfft is always same length as window
%
% modified from code here:
% https://uk.mathworks.com/matlabcentral/answers/33653-psd-estimation-fft-vs-welch
%
%
% Soraya Dunn 2021
%

if(size(signal,1)==1)
    signal = transpose(signal);
end

nwindow       = length(window);
nsamp_overlap = round(noverlap*nwindow);
NumUniquePts  = nwindow/2+1; 

fxx = (0:NumUniquePts-1)*Fs/nwindow;
pxx = NaN(NumUniquePts,size(signal,2));

for n = 1:size(signal,2)
       
    buffersignal = buffer(signal(:,n),nwindow,nsamp_overlap);
    nanidx       = any(isnan(buffersignal));
    
    buffersignal(:,nanidx)=[];  % remove any segments with NaNs
    
    if isempty(buffersignal)
        continue
    end
    
    win_signal = window.*buffersignal; % Window data
    
    % Calculate power
    winsig_fft = fft(win_signal,nwindow);
    winsig_power = abs(winsig_fft).^2;
    % Normalize by window power. Multiply by 2 (except DC & Nyquist)
    % to calculate one-sided spectrum. Divide by Fs to calculate
    % spectral  density.
    winsig_power = winsig_power./(window'*window);

    winsig_power = winsig_power(1:NumUniquePts,:);
    winsig_power(2:end-1,:) = winsig_power(2:end-1,:)*2;
    Pxx1 = winsig_power./Fs;
    pxx(:,n) = mean(Pxx1,2);
end

