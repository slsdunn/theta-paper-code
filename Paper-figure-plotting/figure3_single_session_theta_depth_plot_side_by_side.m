function figure3_single_session_theta_depth_plot_side_by_side

params = get_parameters;

%% plotting parameters
lw = 1;
ylimits = [-0.5 31.5];
yticks  = 5:5:30;
ylabels = 0.5:0.5:3;

%% load data
powerFile = 'L5L6_theta_averages.mat';
phaseFile = 'L5L6_theta_phase_shift.mat';
speedFile = 'L5L6_speed_vs_signal.mat';

%% rat data
species = 'R';

r.plotcol = params.col.(species);

r.powerData = load(fullfile(params.(species).processedDataPath,powerFile),'CTM');
r.phaseData = load(fullfile(params.(species).processedDataPath,phaseFile),'phaseShift');
r.speedData = load(fullfile(params.(species).processedDataPath,speedFile),'motion_vs_signal');

r.ID           = 'DBLU';
r.ref          = load_reference_table(species,'incl','neu','level','L5|6','ID',r.ID);
r.session      =  '2017-04-16_16-16-28_CX.mat';
r.sessionref   = r.ref(contains(r.ref.ExtractedFile,r.session),:);
r.powSession   = r.powerData.CTM(contains(r.powerData.CTM.ExtractedFile,r.session),:);
r.phaseSession = r.phaseData.phaseShift(contains(r.phaseData.phaseShift.ExtFile,r.session),:);
r.speedSession = r.speedData.motion_vs_signal(contains(r.speedData.motion_vs_signal.ExtFile,r.session),:);
r.startpoint = 1590000;% other options 3323850, 832620
r.win = 500;  

%% ferret data
species = 'F';

f.plotcol = params.col.(species);

f.powerData = load(fullfile(params.(species).processedDataPath,powerFile),'CTM');
f.phaseData = load(fullfile(params.(species).processedDataPath,phaseFile),'phaseShift');
f.speedData = load(fullfile(params.(species).processedDataPath,speedFile),'motion_vs_signal');

f.ID           = 'BEA';
f.ref          = load_reference_table(species,'incl','neu','level','L5|6','ID',f.ID,'recside','L');
% f.session      =  'BEA_Block10-16_2015-08-12T15-17_LHS_CX.mat';
% f.sessionref   = f.ref(contains(f.ref.ExtractedFile,f.session),:);
 f.nsession = 5;
 f.sessionref = f.ref(f.nsession,:);
f.powSession   = f.powerData.CTM(contains(f.powerData.CTM.ExtractedFile,f.sessionref.ExtractedFile),:);
f.phaseSession = f.phaseData.phaseShift(contains(f.phaseData.phaseShift.ExtFile,f.sessionref.ExtractedFile),:);
f.speedSession = f.speedData.motion_vs_signal(contains(f.speedData.motion_vs_signal.ExtFile,f.sessionref.ExtractedFile),:);
f.startpoint = 240500;%663734;
f.win = 500;  




%% plot

axn = figure3_single_session_theta_side_by_side_makeFigure;

%% rat
%% plot histology
plot_neuronexus_electrode_track(axn(1),r.sessionref.ID{1},r.sessionref.RecSide{1})
title(axn(1),'')

%% plot filtered signal
[~] = plot_segment_of_signal_across_channels(axn(2),r.sessionref,'mov','thetafilt',r.startpoint,r.win,[],r.plotcol,lw,ylimits,yticks,ylabels);
title(axn(2),{'Theta'; 'filtered'},'Position',[0.5 1])
plot(axn(2), [0.05 0.25],[33 33],'linewidth',1.5,'color','k')
plot(axn(2), [-0.05 -0.05],[29 31],'linewidth',1.5,'color','k')
set(axn(2),'xcolor','none','ycolor','none','clipping','off','xlim',[0 0.5])
text(axn(2),0.17,34,'200 ms')

%% plot power
plot_single_session_during_motion_across_probe__power(axn(3),r.powSession,r.plotcol,lw,ylimits,yticks,ylabels)
title(axn(3),{'Theta'; 'power'},'Position',[0.5 1])
ylabel(axn(3),'')
set(axn(3),'yticklabel',[],'ycolor','none','xlim',[-21 4.2],'xtick',[-20 -10 0])

%% plot phase
plot_single_session_during_motion_across_probe__phase(axn(4),r.phaseSession,r.plotcol,lw,ylimits,yticks,ylabels)
title(axn(4),{'Theta'; 'phase'},'Position',[0.5 1])
ylabel(axn(4),'')
set(axn(4),'yticklabel',[],'ycolor','none','xlim',[-0.52 4.8],'xtick',[0 2 4])

%% plot speed v frequency correlation
pval = 0.05/32;
param2plot = 'b1';
xrange = [9.9 55.1];
plot_all_sessions_during_motion_across_probe__speed_vs_signal(axn(5),r.speedSession,{'medianSpeed','medianFreq'},param2plot,xrange,pval,r.plotcol,lw,ylimits,yticks,ylabels)
title(axn(5),{'Speed vs' 'freq.'},'Position',[0.5 1])
ylabel(axn(5),'')
xlabel(axn(5),'\beta_{1}','Interpreter','tex')
zl = plot(axn(5),[0 0],ylimits,'k','linewidth',0.5);
uistack(zl,'bottom')
set(axn(5),'ycolor','none','xlim',[-0.0075 0.0375],'xtick',[0 0.02],'XTickLabelRotation',45)

%% plot speed v power correlation
plot_all_sessions_during_motion_across_probe__speed_vs_signal(axn(6),r.speedSession,{'medianSpeed','medianPdB'},param2plot,xrange,pval,r.plotcol,lw,ylimits,yticks,ylabels)
title(axn(6),{'pow.'},'Position',[0.5 1])
ylabel(axn(6),'')
xlabel(axn(6),'\beta_{1}','Interpreter','tex')
set(axn(6),'ycolor','none','xlim',[-0.035 0.085],'xtick',[-0.02 0 0.02 0.04 0.06 0.08],'xticklabel',{'','0','','','0.06','' },'XTickLabelRotation',45)
zl = plot(axn(6),[0 0],ylimits,'k','linewidth',0.5);
uistack(zl,'bottom')


set(axn(2:6),'YDir','reverse','ylim',ylimits,'YTick',yticks,...
    'YMinorGrid','on') 

patchlim = 67;
patchw = 0.45;
patchcol = [0.5 0.5 0.5];
patcha = 0.3;

add_shaded_areas(axn(3), [-21 patchlim],[params.oCL.(r.sessionref.IDside{1})-1-patchw params.oCL.(r.sessionref.IDside{1})-1+patchw],patchcol,patcha) % -1 as plotted from 0-31
add_shaded_areas(axn(3), [-21 patchlim],[params.pCL.(r.sessionref.IDside{1})-1-patchw params.pCL.(r.sessionref.IDside{1})-1+patchw],patchcol,patcha)
add_shaded_areas(axn(3), [-21 patchlim],[params.rCL.(r.sessionref.IDside{1})-1-patchw params.rCL.(r.sessionref.IDside{1})-1+patchw],patchcol,patcha)

set(findall(axn(3),'type','patch'),'clipping','off')
uistack(axn(3),'top')

%% ferret
%% plot histology
plot_neuronexus_electrode_track(axn(7),f.sessionref.ID{1},f.sessionref.RecSide{1})
title(axn(7),'')

%% plot filtered signal
[~] = plot_segment_of_signal_across_channels(axn(8),f.sessionref,'mov','thetafilt',f.startpoint,f.win,[],f.plotcol,lw,ylimits,yticks,ylabels);
title(axn(8),{'Theta'; 'filtered'},'Position',[0.5 1])
set(axn(8),'xcolor','none','clipping','off','ycolor','none','xlim',[0 0.5])
plot(axn(8), [0.05 0.25],[33 33],'linewidth',1.5,'color','k')
plot(axn(8), [-0.05 -0.05],[29 31],'linewidth',1.5,'color','k')
text(axn(8),0.17,34,'200 ms')

%% plot power
plot_single_session_during_motion_across_probe__power(axn(9),f.powSession,f.plotcol,lw,ylimits,yticks,ylabels)
title(axn(9),{'Theta'; 'power'},'Position',[0.5 1])
ylabel(axn(9),'')
set(axn(9),'yticklabel',[],'ycolor','none','xlim',[-17 4],'xtick',[-15  0])

%% plot phase
plot_single_session_during_motion_across_probe__phase(axn(10),f.phaseSession,f.plotcol,lw,ylimits,yticks,ylabels)
title(axn(10),{'Theta'; 'phase'},'Position',[0.5 1])
ylabel(axn(10),'')
set(axn(10),'yticklabel',[],'ycolor','none','xlim',[-0.52 3.45],'xtick',[0 3])

%% plot speed v frequency correlation
pval = 0.0016;
param2plot = 'b1';
xrange = [9.9 55.1];
plot_all_sessions_during_motion_across_probe__speed_vs_signal(axn(11),f.speedSession,{'medianSpeed','medianFreq'},param2plot,xrange,pval,f.plotcol,lw,ylimits,yticks,ylabels)
title(axn(11),{'Speed vs'; 'freq.'},'Position',[0.5 1])
ylabel(axn(11),'')
zl = plot(axn(11),[0 0],ylimits,'k','linewidth',0.8);
uistack(zl,'bottom')
set(axn(11),'ycolor','none','xlim',[-0.0075 0.015],'xtick',[0 0.01],'XTickLabel',{'0','0.01'},'XTickLabelRotation',45)
xlabel(axn(11),'\beta_{1}','Interpreter','tex')


%% plot speed v power correlation
plot_all_sessions_during_motion_across_probe__speed_vs_signal(axn(12),f.speedSession,{'medianSpeed','medianPdB'},param2plot,xrange,pval,f.plotcol,lw,ylimits,yticks,ylabels)
title(axn(12),{''; 'pow.'},'Position',[0.5 1])
ylabel(axn(12),'')
xlabel(axn(12),'')
set(axn(12),'ycolor','none','xlim',[-0.065 0.11],'xtick',[-0.02 0 0.02 0.04 0.06 0.08],'XTickLabelRotation',45,'XTickLabel',{'','0','','','','0.08' })
zl = plot(axn(12),[0 0],ylimits,'k','linewidth',0.8);
uistack(zl,'bottom')
xlabel(axn(12),'\beta_{1}','Interpreter','tex')

set(axn(8:12),'YDir','reverse','ylim',ylimits,'YTick',yticks,...
    'YMinorGrid','on') 


patchlim = 56.5;
patchw = 0.45;
patchcol = [0.5 0.5 0.5];
patcha = 0.3;

add_shaded_areas(axn(9), [-17 patchlim],[params.oCL.(f.sessionref.IDside{1})-1-patchw params.oCL.(f.sessionref.IDside{1})-1+patchw],patchcol,patcha) % -1 as plotted from 0-31
add_shaded_areas(axn(9), [-17 patchlim],[params.pCL.(f.sessionref.IDside{1})-1-patchw params.pCL.(f.sessionref.IDside{1})-1+patchw],patchcol,patcha)
add_shaded_areas(axn(9), [-17 patchlim],[params.rCL.(f.sessionref.IDside{1})-1-patchw params.rCL.(f.sessionref.IDside{1})-1+patchw],patchcol,patcha)

set(findall(axn(9),'type','patch'),'clipping','off')
uistack(axn(9),'top')


font_size_and_color(gcf,8)

keyboard

%print(gcf,'-dpdf','-r600','-painters','figure3_depth_MATLABoutput.pdf')