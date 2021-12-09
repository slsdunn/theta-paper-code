function [maxPoint, minPoint, minChange] = findMinMax(signal, thresh, varargin)

%
% code adapted from http://nocurve.com/virtual-lab/finding-peaks-and-troughs-in-a-noisy-curve/
%
% input: 
% signal = vector 
% thresh = value between 0-1, used to define yvalue range over which local extrema are detected (as % of signal median)
%		   chosen empirically, I typically use 0.25
% varargin = thresh_type = 'fixed', for when you want a fixed threshold, not one calc using median
%
% output:
% maxPoint  = maxima sample number and value
% minPoint  = minima sample number and value
% minChange = y value range for local extrema detection
%
% Soraya Dunn 2017
%

if nargin > 2
    thresh_type = varargin{1};
    switch thresh_type
        case 'fixed'
            A=1;
    end
else
    A = nanmedian(abs(signal));
end
minChange = A * thresh;


lookingFor = 1;
localMaxY = [];
localMinY = [];
localMaxYx =[];
localMinYx = [];
nmin = 1;
nmax = 1;
minPoint = NaN(numel(signal),2);
maxPoint = NaN(numel(signal),2);

if isnan(signal(1))
	nextMaxY = signal(find(~isnan(signal),1))+minChange;
	nextMinY = signal(find(~isnan(signal),1))-minChange;   
else
	nextMaxY = signal(1)+minChange;
	nextMinY = signal(1)-minChange;
end

for x = 1:length(signal)
    y = signal(x);
    
    if y>nextMaxY
        if lookingFor == 1
            %% added 08/02/21 to fix bug where no local min found - found when quantifying EMU xcorrs 
            if isempty(localMinY)
                lookingFor = 0;
                continue
            end
            %%
            minPoint(nmin,:) = [localMinYx, localMinY];
            nmin = nmin + 1;
        end
        nextMinY = y - minChange;
        nextMaxY = y + minChange;
        lookingFor = 0; % look for minimum, but save highest until we find it
        localMaxY = y;  % reset the local highest
        localMaxYx = x;
    end
    if localMaxY<=y
        localMaxY  = y;
        localMaxYx = x;
    end
    
    if y<nextMinY
        if lookingFor == 0 
            %% added 08/02/21 to fix bug where no local max found - found when quantifying EMU xcorrs 
            if isempty(localMaxY)
                lookingFor = 1;
                continue
            end
            %%
            maxPoint(nmax,:) = [localMaxYx, localMaxY];
            nmax = nmax + 1;
        end
        nextMaxY = y + minChange;
        nextMinY = y - minChange;
        lookingFor = 1; % look for maximum, but save lowest until we find it
        localMinY = y; % reset the local lowest
        localMinYx = x;
    end
    if localMinY>=y
        localMinY = y;
        localMinYx = x;
    end
end

minPoint(isnan(minPoint(:,1)),:) = [];
maxPoint(isnan(maxPoint(:,1)),:) = [];
