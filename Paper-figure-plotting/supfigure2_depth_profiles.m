function supfigure2_depth_profiles(species,ID,recside,keepxlabels)

params = get_parameters;
ref    = load_reference_table(species,'incl','neu','level','L5|6','ID',ID);

%% load data
powerFile = 'L5L6_theta_averages.mat';
phaseFile = 'L5L6_theta_phase_shift.mat';
speedFile = 'L5L6_speed_vs_signal.mat';

powerData = load(fullfile(params.(species).processedDataPath,powerFile),'CTM');
phaseData = load(fullfile(params.(species).processedDataPath,phaseFile),'phaseShift');
speedData = load(fullfile(params.(species).processedDataPath,speedFile),'motion_vs_signal');

idside = [ID recside];


phaseidx    = contains(phaseData.phaseShift.IDside,idside) & ~phaseData.phaseShift.MapID==0; % & contains(phaseData.phaseShift.RecType,rectype);
phaseDataID = phaseData.phaseShift(phaseidx,:);

% check mapping, only keep mapped sessions
sessionsidx = ismember(ref.ExtractedFile,phaseDataID.ExtFile);
sessionsref = ref(sessionsidx,:);

poweridx    = contains(powerData.CTM.IDside,idside) & ismember(powerData.CTM.ExtractedFile,sessionsref.ExtractedFile); %  & contains(powerData.CTM.RecType,rectype) 
powerDataID = powerData.CTM(poweridx,:);

speedidx    = ismember(speedData.motion_vs_signal.ExtFile,phaseDataID.ExtFile);
speedDataID = speedData.motion_vs_signal(speedidx,:);

if ~isequal(size(powerDataID,1),size(phaseDataID,1),size(speedDataID,1))
keyboard
end


%% plotting parameters
plotcol = params.col.(ID);
lw = 1;
ylimits = [-0.5 31.5];
yticks  = 5:5:30;
ylabels = 0.5:0.5:3;

switch species
    case 'F'
        xlim1 = [-25 2];
        xtick1 = [-20 -10 0];
        xlim2 = [-0.5 3.3];
        xtick2 = [0 1 2 3];
        xlim3 = [-0.02 0.02];
        xtick3 = [-0.01 0.01];
        xlim4 = [-0.1 0.1];
        xtick4 = [-0.1 0 0.1];
        patchlim = 67;
    case 'R'
         xlim1 = [-15 2];
        xtick1 = [ -10 0];
        xlim2 = [-2 5];
        xtick2 = [-2 0 2 4];
        xlim3 = [-0.02 0.05];
        xtick3 = [0 0.04];
        xlim4 = [-0.1 0.16];
        xtick4 = [-0.1 0.1];
        patchlim = 43;
end

axn = supfigure2_depth_profile_makeFigure;


%% plot histology
plot_neuronexus_electrode_track(axn(1),ID,recside)
title(axn(1),'','position',[0.5 1])


%% plot power
lw1=1;
all_sessions_during_motion_across_probe__power(axn(2),powerDataID,plotcol,lw1,ylimits,yticks,ylabels)
title(axn(2),'')
set(axn(2),'xlim',xlim1,'xtick',xtick1,'xticklabel','')
if ~keepxlabels
   xlabel(axn(2),'') 
else
  set(axn(2),'xlim',xlim1,'xtick',xtick1,'xticklabel',xtick1)  
end

patchw = 0.45;
patchcol = [0.5 0.5 0.5];
patcha = 0.3;

if ~isempty(params.oCL.(idside))
   add_shaded_areas(axn(2), [xlim1(1) patchlim],[params.oCL.(idside)-1-patchw params.oCL.(idside)-1+patchw],patchcol,patcha) % -1 as plotted from 0-31
end
if ~isempty(params.pCL.(idside))
   add_shaded_areas(axn(2), [xlim1(1) patchlim],[params.pCL.(idside)-1-patchw params.pCL.(idside)-1+patchw],patchcol,patcha)
end
if ~isempty(params.rCL.(idside))
   add_shaded_areas(axn(2), [xlim1(1) patchlim],[params.rCL.(idside)-1-patchw params.rCL.(idside)-1+patchw],patchcol,patcha)
end
set(findall(axn(2),'type','patch'),'clipping','off')
uistack(axn(2),'top')
%% plot phase
all_sessions_during_motion_across_probe__phase(axn(3),phaseDataID,plotcol,lw1,ylimits,yticks,ylabels)
title(axn(3),'')
ylabel(axn(3),'')
set(axn(3),'ycolor','none','xlim',xlim2,'xtick',xtick2,'xticklabel','')
if ~keepxlabels
   xlabel(axn(3),'') 
else
    set(axn(3),'xlim',xlim2,'xtick',xtick2,'xticklabel',xtick2)
end

%% plot speed v frequency correlation
pval = 0.0016;
param2plot = 'b1';
xrange = [9.9 55.1];
msize = 10;
all_sessions_during_motion_across_probe__speed_vs_signal(axn(4),speedDataID,{'medianSpeed','medianFreq'},param2plot,xrange,pval,plotcol,msize,lw+0.5,ylimits,yticks,ylabels)
title(axn(4),'')
ylabel(axn(4),'')
zl = plot(axn(4),[0 0],ylimits,'k','linewidth',0.8);
uistack(zl,'bottom')
set(axn(4),'ycolor','none','xlim',xlim3,'xtick',xtick3,'xticklabel','') 
if ~keepxlabels
   xlabel(axn(4),'') 
   else
    xlabel(axn(4),[char(946) '_1'],'Interpreter','tex')
    set(axn(4),'ycolor','none','xlim',xlim3,'xtick',xtick3,'xticklabel',xtick3,'XTickLabelRotation',45) 
end
%% plot speed v power correlation
all_sessions_during_motion_across_probe__speed_vs_signal(axn(5),speedDataID,{'medianSpeed','medianPdB'},param2plot,xrange,pval,plotcol,msize,lw+0.5,ylimits,yticks,ylabels)
title(axn(5),'')
ylabel(axn(5),'')
zl = plot(axn(5),[0 0],ylimits,'k','linewidth',0.8);
uistack(zl,'bottom')
set(axn(5),'ycolor','none','xlim',xlim4,'xtick',xtick4,'xticklabel','')
if ~keepxlabels
   xlabel(axn(5),'') 
else
    xlabel(axn(5),[char(946) '_1'],'Interpreter','tex')
    set(axn(5),'xlim',xlim4,'xtick',xtick4,'xticklabel',xtick4,'XTickLabelRotation',45)

end

font_size_and_color(gcf,7)

set(axn(2:5),'YDir','reverse','ylim',ylimits,'YTick',yticks,...
    'YMinorGrid','on') 


%print(gcf,'-dpdf','-r600','-painters','supfigure2_depth_profile_F1L.pdf')


end







function all_sessions_during_motion_across_probe__power(ax,powdata,plotcol,lw,ylimits,yticks,ylabels)

powMedian = cell2mat(powdata.MovPdBMedian);
maxPow    = max(powMedian,[],2);
normPow   = powMedian - maxPow;

medMedian = nanmedian(normPow);

nchan = size(powMedian,2);

plot(ax,normPow,0:nchan-1,'color',plotcol,'LineWidth',lw)
plot(ax,medMedian,0:nchan-1,'color',[0 0 0 0.8],'LineWidth',lw+0.5)

        
set(ax,'YDir','reverse','ylim',ylimits,'YTick',yticks,'YTickLabel',ylabels,...
    'YMinorGrid','on')  
ylabel(ax,'Depth (mm)')
xlabel(ax,{'Norm. power'; '(dB)'})
end


function all_sessions_during_motion_across_probe__phase(ax,phasedata,plotcol,lw,ylimits,yticks,ylabels)

phasediffs  = cell2mat(phasedata.PhaseDiffMov);
mphasediffs = nanmean(phasediffs);

nchan = size(phasediffs,2);

plot(ax,phasediffs,0:nchan-1,'color',plotcol,'LineWidth',lw)
plot(ax,mphasediffs,0:nchan-1,'color',[0 0 0 0.7],'LineWidth',lw+0.5)

        
set(ax,'YDir','reverse','ylim',ylimits,'YTick',yticks,'YTickLabel',ylabels,...
    'YMinorGrid','on')  
ylabel(ax,'Depth (mm)')
xlabel(ax,{'Phase shift'; 'w.r.t. C1 (rad)'})
end




function all_sessions_during_motion_across_probe__speed_vs_signal(ax,speedData,vars2mdl,param2plot,xrange,pval,plotcol,msize,lw,ylimits,yticks,ylabels)

% ax = axes 
% speedData = table of speed vs signal data;
% vars2mdl = 'medianSpeed','medianFreq','medianPdB', etc
% param2plot = b0, b1 (regression coefficients), r2, corrcoeff r
% xrange = range of x (ie for specifiying speed range >10cm/s & <95th pct
% pval = pval thresh for filling plot point

xrangeIn = cell(size(speedData,1),32);
xrangeIn(:) = {xrange};
vars2mdlIn = cell(size(speedData,1),32);
vars2mdlIn(:) = {vars2mdl};
plotYN = cell(size(speedData,1),32);
plotYN(:) = {false};

[~, fits] = cellfun(@linear_fit_of_table_or_struct_vars,speedData.ChannelData,vars2mdlIn,xrangeIn,plotYN,'uniformoutput',0);

% fits = [b0,b1,r2,pval,   corrcoeff_r,corrcoeff_p];
           %using fitlm      % using corrcoeff
                    
switch param2plot
    case 'b0'
        ncol = 1;
        pcol = 4;
    case 'b1'
        ncol = 2;
        pcol = 4;
    case 'r2'
        ncol = 3;
        pcol = 4;
    case 'corrcoeff_r'
        ncol = 5;
        pcol = 6;
end


medParam = NaN(32,1);
nchan    = size(fits,2);

for nc = 1:nchan
    
    chandata = fits(:,nc);
    chandata = cell2mat(chandata);
    if isempty(chandata)
        continue
    end
    
    sig_idx  = chandata(:,pcol) < pval;   
    sig_vals = chandata(sig_idx,ncol);
    
    scatter(ax,chandata(:,ncol), (nc-1)*ones(length(chandata(:,ncol)),1),msize,'o','MarkerEdgeColor',plotcol)
    
    scatter(ax,sig_vals, (nc-1)*ones(length(sig_vals),1),msize,'o','MarkerEdgeColor',plotcol,'MarkerFaceColor',plotcol)
    
    medParam(nc) = nanmedian(chandata(:,ncol));
    
end

plot(ax,medParam,0:nchan-1,'color',[0 0 0 0.7],'LineWidth',lw)

set(ax,'YDir','reverse','ylim',ylimits,'YTick',yticks,'YTickLabel',ylabels,'YMinorGrid','on')  

xlabel(ax,{param2plot; vars2mdl{1}; 'vs' ; vars2mdl{2}})

end