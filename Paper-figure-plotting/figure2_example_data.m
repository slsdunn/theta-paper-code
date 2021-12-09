function figure2_example_data

trialwin = 2;
tshift   = 1;

%% rat data 
% rID = 'ERED';
% nsession = 5;
% rntrial = 17;

% rID = 'DBLU';
% nsession = 15;
% rntrial = 14;

rID = 'ERED';
nsession = 8;
rntrial = 9;

rref  = load_reference_table('R','ID',rID,'incl','neu','level','L5|6');
rsref = rref(nsession,:);

rmdata  = load_metadata(rsref);
rcdata  = load_neural_mapped(rsref,rmdata,'all','cleansignal');
rcdata  = cheby2_filtfilthd(rcdata,'2_highpass',1000);
rt_neu  = load_neural_timeline(rmdata);
[rx,ry] = load_tracking_location(rsref,rmdata,rt_neu);
rspeed  = load_tracking_speed(rsref,rmdata,rt_neu);

rtrials  = load_trials_table(rsref,'raw');


rtrial2plot = rtrials(rntrial,:);

rtrialdata  = extract_epochs_from_signal(rcdata,rt_neu,rtrial2plot.HoldEnd-trialwin+tshift,trialwin*2);
rtrialx     = extract_epochs_from_signal(rx,rt_neu,rtrial2plot.HoldEnd-trialwin+tshift,trialwin*2);
rtrialy     = extract_epochs_from_signal(ry,rt_neu,rtrial2plot.HoldEnd-trialwin+tshift,trialwin*2);
rtrialspeed = extract_epochs_from_signal(rspeed,rt_neu,rtrial2plot.HoldEnd-trialwin+tshift,trialwin*2);


%% ferret data 
% fID = 'KIW';
% recside = 'L';
% nsession = 3;
% fntrial = 10;

%  fID = 'BEA';
%  recside = 'L';
%  nsession = 3;
%  fntrial = 15;

 fID = 'BEA';
 recside = 'R';
 nsession = 3;
 fntrial = 15;

fref  = load_reference_table('F','ID',fID,'recside',recside,'incl','neu','level','L5|6');
fsref = fref(nsession,:);

fmdata  = load_metadata(fsref);
fcdata  = load_neural_mapped(fsref,fmdata,'all','cleansignal');
fcdata  = cheby2_filtfilthd(fcdata,'1_highpass',1000);
ft_neu  = load_neural_timeline(fmdata);
[fx,fy] = load_tracking_location(fsref,fmdata,ft_neu);
fspeed  = load_tracking_speed(fsref,fmdata,ft_neu);

ftrials  = load_trials_table(fsref);

ftrial2plot = ftrials(fntrial,:);

ftrialdata  = extract_epochs_from_signal(fcdata,ft_neu,ftrial2plot.HoldEnd-trialwin+tshift,trialwin*2);
ftrialx     = extract_epochs_from_signal(fx,ft_neu,ftrial2plot.HoldEnd-trialwin+tshift,trialwin*2);
ftrialy     = extract_epochs_from_signal(fy,ft_neu,ftrial2plot.HoldEnd-trialwin+tshift,trialwin*2);
ftrialspeed = extract_epochs_from_signal(fspeed,ft_neu,ftrial2plot.HoldEnd-trialwin+tshift,trialwin*2);


%% plot
axn = figure2_example_data_makeFigure;
clm = [-1 3.5];
% rat
plot_neuronexus_electrode_track(axn(1),rID,'R')
title(axn(1),'')
xl = xlim(axn(1));
yl = ylim(axn(1));

plot(axn(2),rx,ry,'color',[0.5 0.5 0.5 0.2],'clipping','off')
%plot_line_with_varying_color(axn(2),rtrialx(:,1,1),rtrialy(:,:,1),rtrialspeed(:,:,1),'linewidth',1.5) % color varies with speed
plot_line_with_varying_color(axn(2),rtrialx(:,1,1),rtrialy(:,:,1),rtrialspeed(:,1,2)-rtrial2plot.HoldEnd,'linewidth',1.5) % color varies with time
set(axn(2),'XColor','none','YColor','none','CLim',clm,'XLimSpec', 'Tight','ydir','reverse')
set(axn(2),'ylim',xlim(axn(2))-20)
title(axn(2),'')
colormap(magma)

%plot_line_with_varying_color(axn(3),rtrialspeed(:,1,2)-rtrial2plot.HoldEnd,rtrialspeed(:,1,1),rtrialspeed(:,:,1)) % color varies with speed
plot_line_with_varying_color(axn(3),rtrialspeed(:,1,2)-rtrial2plot.HoldEnd,rtrialspeed(:,1,1),rtrialspeed(:,1,2)-rtrial2plot.HoldEnd)  % color varies with time

title(axn(3),'')
set(axn(3),'CLim',clm,'xticklabel','','ytick',[0 50],'XLimSpec', 'Tight')
ylabel(axn(3),'Speed (cms^{-1})','Interpreter','tex')
cb1 = colorbar(axn(3),'Position',[0.45    0.89    0.0156    0.059],'xtick',[0 3]);
cb1.Title.Interpreter = 'tex';
cb1.Title.String = 'Time post-stimulus (s)';
%title(axn(3),[rsref.ExtractedFolder{1} ' trial ' num2str(rntrial)],'position',[0.5 1])

plot_trace_across_chans(axn(4),squeeze(rtrialdata(:,1,1:32)),'xvec',squeeze(rtrialdata(:,1,33))-rtrial2plot.HoldEnd,'scalefactor',0.7,'linewidth',0.75)
title(axn(4),'')
set(axn(4),'YColor','none','XLim', [-1 3],'Ylim',[0 33])
xlabel(axn(4),'Time (s)')
line(axn(4),[3.15 3.15],[1 3],'linewidth',2,'clipping','off','color','k')
text(axn(4),3.165,3.67,['200 ' char(181) 'm'],'Rotation',90)

linkaxes([axn(3) axn(4)],'x')

% ferret
plot_neuronexus_electrode_track(axn(5),fID,recside)
title(axn(5),'')

plot(axn(6),fx,fy,'color',[0.5 0.5 0.5 0.5],'clipping','off')
%plot_line_with_varying_color(axn(6),ftrialx(:,1,1),ftrialy(:,:,1),ftrialspeed(:,:,1),'linewidth',1.5)
plot_line_with_varying_color(axn(6),ftrialx(:,1,1),ftrialy(:,:,1),ftrialspeed(:,1,2)-ftrial2plot.HoldEnd,'linewidth',1.5)
set(axn(6),'YDir','reverse','XColor','none','YColor','none','CLim',clm,'XLimSpec', 'Tight','YLimSpec', 'Tight')
title(axn(6),'')
colormap(magma)

%plot_line_with_varying_color(axn(7),ftrialspeed(:,1,2)-ftrial2plot.HoldEnd,ftrialspeed(:,1,1),ftrialspeed(:,:,1))
plot_line_with_varying_color(axn(7),ftrialspeed(:,1,2)-ftrial2plot.HoldEnd,ftrialspeed(:,1,1),ftrialspeed(:,1,2)-ftrial2plot.HoldEnd)
title(axn(7),'')
set(axn(7),'CLim',clm,'xticklabel','','ytick',[0 50],'XLimSpec', 'Tight')
ylabel(axn(7),'Speed (cms^{-1})','Interpreter','tex')
cb2 = colorbar(axn(7),'Position',[0.9106   0.89    0.0156    0.059],'xtick',[0 3]);
cb2.Title.Interpreter = 'tex';
cb2.Title.String = 'Time post-stimulus (s)';
%title(axn(7),[fsref.ExtractedFolder{1} ' trial ' num2str(fntrial)],'position',[0.5 1])

plot_trace_across_chans(axn(8),squeeze(ftrialdata(:,1,1:32)),'xvec',squeeze(ftrialdata(:,1,33))-ftrial2plot.HoldEnd,'scalefactor',0.8,'linewidth',0.75)
title(axn(8),'')
set(axn(8),'YColor','none','XLim', [-1 3],'Ylim',[0 33])
xlabel(axn(8),'Time (s)')
line(axn(8),[3.15 3.15],[1 3],'linewidth',2,'clipping','off','color','k')
text(axn(8),3.165,3.67,['200 ' char(181) 'm'],'Rotation',90)

linkaxes([axn(7) axn(8)],'x')

font_size_and_color(gcf,8)

params = get_parameters;
text(axn(1),118,-150,params.lbl.(rID),'color',params.col.R,'fontname','arial','fontsize',8,'FontWeight','bold')
text(axn(5),118,-150,params.lbl.(fID),'color',params.col.F,'fontname','arial','fontsize',8,'FontWeight','bold')

keyboard

%print(gcf,'-dpdf','-r600','-painters','figure2_example_data.pdf')
