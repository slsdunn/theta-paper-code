function scalefactor = plot_trace_across_chans(ax1, signal, varargin)

%
% scalefactor = plot_trace_across_chans(ax1, signal, varargin)
% name pair inputs: xvec,yvec,zval,,scalefactor,color,linewidth, linestyle
% 

% Soraya Dunn 2020

if ndims(signal) > 2 %#ok<*ISMAT> % supress suggestion
    signal = squeeze(signal);
    if ndims(signal) > 2
        disp('cannot use plot_trace_across_chans.m with more than 2 dimensions')
        return
    end
end

% set default parameters
defaultX  = 1:size(signal,1);
defaultY  = flip(1:size(signal,2));
defaultSF = calc_scale_factor(signal);
defaultC  = 'k';
defaultLW = 1;
defaultLS = '-';
defaultZ = [];

% parse inputs
p = inputParser;
addRequired(p,'ax1')
addRequired(p,'signal');
addParameter(p,'xvec',defaultX);
addParameter(p,'yvec',defaultY);
addParameter(p,'scalefactor',defaultSF)
addParameter(p,'color',defaultC)
addParameter(p,'linewidth',defaultLW)
addParameter(p,'linestyle',defaultLS)
addParameter(p,'zval',defaultZ)

parse(p,ax1,signal,varargin{:});

% set parameters
xvec = p.Results.xvec;
yvec = p.Results.yvec;
scalefactor = p.Results.scalefactor;
col = p.Results.color;
linewidth = p.Results.linewidth;
linestyle = p.Results.linestyle;
zval = p.Results.zval;

if numel(zval) == 1
    zval = zval*ones(size(signal,1),1);
end

% create figure if necessary
if isempty(ax1)
    figure
    ax1 = axes('next','add');
end
set(ax1,'next','add')


% plot
nchans = size(signal,2);

if isnumeric(col)
    if size(col,1) == 1
        col = repmat(col,nchans,1);
    end
else 
    C    = cell(nchans,1);
    C(:) = {col};
    col  = C;
end

for j = 1:nchans
    chan_to_plot = signal(:,j) - nanmedian(signal(:,j));
    col4line     = col(j,:);
    if iscell(col4line)
        col4line = col4line{1};
    end
    if isempty(zval)
    plot(ax1,xvec,(chan_to_plot*scalefactor)+yvec(j),'color',col4line, 'Linewidth',linewidth,'Linestyle',linestyle);
    else
    plot3(ax1,xvec,(chan_to_plot*scalefactor)+yvec(j),zval,'color',col4line, 'Linewidth',linewidth,'Linestyle',linestyle);    
    end
end

end


function scalefactor = calc_scale_factor(signal)
%posidx    = signal > 0;
% chans_neg = signal;
% chans_neg(posidx)=NaN;
% med_neg = nanmedian(chans_neg,1);
% chans_pos = signal;
% chans_pos(~posidx)=NaN;
% med_pos = nanmedian(chans_pos,1);
%meds = med_pos-med_neg;
meds = nanmedian(abs(signal));
max_diff = max(meds);
scalefactor = 1/max_diff;
end