function plot_lines_with_color_gradient(ax1, dataIn, varargin)

%
% Plots lines from columns of dataIn matrix with colour gradient
%
% Name-pair arguments:
% xvec
% yvec
% colormap
% alpha
% linewidth
% orientation
% colorbar
%
% Soraya Dunn 2019
%

nLines      = size(dataIn,2);
nDataPoints = size(dataIn,1);

% set default parameters
defaultX  = 1:nDataPoints;
defaultY  = 1:nDataPoints;
defaultC  = turbo(nLines);
defaultA  = 1;
defaultLW = 1;
defaultO  = 'horizontal';
defaultCB = false;

% parse inputs
p = inputParser;
addRequired(p,'ax1')
addRequired(p,'dataIn');
addParameter(p,'xvec',defaultX);
addParameter(p,'yvec',defaultY);
addParameter(p,'colormap',defaultC);
addParameter(p,'alpha',defaultA);
addParameter(p,'linewidth',defaultLW);
addParameter(p,'orientation',defaultO);
addParameter(p,'colorbar',defaultCB);

parse(p,ax1,dataIn,varargin{:});

% set parameters
x    = p.Results.xvec;
y    = p.Results.yvec;
cols = p.Results.colormap;
alpha= p.Results.alpha;
lw   = p.Results.linewidth;
orientation = p.Results.orientation;
cbstatus    = p.Results.colorbar;


if isempty(ax1)
    figure
    ax1 = axes('next','add');
end
set(ax1,'next','add')

switch orientation
    case 'horizontal'
        for n = 1:nLines
            plot(ax1,x,dataIn(:,n),'color',[cols(n,:) alpha],'linewidth',lw);
        end
    case 'vertical'
        for n = 1:nLines
            plot(ax1,dataIn(:,n),y,'color',[cols(n,:) alpha],'linewidth',lw);
        end
end
colormap(ax1,cols)
if nLines>1
set(ax1,'clim',[1 nLines])
end

if cbstatus
    colorbar
end
% cbh = colorbar('peer', AxesH, 'h', ...
%                'XTickLabel',{'-12','-9','-6','-3','0','3','6','9','12'}, ...
%                'XTick', -12:3:12)