function stdshade(AX,amatrix,alpha,acolor,F,smth, varargin)
% usage: stdshading(amatrix,alpha,acolor,F,smth)
% plot mean and sem/std coming from a matrix of data, at which each row is an
% observation. sem/std is shown as shading.
% - acolor defines the used color (default is red)
% - F assignes the used x axis (default is steps of 1).
% - alpha defines transparency of the shading (default is no shading and black mean line)
% - smth defines the smoothing factor (default is no smooth)
% smusall 2010/4/23

% varargin to do circular calculations

if exist('acolor','var')==0 || isempty(acolor)
    acolor='r';
end

if isempty(AX)
    figure;
    AX = axes('next','add');
end

if exist('F','var')==0 || isempty(F);
    F=1:size(amatrix,2);
end

if exist('smth','var'); if isempty(smth); smth=1; end
else smth=1;
end

if ne(size(F,1),1)
    F=F';
end
if nargin == 6
    if any(any(isnan(amatrix)))
        amean=smooth(nanmean(amatrix),smth)';
        astd=nanstd(amatrix); % to get std shading
        
        nanidx = isnan(amean);
        nans = find(nanidx);
        nanidx(nans+1) = 1;
        if any(nans==1)
            nans(nans==1)=[];   % because cant have 0 idx
        end
        nanidx(nans-1) = 1;
        
        nanidx = nanidx(1:length(amean)); % incase the +1 goes out of bounds
        
        amean = simpleNaNInterp(amean);
        astd  = simpleNaNInterp(astd);
        
        tocoverm = amean(nanidx);
        tocovers = astd(nanidx);
        tocoverx = F(nanidx);
    else
        amean=smooth(mean(amatrix),smth)';
        astd=std(amatrix); % to get std shading
       % astd=astd/size(amatrix,1); 
    end
else % do circular
    
    amean = circ_mean(amatrix);
    astd = circ_std(amatrix);
end

%astd=std(amatrix)/sqrt(size(amatrix,1)); % to get sem shading

if exist('alpha','var')==0 || isempty(alpha)
    fill(AX,[F fliplr(F)],[amean+astd fliplr(amean-astd)],acolor,'linestyle','none');
    acolor='k';
else
    fill(AX,[F fliplr(F)],[amean+astd fliplr(amean-astd)],acolor, 'FaceAlpha', alpha,'linestyle','none');
end


if ishold==0
    check=true; else check=false;
end

hold on;plot(AX,F,amean,'color',acolor,'linewidth',1.5); %% change color or linewidth to adjust mean line

if exist('tocoverm','var')
    fill(AX,[tocoverx fliplr(tocoverx)],[tocoverm+tocovers fliplr(tocoverm-tocovers)],[1 1 1],'linestyle','none');
end

if check
    hold off;
end


end



