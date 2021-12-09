function [threshold, h] = find_thresholds_using_histogram(ax1,input,binW, mult,thresh_method, plotYN)


if plotYN
    if isempty(ax1)
        fig = figure;
        ax1 = axes('next','add');
    end
else
    fig = figure;
    ax1 = axes('next','add');
    set(fig, 'visible','off')
end

if isempty(binW)
    h = histogram(ax1,input);
else
    h = histogram(ax1,input,'BinWidth',binW);
end

switch thresh_method
    case 'median'
        
        threshold.param = nanmedian(input);
        threshold.mult = mult;
        threshold.thresh = threshold.param*mult;
        
        
    case 'mode'
                
        [~,mi]=max(h.Values);
        threshold.param = h.BinEdges(mi+1);
        threshold.mult = mult;
        threshold.thresh = threshold.param*mult;
        
    case 'neg_exp'
        pd = fitdist(input,'exponential');
        xx=1:10000;
        yy = exp(-xx/pd.mu);
        yyy = find(yy<0.000005);
        threshold.thresh = xx(yyy(1));
        
end

if plotYN
    yplot = ylim(ax1);
    yplot = [0.00000001 yplot(2)];
    plot(ax1,[threshold.thresh, threshold.thresh],yplot)
else    
 close(fig)
end


end