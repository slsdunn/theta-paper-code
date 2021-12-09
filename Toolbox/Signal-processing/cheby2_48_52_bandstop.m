function [Hd,f_info] = cheby2_48_52_bandstop
%IIR_48_52_BANDSTOP Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 9.9 and DSP System Toolbox 9.11.
% Generated on: 18-Mar-2021 16:33:48

% Chebyshev Type II Bandstop filter designed using FDESIGN.BANDSTOP.

% All frequency values are in Hz.
f_info.Fs = 1000;  % Sampling Frequency

f_info.Fpass1 = 46;          % First Passband Frequency
f_info.Fstop1 = 48;          % First Stopband Frequency
f_info.Fstop2 = 52;          % Second Stopband Frequency
f_info.Fpass2 = 54;          % Second Passband Frequency
f_info.Apass1 = 0.5;         % First Passband Ripple (dB)
f_info.Astop  = 80;          % Stopband Attenuation (dB)
f_info.Apass2 = 1;           % Second Passband Ripple (dB)
f_info.match  = 'stopband';  % Band to match exactly
f_info.type   = 'cheby2';

% Construct an FDESIGN object and call its CHEBY2 method.
h  = fdesign.bandstop(f_info.Fpass1, f_info.Fstop1, f_info.Fstop2, f_info.Fpass2, f_info.Apass1, f_info.Astop, ...
                      f_info.Apass2, f_info.Fs);
Hd = design(h, 'cheby2', 'MatchExactly', f_info.match);

f_info.order = filtord(Hd.sosMatrix);
f_info.stable = isstable(Hd);
% [EOF]
