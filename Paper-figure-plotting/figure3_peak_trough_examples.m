function figure3_peak_trough_examples


params = get_parameters;

%% rat data
r.ID           = 'DBLU';
r.ref          = load_reference_table('R','incl','neu','level','L5|6','ID',r.ID);
r.session      =  '2017-04-16_16-16-28_CX.mat';
r.sessionref   = r.ref(contains(r.ref.ExtractedFile,r.session),:);

r.mdata = load_metadata(r.sessionref);
r.cdata = load_neural_mapped(r.sessionref,r.mdata,r.mdata.maxThetaChanMapped,'cleansignal');
r.cdata = cheby2_filtfilthd(r.cdata,'1_highpass',1000);
r.flt   = filter_signal(r.cdata,1000,'BP',params.R.theta_bandwidth,params.R.theta_filtOrder);
r.t_neu = load_neural_timeline(r.mdata);
r.speed = load_tracking_speed(r.sessionref,r.mdata, r.t_neu);

[r.ifreq,r.iphase,r.ipower,r.reconstructed, ~] = calculate_peak_trough_signal_parameters(r.flt.signal,params.PT_thresh_pc,r.t_neu);

r.movidx = r.speed > params.speedThresh.moving;

r.movdata = r.cdata;
r.movdata(~r.movidx)= NaN;

[r.pxx,r.fxx] = nanpwelch(r.movdata,hanning(1024),0.5,1000);
r.pxxdB = 10*log10(r.pxx/(max(r.pxx)));

r.startidx = 1589800;% other options 3323850, 832620
r.winlength = 1000;
r.examplet    = r.t_neu(r.startidx:r.startidx+r.winlength-1);
r.exampledata = r.cdata(r.startidx:r.startidx+r.winlength-1);
r.exampleflt  = r.flt.signal(r.startidx:r.startidx+r.winlength-1);
r.examplepha  = r.iphase(r.startidx:r.startidx+r.winlength-1);
r.exampleamp  = sqrt(r.ipower(r.startidx:r.startidx+r.winlength-1));
r.examplef    = r.ifreq(r.startidx:r.startidx+r.winlength-1);

r.examplePT   = extract_rows_within_range(r.reconstructed{1},1,[r.startidx r.startidx+r.winlength-1]);

r.spectdata = r.cdata(r.startidx-r.winlength:r.startidx+(2*r.winlength)-1);
r.spectt    = r.t_neu(r.startidx-r.winlength:r.startidx+(2*r.winlength)-1);
r.freqrange = [2 14];
r.spectf    = r.freqrange(1):(1000/(length(r.spectdata)-1)):r.freqrange(2);
[~,r.spectF,r.spectT,r.spectP]  = spectrogram(r.spectdata,1024,(6/8)*1024,r.spectf,1000);
[r.spectPdB] = 10*log10(r.spectP/max(max(r.spectP)));
r.spectT = r.spectT + r.spectt(1);


%% ferret data
f.ref = load_reference_table('F','level','L5|6','incl','neu','ID','BEA','recside','L');
 f.nsession = 5;
 f.sessionref = f.ref(f.nsession,:);
% f.session      =  'BEA_Block10-16_2015-08-12T15-17_LHS_CX.mat';
% f.sessionref   = f.ref(contains(f.ref.ExtractedFile,f.session),:);

f.mdata = load_metadata(f.sessionref);

f.cdata = load_neural_mapped(f.sessionref,f.mdata,f.mdata.maxThetaChanMapped,'cleansignal');
f.cdata = cheby2_filtfilthd(f.cdata,'1_highpass',1000);
f.flt   = filter_signal(f.cdata,1000,'BP',params.F.theta_bandwidth,params.F.theta_filtOrder);
f.t_neu = load_neural_timeline(f.mdata);
f.speed = load_tracking_speed(f.sessionref,f.mdata, f.t_neu);

[f.ifreq,f.iphase,f.ipower,f.reconstructed, ~] = calculate_peak_trough_signal_parameters(f.flt.signal,params.PT_thresh_pc,f.t_neu);

f.movidx = f.speed > params.speedThresh.moving;

f.movdata = f.cdata;
f.movdata(~f.movidx)= NaN;

[f.pxx,f.fxx] = nanpwelch(f.movdata,hanning(1024),0.5,1000);
f.pxxdB = 10*log10(f.pxx/(max(f.pxx)));

f.startidx = 481000;%1126040;
f.winlength = 1000;
f.examplet    = f.t_neu(f.startidx:f.startidx+f.winlength-1);
f.exampledata = f.cdata(f.startidx:f.startidx+f.winlength-1);
f.exampleflt  = f.flt.signal(f.startidx:f.startidx+f.winlength-1);
f.examplepha  = f.iphase(f.startidx:f.startidx+f.winlength-1);
f.exampleamp  = sqrt(f.ipower(f.startidx:f.startidx+f.winlength-1));
f.examplef    = f.ifreq(f.startidx:f.startidx+f.winlength-1);

f.examplePT   = extract_rows_within_range(f.reconstructed{1},1,[f.startidx f.startidx+f.winlength-1]);

f.spectdata = f.cdata(f.startidx-f.winlength:f.startidx+(2*f.winlength)-1);
f.spectt    = f.t_neu(f.startidx-f.winlength:f.startidx+(2*f.winlength)-1);
f.freqrange = [2 14];
f.spectf    = f.freqrange(1):(1000/(length(f.spectdata)-1)):f.freqrange(2);
[~,f.spectF,f.spectT,f.spectP]  = spectrogram(f.spectdata,1024,(6/8)*1024,f.spectf,1000);
[f.spectPdB] = 10*log10(f.spectP/max(max(f.spectP)));
f.spectT = f.spectT + f.spectt(1);


%% plot
axn = figure3_peak_trough_examples_makeFigure;
title(axn,'')

%% plot rat
% plot PSD
add_shaded_areas(axn(1),[6 13],[-35 0],params.col.R,0.25)
plot(axn(1),r.fxx,r.pxxdB,'color',params.col.R,'LineWidth',1);
set(axn(1),'xscale','log','xlim',[1.5 120],'ylim',[-32 0],'ytick',[-30 -20 -10],'xtick',[10 100],'XTickLabel',[10 100])
ylabel(axn(1),'Norm. power (dB/Hz)')
xlabel(axn(1),'Frequency (Hz)')

% plot signal/filtered
plot(axn(2),r.examplet,r.exampledata,'color',[0.1 0.1 0.1 0.5],'LineWidth',0.7)
plot(axn(2),r.examplet,r.exampleflt,'color',params.col.R,'LineWidth',1.2)
plot(axn(2),r.examplet,r.exampleamp,'color','k','LineWidth',1)
plotXYlines(axn(2),r.t_neu(r.examplePT(:,1)),'linewidth',0.5,'linestyle',':', 'color',[0.5 0.5 0.5],'lineExtent',[-1.3 1])
set(axn(2),'xlim',[r.examplet(1) r.examplet(end)],'XColor','none','ytick',[-0.8 0 0.8],'clipping','off','ylim',[-1.2 1])
ylabel(axn(2),{'Amp.'; '(mV)'})

% plot phase
plot(axn(3),r.examplet,r.examplepha,'k','LineWidth',1)
set(axn(3),'xlim',[r.examplet(1) r.examplet(end)],'XColor','none','ytick',[0 180 360],'ylim',[-80 440],'YTickLabel',{'0'; char(960); ['2' char(960)]})
plotXYlines(axn(3),r.t_neu(r.examplePT(:,1)),'linewidth',0.5,'linestyle',':', 'color',[0.5 0.5 0.5])
ylabel(axn(3),{'Phase'; '(r)'})

% plot freq
r.sf = surf(axn(4),r.spectT,r.spectF,r.spectPdB,'EdgeColor','none');
plot3(axn(4),r.examplet,r.examplef,ones(size(r.examplef)),'k','LineWidth',1)
plot(axn(4),[r.examplet(1)+0.1 r.examplet(1)+0.2],[0.5 0.5],'k','LineWidth',1.5,'Clipping','off')
text(axn(4),r.examplet(1)+0.05,-2.5,'100 ms','FontName','arial','FontSize',8)
set(axn(4),'xlim',[r.examplet(1) r.examplet(end)],'clim',[-25 0],'ytick',[5 10],'Xcolor','none','ylim',r.freqrange)
ylabel(axn(4),{'Freq.'; '(Hz)'})
cb = colorbar(axn(4),'location','southoutside');
cb.Position = [0.4631    0.5943    0.0311    0.0228];
cb.Label.String = {'Norm. pow.'; '(dB/Hz)'};
title(axn,'')


r.lregf = plot_example_session_motion_vs_signal(axn(5),r.sessionref,r.mdata.maxThetaChanMapped,'freq','speed',250,params.col.R,0.5,1);
text(axn(5),25, 3.5,{['b_1 = ' num2str(r.lregf.b(2),'%3.1e')];['R^2 = ' num2str(r.lregf.stats(1),'%.2f')] ; ['p = ' num2str(r.lregf.stats(3),'%3.1e')]},'FontSize',7,'FontName','Arial','interpreter','tex')
xlabel(axn(5),'Speed (cms^{-1})','Interpreter','tex')
ylabel(axn(5),'Frequency (Hz)')

r.lregp = plot_example_session_motion_vs_signal(axn(6),r.sessionref,r.mdata.maxThetaChanMapped,'PdB','speed',250,params.col.R,0.5,1);
text(axn(6),25, -25,{['b_1 = ' num2str(r.lregp.b(2),'%3.1e')];['R^2 = ' num2str(r.lregp.stats(1),'%.2f')] ; ['p = ' num2str(r.lregp.stats(3),'%3.1e')]},'FontSize',7,'FontName','Arial','interpreter','tex')
xlabel(axn(6),'Speed (cms^{-1})','Interpreter','tex')
ylabel(axn(6),'Power (dB)')

%% plot ferret
% plot PSD
add_shaded_areas(axn(7),[4 7],[-35 0],params.col.F,0.25)
plot(axn(7),f.fxx,f.pxxdB,'color',params.col.F,'LineWidth',1);
set(axn(7),'xscale','log','xlim',[1.5 120],'ylim',[-28 0],'ytick',[-30 -20 -10],'xtick',[10 100],'XTickLabel',[10 100])
ylabel(axn(7),'Norm. power (dB/Hz)')
xlabel(axn(7),'Frequency (Hz)')

% plot signal/filtered
plot(axn(8),f.examplet,f.exampledata,'color',[0.1 0.1 0.1 0.5],'LineWidth',0.7)
plot(axn(8),f.examplet,f.exampleflt,'color',params.col.F,'LineWidth',1.2)
plot(axn(8),f.examplet,f.exampleamp,'color','k','LineWidth',1)
plotXYlines(axn(8),f.t_neu(f.examplePT(:,1)),'linewidth',0.5,'linestyle',':', 'color',[0.5 0.5 0.5],'lineExtent',[-0.7 0.5])
set(axn(8),'xlim',[f.examplet(1) f.examplet(end)],'XColor','none','ytick',[-0.4 0 0.4],'clipping','off','ylim',[-0.5 0.5])
ylabel(axn(8),{'Amp.'; '(mV)'})

% plot phase
plot(axn(9),f.examplet,f.examplepha,'k','LineWidth',1)
set(axn(9),'xlim',[f.examplet(1) f.examplet(end)],'XColor','none','ytick',[0 180 360],'ylim',[-80 440],'YTickLabel',{'0'; char(960); ['2' char(960)]})
plotXYlines(axn(9),f.t_neu(f.examplePT(:,1)),'linewidth',0.5,'linestyle',':', 'color',[0.5 0.5 0.5])
ylabel(axn(9),{'Phase'; '(r)'})

% plot freq
f.sf = surf(axn(10),f.spectT,f.spectF,f.spectPdB,'EdgeColor','none');
plot3(axn(10),f.examplet,f.examplef,ones(size(f.examplef)),'k','LineWidth',1)
plot(axn(10),[f.examplet(1)+0.1 f.examplet(1)+0.2],[0.5 0.5],'k','LineWidth',1.5,'Clipping','off')
text(axn(10),f.examplet(1)+0.05,-2.5,'100 ms','FontName','arial','FontSize',8)
set(axn(10),'xlim',[f.examplet(1) f.examplet(end)],'clim',[-25 0],'ytick',[5 10],'Xcolor','none','ylim',f.freqrange)
ylabel(axn(10),{'Freq.'; '(Hz)'})
cb = colorbar(axn(10),'location','southoutside');
cb.Position = [0.9611    0.5943    0.0311    0.0228];
cb.Label.String = {'Norm. pow.'; '(dB/Hz)'};
title(axn,'')


f.lregf = plot_example_session_motion_vs_signal(axn(11),f.sessionref,f.mdata.maxThetaChanMapped,'freq','speed',250,params.col.F,0.5,1);
text(axn(11),25, 3.5,{['b_1 = ' num2str(f.lregf.b(2),'%3.1e')];['R^2 = ' num2str(f.lregf.stats(1),'%.2f')] ; ['p = ' num2str(f.lregf.stats(3),'%3.1e')]},'FontSize',7,'FontName','Arial','interpreter','tex')
xlabel(axn(11),'Speed (cms^{-1})','Interpreter','tex')
ylabel(axn(11),'Frequency (Hz)')

f.lregp = plot_example_session_motion_vs_signal(axn(12),f.sessionref,f.mdata.maxThetaChanMapped,'PdB','speed',250,params.col.F,0.5,1);
text(axn(12),25, -25,{['b_1 = ' num2str(f.lregp.b(2),'%3.1e')];['R^2 = ' num2str(f.lregp.stats(1),'%.2f')] ; ['p = ' num2str(f.lregp.stats(3),'%3.1e')]},'FontSize',7,'FontName','Arial','interpreter','tex')
xlabel(axn(12),'Speed (cms^{-1})','Interpreter','tex')
ylabel(axn(12),'Power (dB)')

font_size_and_color(gcf,8)

%print(gcf,'-dpdf','-r600','-painters','figure2_peak_trough_examples.pdf')