function figure6_trials

params = get_parameters;

alldata = readtable(fullfile(params.figDataPath,'figure6trials.csv'));
alldata = alldata(alldata.Correct==1&~alldata.NanIdx&alldata.RwdWinIdx,:);

%% ferret
f.ID = 'BEAL';
f.ref = load_reference_table('F','ID',f.ID(1:3),'incl','neu','level','L5|6');
f.ref = f.ref(contains(f.ref.IDside,f.ID),:);
f.xcfft = load_results_tables(f.ref,'xcorr_trial_epochs',1:32,params);
f.oCL   = params.oCL.(f.ID);
f.rCL   = params.rCL.(f.ID);

% example session
f.session = 'BEA_Block10-53_2015-09-24T09-40';
f.sref = f.ref(contains(f.ref.ExtractedFile,f.session),:);
f.sxcfft = load_results_tables(f.sref,'xcorr_trial_epochs',1:32,params);
f.mdata = load_metadata(f.sref);
f.cdata = load_neural_mapped(f.sref,f.mdata,[f.oCL,f.rCL],'cleansignal');
f.flt_desc = {'1_highpass';'49_51_bandstop'};
f.cdata = cheby2_filtfilthd(f.cdata,f.flt_desc{1},1000);
f.cdata = cheby2_filtfilthd(f.cdata,f.flt_desc{2},1000);
f.t_neu = load_neural_timeline(f.mdata);
f.speed = load_tracking_speed(f.sref,f.mdata,f.t_neu);

% example trial
f.xcoCL   = f.sxcfft{f.oCL};
f.xcrCL  = f.sxcfft{f.rCL};
f.goodtrialidx = ~f.xcoCL.NaN_trial_idx & f.xcoCL.Rwd_win_idx & f.xcoCL.Correct & ~f.xcrCL.NaN_trial_idx & f.xcrCL.Rwd_win_idx;
f.xcoCL = f.xcoCL(f.goodtrialidx,:);
f.xcrCL = f.xcrCL(f.goodtrialidx,:);
f.ntrial = 12;

f.egxcoCL   = f.xcoCL(f.ntrial,:);
f.egxcrCL  = f.xcrCL(f.ntrial,:);
f.trialIdx(1) = interp1(f.t_neu,1:length(f.t_neu),f.egxcrCL.HoldStart-1,'nearest'); % take window 1 s beore hold start to 1 s after reward win end
f.trialIdx(2) = f.egxcrCL.Rwd_win_start + 2024;
f.holdwin(1)  = f.egxcrCL.HoldEnd-params.xcorr.win_seconds-params.trial_ext.holdshift;
f.holdwin(2)  = f.egxcrCL.HoldEnd-params.trial_ext.holdshift;
f.runwin(1)   = f.egxcrCL.RespTime-params.xcorr.win_seconds;
f.runwin(2)   = f.egxcrCL.RespTime;
f.rwdwin(1)   = interp1(1:length(f.t_neu),f.t_neu,f.egxcrCL.Rwd_win_start,'nearest'); % tak
f.rwdwin(2)   = f.rwdwin(1) + params.xcorr.win_seconds;

f.trialspeed = f.speed(f.trialIdx(1):f.trialIdx(2));
f.trialoCL    = f.cdata(f.trialIdx(1):f.trialIdx(2),1);
f.trialrCL   = f.cdata(f.trialIdx(1):f.trialIdx(2),2);
f.trialt     = f.t_neu(f.trialIdx(1):f.trialIdx(2));

f.oCLhold = extract_epochs_from_signal(f.trialoCL,f.trialt,f.holdwin(1),params.xcorr.win_seconds);
f.oCLrun  = extract_epochs_from_signal(f.trialoCL,f.trialt,f.runwin(1),params.xcorr.win_seconds);
f.oCLrwd  = extract_epochs_from_signal(f.trialoCL,f.trialt,f.rwdwin(1),params.xcorr.win_seconds);

f.rCLhold = extract_epochs_from_signal(f.trialrCL,f.trialt,f.holdwin(1),params.xcorr.win_seconds);
f.rCLrun  = extract_epochs_from_signal(f.trialrCL,f.trialt,f.runwin(1),params.xcorr.win_seconds);
f.rCLrwd  = extract_epochs_from_signal(f.trialrCL,f.trialt,f.rwdwin(1),params.xcorr.win_seconds);

[f.oCLXC, f.oCLxcTbl] = quantify_xcorr_epochs([f.oCLhold(:,:,1) f.oCLrun(:,:,1) f.oCLrwd(:,:,1)],params.xcorr.F.freq_range,params.xcorr.freqResolution);
[f.rCLXC, f.rCLxcTbl] = quantify_xcorr_epochs([f.rCLhold(:,:,1) f.rCLrun(:,:,1) f.rCLrwd(:,:,1)],params.xcorr.F.freq_range,params.xcorr.freqResolution);

% all trials
f.alltrials = alldata(contains(alldata.ID,f.ID(1:3))&contains(alldata.Recside,f.ID(4)),:);
f.alltrials_rCL = f.alltrials(contains(f.alltrials.Chan,'rad'),:);
f.alltrials_rCl_hold = f.alltrials_rCL(contains(f.alltrials_rCL.Epoch,'Hold'),:);
f.alltrials_rCl_run = f.alltrials_rCL(contains(f.alltrials_rCL.Epoch,'Run'),:);
f.alltrials_rCl_rwd = f.alltrials_rCL(contains(f.alltrials_rCL.Epoch,'Rwd'),:);

% reference sine ac
t = 0:1/1000:1 - 1/1000;
f.holdsinxc = xcorr(sin(2*pi*f.rCLxcTbl.freq(1)*t),sin(2*pi*f.rCLxcTbl.freq(1)*t));
f.holdsinxc = f.holdsinxc/max(f.holdsinxc);
f.runsinxc = xcorr(sin(2*pi*f.rCLxcTbl.freq(2)*t),sin(2*pi*f.rCLxcTbl.freq(2)*t));
f.runsinxc = f.runsinxc/max(f.runsinxc);
f.rwdsinxc = xcorr(sin(2*pi*f.rCLxcTbl.freq(3)*t),sin(2*pi*f.rCLxcTbl.freq(3)*t));
f.rwdsinxc = f.rwdsinxc/max(f.rwdsinxc);

%% rat
r.ID    = 'DBLUR';
r.ref   = load_reference_table('R','ID',r.ID(1:4),'incl','neu','level','L5|6');
r.xcfft = load_results_tables(r.ref,'xcorr_trial_epochs',1:32,params);
r.oCL   = params.oCL.(r.ID);
r.rCL   = params.rCL.(r.ID);

% example session
r.session = '2017-04-18_14-24-12';
r.sref = r.ref(contains(r.ref.ExtractedFile,r.session),:);
r.sxcfft = load_results_tables(r.sref,'xcorr_trial_epochs',1:32,params);
r.mdata = load_metadata(r.sref);
r.cdata = load_neural_mapped(r.sref,r.mdata,[r.oCL,r.rCL],'cleansignal');
r.flt_desc = {'2_highpass';'49_51_bandstop'};
r.cdata = cheby2_filtfilthd(r.cdata,r.flt_desc{1},1000);
r.cdata = cheby2_filtfilthd(r.cdata,r.flt_desc{2},1000);
r.t_neu = load_neural_timeline(r.mdata);
r.speed = load_tracking_speed(r.sref,r.mdata,r.t_neu);

% example trial
r.xcoCL   = r.sxcfft{r.oCL};
r.xcrCL  = r.sxcfft{r.rCL};
r.goodtrialidx = ~r.xcoCL.NaN_trial_idx & r.xcoCL.Rwd_win_idx & r.xcoCL.Correct & ~r.xcrCL.NaN_trial_idx & r.xcrCL.Rwd_win_idx;
r.xcoCL = r.xcoCL(r.goodtrialidx,:);
r.xcrCL = r.xcrCL(r.goodtrialidx,:);
r.ntrial = 18;

r.egxcoCL     = r.xcoCL(r.ntrial,:);
r.egxcrCL     = r.xcrCL(r.ntrial,:);
r.trialIdx(1) = interp1(r.t_neu,1:length(r.t_neu),r.egxcrCL.HoldStart-1,'nearest'); % take window 1 s beore hold start to 1 s after reward win end
r.trialIdx(2) = r.egxcrCL.Rwd_win_start + 2024;
r.holdwin(1)  = r.egxcrCL.HoldEnd-params.xcorr.win_seconds-params.trial_ext.holdshift;
r.holdwin(2)  = r.egxcrCL.HoldEnd-params.trial_ext.holdshift;
r.runwin(1)   = r.egxcrCL.RespTime-params.xcorr.win_seconds;
r.runwin(2)   = r.egxcrCL.RespTime;
r.rwdwin(1)   = interp1(1:length(r.t_neu),r.t_neu,r.egxcrCL.Rwd_win_start,'nearest'); % tak
r.rwdwin(2)   = r.rwdwin(1) + params.xcorr.win_seconds;

r.trialspeed = r.speed(r.trialIdx(1):r.trialIdx(2));
r.trialoCL    = r.cdata(r.trialIdx(1):r.trialIdx(2),1);
r.trialrCL   = r.cdata(r.trialIdx(1):r.trialIdx(2),2);
r.trialt     = r.t_neu(r.trialIdx(1):r.trialIdx(2));

r.oCLhold = extract_epochs_from_signal(r.trialoCL,r.trialt,r.holdwin(1),params.xcorr.win_seconds);
r.oCLrun  = extract_epochs_from_signal(r.trialoCL,r.trialt,r.runwin(1),params.xcorr.win_seconds);
r.oCLrwd  = extract_epochs_from_signal(r.trialoCL,r.trialt,r.rwdwin(1),params.xcorr.win_seconds);

r.rCLhold = extract_epochs_from_signal(r.trialrCL,r.trialt,r.holdwin(1),params.xcorr.win_seconds);
r.rCLrun  = extract_epochs_from_signal(r.trialrCL,r.trialt,r.runwin(1),params.xcorr.win_seconds);
r.rCLrwd  = extract_epochs_from_signal(r.trialrCL,r.trialt,r.rwdwin(1),params.xcorr.win_seconds);

[r.oCLXC, r.oCLxcTbl] = quantify_xcorr_epochs([r.oCLhold(:,:,1) r.oCLrun(:,:,1) r.oCLrwd(:,:,1)],params.xcorr.R.freq_range,params.xcorr.freqResolution);
[r.rCLXC, r.rCLxcTbl] = quantify_xcorr_epochs([r.rCLhold(:,:,1) r.rCLrun(:,:,1) r.rCLrwd(:,:,1)],params.xcorr.R.freq_range,params.xcorr.freqResolution);

% all trials
r.alltrials = alldata(contains(alldata.ID,r.ID(1:4))&contains(alldata.Recside,r.ID(5)),:);
r.alltrials_rCL = r.alltrials(contains(r.alltrials.Chan,'rad'),:);
r.alltrials_rCl_hold = r.alltrials_rCL(contains(r.alltrials_rCL.Epoch,'Hold'),:);
r.alltrials_rCl_run = r.alltrials_rCL(contains(r.alltrials_rCL.Epoch,'Run'),:);
r.alltrials_rCl_rwd = r.alltrials_rCL(contains(r.alltrials_rCL.Epoch,'Rwd'),:);

% reference sine ac
r.holdsinxc = xcorr(sin(2*pi*r.rCLxcTbl.freq(1)*t),sin(2*pi*r.rCLxcTbl.freq(1)*t));
r.holdsinxc = r.holdsinxc/max(r.holdsinxc);
r.runsinxc = xcorr(sin(2*pi*r.rCLxcTbl.freq(2)*t),sin(2*pi*r.rCLxcTbl.freq(2)*t));
r.runsinxc = r.runsinxc/max(r.runsinxc);
r.rwdsinxc = xcorr(sin(2*pi*r.rCLxcTbl.freq(3)*t),sin(2*pi*r.rCLxcTbl.freq(3)*t));
r.rwdsinxc = r.rwdsinxc/max(r.rwdsinxc);

%% plot 
axn = figure6_makeFigure;

holdcol = [0.3 0.3 0.3];
runcol1  = params.col.R;
runcol2  = params.col.F;
rwdcol  = [111,12,90]/255; %[0,0.6,0.5];
shadealpha = 0.15;
aclinecol  = 'k'; % light green: [0.50,0.78,0.25]; 

%% rat example trial
add_shaded_areas(axn(1),r.holdwin,[0 100],holdcol,shadealpha)
add_shaded_areas(axn(1),r.runwin,[0 100],runcol1 ,shadealpha)
add_shaded_areas(axn(1),r.rwdwin,[0 100],rwdcol,shadealpha)
plot(axn(1),r.trialt,r.trialspeed,'k','LineWidth',1.5)
set(axn(1),'XTickLabel','','ytick',[0 50],'ylim',[-1 90],'xlim',[3936.3 3942.6])
ylabel(axn(1),{'Speed';'(cms^{-1})'},'interpreter','tex')

%plot_trace_across_chans(axn(2),[r.trialCL,r.trialdCL],'xvec',r.trialt,'color',params.col.R,'scalefactor',1)
add_shaded_areas(axn(2),r.holdwin,[-1.2 1.2],holdcol,shadealpha)
add_shaded_areas(axn(2),r.runwin,[-1.2 1.2],runcol1,shadealpha)
add_shaded_areas(axn(2),r.rwdwin,[-1.2 1.2],rwdcol,shadealpha)
plot(axn(2),r.trialt,r.trialrCL,'color',params.col.R)
set(axn(2),'XTickLabel','','ylim',[-1.1 1.1],'xcolor','none','YTick',[-0.5 0 0.5],'xlim',[3936.3 3942.6])
line(axn(2),[r.trialt(end)-1.5 r.trialt(end)-0.5],[-1.175 -1.175],'color','k','linewidth',1.5,'clipping','off')
text(axn(2),3941.7, -1.4289,'1 sec')
ylabel(axn(2),{'Amplitude';'(mV)'})
linkaxes([axn(1) axn(2)],'x')

% rat example autocorrs
plot(axn(3),r.holdsinxc(ceil(size(r.holdsinxc,2)/2):end),'color',[0.3 0.3 0.3 0.5],'LineWidth',0.8,'LineStyle','-')
plot(axn(3),r.rCLXC(ceil(size(r.rCLXC,1)/2):end,1),'color',holdcol,'LineWidth',1.5)
plotXYlines(axn(3),r.rCLxcTbl.peak1i(1)-ceil(size(r.rCLXC,1)/2),'color',aclinecol,'lineExtent',[mean([r.rCLxcTbl.trough1(1), r.rCLxcTbl.trough2(1)]) r.rCLxcTbl.peak1(1)],'linestyle','-')
line(axn(3),[650 850],[-0.75 -0.75],'color','k','linewidth',1.5,'clipping','off')
text(axn(3),500,-1.24,'200 ms')
set(axn(3),'ylim',[-1 1],'ytick',[-1 0 1],'xcolor','none')

plot(axn(4),r.runsinxc(ceil(size(r.runsinxc,2)/2):end),'color',[0.3 0.3 0.3 0.5],'LineWidth',0.8,'LineStyle','-')
plot(axn(4),r.rCLXC(ceil(size(r.rCLXC,1)/2):end,2),'color',runcol1,'LineWidth',1.5)
plotXYlines(axn(4),r.rCLxcTbl.peak1i(2)-ceil(size(r.rCLXC,1)/2),'color',aclinecol,'lineExtent',[mean([r.rCLxcTbl.trough1(2), r.rCLxcTbl.trough2(2)]) r.rCLxcTbl.peak1(2)],'linestyle','-')
line(axn(4),[650 850],[-0.75 -0.75],'color','k','linewidth',1.5,'clipping','off')
text(axn(4),500,-1.24,'200 ms')
set(axn(4),'YTickLabel','','ylim',[-1 1],'ytick',[-1 0 1],'xcolor','none')
plot(axn(5),r.rwdsinxc(ceil(size(r.rwdsinxc,2)/2):end),'color',[0.3 0.3 0.3 0.5],'LineWidth',0.8,'LineStyle','-')
plot(axn(5),r.rCLXC(ceil(size(r.rCLXC,1)/2):end,3),'color',rwdcol,'LineWidth',1.5)
plotXYlines(axn(5),r.rCLxcTbl.peak1i(3)-ceil(size(r.rCLXC,1)/2),'color',aclinecol,'lineExtent',[mean([r.rCLxcTbl.trough1(3), r.rCLxcTbl.trough2(3)]) r.rCLxcTbl.peak1(3)],'linestyle','-')
line(axn(5),[650 850],[-0.75 -0.75],'color','k','linewidth',1.5,'clipping','off')
text(axn(5),500,-1.24,'200 ms')
set(axn(5),'YTickLabel','','ylim',[-1 1],'ytick',[-1 0 1],'xcolor','none')
ylabel(axn(3),'r')

% rat all trial scatter + marginals
%quantify_fft_xcorr_trial_epochs__scatter(axn(6),r.rCL_goodtrials,holdcol,runcol1,rwdcol,0.5);
sz = 15;
mkrA = 0.25;

scatter(axn(6),r.alltrials_rCl_hold.Freq,r.alltrials_rCl_hold.Peakrangenorm,sz,holdcol,'filled','MarkerEdgeColor','none','markerfacealpha',mkrA)
scatter(axn(6),r.alltrials_rCl_rwd.Freq,r.alltrials_rCl_rwd.Peakrangenorm,sz,rwdcol,'filled','MarkerEdgeColor','none','markerfacealpha',mkrA)
scatter(axn(6),r.alltrials_rCl_run.Freq,r.alltrials_rCl_run.Peakrangenorm,sz,runcol1,'filled','MarkerEdgeColor','none','markerfacealpha',mkrA)

add_marginal_histograms(axn(6),'axX',axn(7),'axY',axn(8),'binXW',0.5,'binYW',0.05);
scatter(axn(6),r.rCLxcTbl.freq(1),r.rCLxcTbl.peakrangenorm(1),30,holdcol,'filled','markeredgecolor','k')
scatter(axn(6),r.rCLxcTbl.freq(2),r.rCLxcTbl.peakrangenorm(2),30,runcol1,'filled','markeredgecolor','k')
scatter(axn(6),r.rCLxcTbl.freq(3),r.rCLxcTbl.peakrangenorm(3),30,rwdcol,'filled','markeredgecolor','k')
ylabel(axn(6),{'Autocorr.';'peak range'})
xlabel(axn(6),'Frequency (Hz)')
set(axn(6),'xlim',[3.5 14],'ylim',[-0.025 0.9],'ytick',[0 0.4 0.8])

% rat across probe
add_shaded_areas(axn(9),[0 2],[32-(r.oCL-0.3)+1 32-(r.oCL+0.3)+1],'k',0.2)
add_shaded_areas(axn(9),[0 2],[32-(r.rCL-0.3)+1 32-(r.rCL+0.3)+1],'k',0.2)
quantify_fft_xcorr_trial_epochs__depth_plot(axn(9),r.xcfft,holdcol,runcol1,rwdcol,0.5)
set(axn(9),'ycolor','none','yminorgrid','on','xlim',[0 0.75])
plot(axn(9),[-0.025 -0.025],[2 7],'k','linewidth',1.5,'clipping','off')
text(axn(9),-0.125,0.18,'500 \mum','Interpreter','tex','Rotation',90)

xlabel(axn(9),{'Autocorr.','peak range'})
legend(axn(9),'off')

%% ferret example trial
add_shaded_areas(axn(10),f.holdwin,[0 100],holdcol,shadealpha)
add_shaded_areas(axn(10),f.runwin,[0 100],runcol2 ,shadealpha)
add_shaded_areas(axn(10),f.rwdwin,[0 100],rwdcol,shadealpha)
plot(axn(10),f.trialt,f.trialspeed,'k','LineWidth',1.5)
set(axn(10),'XTickLabel','','ytick',[0 50],'ylim',[-1 100],'xlim',[1034.7 1041.0])
ylabel(axn(10),{'Speed';'(cms^{-1})'},'interpreter','tex')

%plot_trace_across_chans(axn(2),[f.trialCL,f.trialdCL],'xvec',f.trialt,'color',params.col.R,'scalefactor',1)
add_shaded_areas(axn(11),f.holdwin,[-1.2 1.2],holdcol,shadealpha)
add_shaded_areas(axn(11),f.runwin,[-1.2 1.2],runcol2,shadealpha)
add_shaded_areas(axn(11),f.rwdwin,[-1.2 1.2],rwdcol,shadealpha)
plot(axn(11),f.trialt,f.trialrCL,'color',params.col.F)
set(axn(11),'XTickLabel','','ylim',[-0.7 0.7],'xcolor','none','YTick',[-0.5 0 0.5],'xlim',[1034.7 1041.0])
line(axn(11),[f.trialt(end)-1.5 f.trialt(end)-0.5],[-0.76 -0.76],'color','k','linewidth',1.5,'clipping','off')
text(axn(11),1039.6,-0.9105,'1 sec')
ylabel(axn(11),{'Amplitude';'(mV)'})
linkaxes([axn(10) axn(11)],'x')

% ferret example autocorrs
plot(axn(12),f.holdsinxc(ceil(size(f.holdsinxc,2)/2):end),'color',[0.3 0.3 0.3 0.5],'LineWidth',0.8,'LineStyle','-')
plot(axn(12),f.rCLXC(ceil(size(f.rCLXC,1)/2):end,1),'color',holdcol,'LineWidth',1.5)
plotXYlines(axn(12),f.rCLxcTbl.peak1i(1)-ceil(size(f.rCLXC,1)/2),'color',aclinecol,'lineExtent',[mean([f.rCLxcTbl.trough1(1), f.rCLxcTbl.trough2(1)]) f.rCLxcTbl.peak1(1)],'linestyle','-')
line(axn(12),[650 850],[-0.75 -0.75],'color','k','linewidth',1.5,'clipping','off')
text(axn(12),500,-1.24,'200 ms')
set(axn(12),'ylim',[-1 1],'ytick',[-1 0 1],'xcolor','none')

plot(axn(13),f.runsinxc(ceil(size(f.runsinxc,2)/2):end),'color',[0.3 0.3 0.3 0.5],'LineWidth',0.8,'LineStyle','-')
plot(axn(13),f.rCLXC(ceil(size(f.rCLXC,1)/2):end,2),'color',runcol2,'LineWidth',1.5)
plotXYlines(axn(13),f.rCLxcTbl.peak1i(2)-ceil(size(f.rCLXC,1)/2),'color',aclinecol,'lineExtent',[mean([f.rCLxcTbl.trough1(2), f.rCLxcTbl.trough2(2)]) f.rCLxcTbl.peak1(2)],'linestyle','-')
line(axn(13),[650 850],[-0.75 -0.75],'color','k','linewidth',1.5,'clipping','off')
text(axn(13),500,-1.24,'200 ms')
set(axn(13),'YTickLabel','','ylim',[-1 1],'ytick',[-1 0 1],'xcolor','none')

plot(axn(14),f.rwdsinxc(ceil(size(f.rwdsinxc,2)/2):end),'color',[0.3 0.3 0.3 0.5],'LineWidth',0.8,'LineStyle','-')
plot(axn(14),f.rCLXC(ceil(size(f.rCLXC,1)/2):end,3),'color',rwdcol,'LineWidth',1.5)
plotXYlines(axn(14),f.rCLxcTbl.peak1i(3)-ceil(size(f.rCLXC,1)/2),'color',aclinecol,'lineExtent',[mean([f.rCLxcTbl.trough1(3), f.rCLxcTbl.trough2(3)]) f.rCLxcTbl.peak1(3)],'linestyle','-')
line(axn(14),[650 850],[-0.75 -0.75],'color','k','linewidth',1.5,'clipping','off')
text(axn(14),500,-1.24,'200 ms')
set(axn(14),'YTickLabel','','ylim',[-1 1],'ytick',[-1 0 1],'xcolor','none')
ylabel(axn(12),'r')

% ferret all trials scatter + marginals
%quantify_fft_xcorr_trial_epochs__scatter(axn(15),f.rCL_goodtrials,holdcol,runcol2,rwdcol,0.5);
scatter(axn(15),f.alltrials_rCl_hold.Freq,f.alltrials_rCl_hold.Peakrangenorm,sz,holdcol,'filled','MarkerEdgeColor','none','markerfacealpha',mkrA)
scatter(axn(15),f.alltrials_rCl_rwd.Freq,f.alltrials_rCl_rwd.Peakrangenorm,sz,rwdcol,'filled','MarkerEdgeColor','none','markerfacealpha',mkrA)
scatter(axn(15),f.alltrials_rCl_run.Freq,f.alltrials_rCl_run.Peakrangenorm,sz,runcol2,'filled','MarkerEdgeColor','none','markerfacealpha',mkrA)

add_marginal_histograms(axn(15),'axX',axn(16),'axY',axn(17),'binXW',0.5,'binYW',0.05);
scatter(axn(15),f.rCLxcTbl.freq(1),f.rCLxcTbl.peakrangenorm(1),30,holdcol,'filled','markeredgecolor','k')
scatter(axn(15),f.rCLxcTbl.freq(2),f.rCLxcTbl.peakrangenorm(2),30,runcol2,'filled','markeredgecolor','k')
scatter(axn(15),f.rCLxcTbl.freq(3),f.rCLxcTbl.peakrangenorm(3),30,rwdcol,'filled','markeredgecolor','k')
ylabel(axn(15),{'Autocorr.';'peak range'})
set(axn(15),'xlim',[1.5 14],'ylim',[-0.025 0.9],'ytick',[0 0.4 0.8])
xlabel(axn(15),'Frequency (Hz)')

% ferret across probe
add_shaded_areas(axn(18),[0 2],[32-(f.oCL-0.3)+1 32-(f.oCL+0.3)+1],'k',0.2)
add_shaded_areas(axn(18),[0 2],[32-(f.rCL-0.3)+1 32-(f.rCL+0.3)+1],'k',0.2)
quantify_fft_xcorr_trial_epochs__depth_plot(axn(18),f.xcfft,holdcol,runcol2,rwdcol,0.5)
legend(axn(18),'off')
set(axn(18),'ycolor','none','yminorgrid','on','xlim',[0 0.75])
plot(axn(18),[-0.025 -0.025],[2 7],'k','linewidth',1.5,'clipping','off')
text(axn(18),-0.125,0.18,'500 \mum','Interpreter','tex','Rotation',90)
xlabel(axn(18),{'Autocorr.';'peak range'})

%% plot group data
% rat
mkrsize = 3.5;
lw = 2.5;
cols = {holdcol,runcol1,rwdcol};
plotXYlines(axn(19),1,'color',[0 0 0 0.5],'linewidth',0.2,'lineExtent',[0.5 3.5],'orientation','horizontal')
plot_ord1 = {'DBLUR','EREDR','DREDR'};
xshift = floor(numel(plot_ord1)/2)/10;
for n = 1:numel(plot_ord1)
    id = plot_ord1{n};
    iddat = alldata(contains(alldata.ID,id(1:4))&contains(alldata.Recside,id(5))&contains(alldata.Chan,'ori'),:);
    hold = iddat.Peakrangenorm(contains(iddat.Epoch,'Hold'));
    run  = iddat.Peakrangenorm(contains(iddat.Epoch,'Run'));
    rwd  = iddat.Peakrangenorm(contains(iddat.Epoch,'Rwd'));
    runmed = median(run);
    hold_norm = hold/runmed;
    run_norm = run/runmed;
    rwd_norm = rwd/runmed;
    [medholdnorm,pc25holdnorm,pc75holdnorm] = median_and_prcntiles(hold_norm);
    [medrunnorm,pc25runnorm,pc75runnorm] = median_and_prcntiles(run_norm);
    [medrwdnorm,pc25rwdnorm,pc75rwdnorm] = median_and_prcntiles(rwd_norm);

    plot(axn(19),[1 1]-xshift+((n-1)*0.15), [pc25holdnorm pc75holdnorm],'color',[cols{1} 0.4],'LineWidth',lw)
    plot(axn(19),[1 1]-xshift+((n-1)*0.15), medholdnorm,'color',cols{1},'marker',params.mkr.(id),'MarkerFaceColor',cols{1},'linestyle','none','MarkerSize',mkrsize)
    plot(axn(19),[2 2]-xshift+((n-1)*0.15), [pc25runnorm pc75runnorm],'color',[cols{2} 0.4],'LineWidth',lw)
    plot(axn(19),[2 2]-xshift+((n-1)*0.15), medrunnorm,'color',cols{2},'marker',params.mkr.(id),'MarkerFaceColor',cols{2},'linestyle','none','MarkerSize',mkrsize)
    plot(axn(19),[3 3]-xshift+((n-1)*0.15), [pc25rwdnorm pc75rwdnorm],'color',[cols{3} 0.4],'LineWidth',lw)
    plot(axn(19),[3 3]-xshift+((n-1)*0.15), medrwdnorm,'color',cols{3},'marker',params.mkr.(id),'MarkerFaceColor',cols{3},'linestyle','none','MarkerSize',mkrsize)

end

% rat rCL
plotXYlines(axn(20),1,'color',[0 0 0 0.5],'linewidth',0.2,'lineExtent',[0.5 3.5],'orientation','horizontal')
plot_ord2 = {'DBLUR','EREDR'};
xshift = floor(numel(plot_ord2)/2)/10;
for n = 1:numel(plot_ord2)
    id = plot_ord2{n};
    iddat = alldata(contains(alldata.ID,id(1:4))&contains(alldata.Recside,id(5))&contains(alldata.Chan,'rad'),:);
    hold = iddat.Peakrangenorm(contains(iddat.Epoch,'Hold'));
    run  = iddat.Peakrangenorm(contains(iddat.Epoch,'Run'));
    rwd  = iddat.Peakrangenorm(contains(iddat.Epoch,'Rwd'));
    runmed = median(run);
    hold_norm = hold/runmed;
    run_norm = run/runmed;
    rwd_norm = rwd/runmed;
    [medholdnorm,pc25holdnorm,pc75holdnorm] = median_and_prcntiles(hold_norm);
    [medrunnorm,pc25runnorm,pc75runnorm] = median_and_prcntiles(run_norm);
    [medrwdnorm,pc25rwdnorm,pc75rwdnorm] = median_and_prcntiles(rwd_norm);

    plot(axn(20),[1 1]-xshift+((n-1)*0.15), [pc25holdnorm pc75holdnorm],'color',[cols{1} 0.4],'LineWidth',lw)
    plot(axn(20),[1 1]-xshift+((n-1)*0.15), medholdnorm,'color',cols{1},'marker',params.mkr.(id),'MarkerFaceColor',cols{1},'linestyle','none','MarkerSize',mkrsize)
    plot(axn(20),[2 2]-xshift+((n-1)*0.15), [pc25runnorm pc75runnorm],'color',[cols{2} 0.4],'LineWidth',lw)
    plot(axn(20),[2 2]-xshift+((n-1)*0.15), medrunnorm,'color',cols{2},'marker',params.mkr.(id),'MarkerFaceColor',cols{2},'linestyle','none','MarkerSize',mkrsize)
    plot(axn(20),[3 3]-xshift+((n-1)*0.15), [pc25rwdnorm pc75rwdnorm],'color',[cols{3} 0.4],'LineWidth',lw)
    plot(axn(20),[3 3]-xshift+((n-1)*0.15), medrwdnorm,'color',cols{3},'marker',params.mkr.(id),'MarkerFaceColor',cols{3},'linestyle','none','MarkerSize',mkrsize)

end

% ferret oCL
cols = {holdcol,runcol2,rwdcol};
plotXYlines(axn(21),1,'color',[0 0 0 0.5],'linewidth',0.2,'lineExtent',[0.5 3.5],'orientation','horizontal')
plot_ord3 = {'KIWL','KIWR','EMUL','BEAL','BEAR'};
xshift = floor(numel(plot_ord3)/2)/10;
for n = 1:numel(plot_ord3)
    id = plot_ord3{n};
    iddat = alldata(contains(alldata.ID,id(1:3))&contains(alldata.Recside,id(4))&contains(alldata.Chan,'ori'),:);
    hold = iddat.Peakrangenorm(contains(iddat.Epoch,'Hold'));
    run  = iddat.Peakrangenorm(contains(iddat.Epoch,'Run'));
    rwd  = iddat.Peakrangenorm(contains(iddat.Epoch,'Rwd'));
    runmed = median(run);
    hold_norm = hold/runmed;
    run_norm = run/runmed;
    rwd_norm = rwd/runmed;
    [medholdnorm,pc25holdnorm,pc75holdnorm] = median_and_prcntiles(hold_norm);
    [medrunnorm,pc25runnorm,pc75runnorm] = median_and_prcntiles(run_norm);
    [medrwdnorm,pc25rwdnorm,pc75rwdnorm] = median_and_prcntiles(rwd_norm);

    plot(axn(21),[1 1]-xshift+((n-1)*0.15), [pc25holdnorm pc75holdnorm],'color',[cols{1} 0.4],'LineWidth',lw)
    plot(axn(21),[1 1]-xshift+((n-1)*0.15), medholdnorm,'color',cols{1},'marker',params.mkr.(id),'MarkerFaceColor',cols{1},'linestyle','none','MarkerSize',mkrsize)
    plot(axn(21),[2 2]-xshift+((n-1)*0.15), [pc25runnorm pc75runnorm],'color',[cols{2} 0.4],'LineWidth',lw)
    plot(axn(21),[2 2]-xshift+((n-1)*0.15), medrunnorm,'color',cols{2},'marker',params.mkr.(id),'MarkerFaceColor',cols{2},'linestyle','none','MarkerSize',mkrsize)
    plot(axn(21),[3 3]-xshift+((n-1)*0.15), [pc25rwdnorm pc75rwdnorm],'color',[cols{3} 0.4],'LineWidth',lw)
    plot(axn(21),[3 3]-xshift+((n-1)*0.15), medrwdnorm,'color',cols{3},'marker',params.mkr.(id),'MarkerFaceColor',cols{3},'linestyle','none','MarkerSize',mkrsize)

end

% ferret rCL
plotXYlines(axn(22),1,'color',[0 0 0 0.5],'linewidth',0.2,'lineExtent',[0.5 3.5],'orientation','horizontal')
plot_ord4 = {'KIWL','BEAL','BEAR'};
xshift = floor(numel(plot_ord4)/2)/10;

for n = 1:numel(plot_ord4)
    id = plot_ord4{n};
    iddat = alldata(contains(alldata.ID,id(1:3))&contains(alldata.Recside,id(4))&contains(alldata.Chan,'rad'),:);
    hold = iddat.Peakrangenorm(contains(iddat.Epoch,'Hold'));
    run  = iddat.Peakrangenorm(contains(iddat.Epoch,'Run'));
    rwd  = iddat.Peakrangenorm(contains(iddat.Epoch,'Rwd'));
    runmed = median(run);
    hold_norm = hold/runmed;
    run_norm = run/runmed;
    rwd_norm = rwd/runmed;
    [medholdnorm,pc25holdnorm,pc75holdnorm] = median_and_prcntiles(hold_norm);
    [medrunnorm,pc25runnorm,pc75runnorm] = median_and_prcntiles(run_norm);
    [medrwdnorm,pc25rwdnorm,pc75rwdnorm] = median_and_prcntiles(rwd_norm);

    plot(axn(22),[1 1]-xshift+((n-1)*0.15), [pc25holdnorm pc75holdnorm],'color',[cols{1} 0.4],'LineWidth',lw)
    plot(axn(22),[1 1]-xshift+((n-1)*0.15), medholdnorm,'color',cols{1},'marker',params.mkr.(id),'MarkerFaceColor',cols{1},'linestyle','none','MarkerSize',mkrsize)
    plot(axn(22),[2 2]-xshift+((n-1)*0.15), [pc25runnorm pc75runnorm],'color',[cols{2} 0.4],'LineWidth',lw)
    plot(axn(22),[2 2]-xshift+((n-1)*0.15), medrunnorm,'color',cols{2},'marker',params.mkr.(id),'MarkerFaceColor',cols{2},'linestyle','none','MarkerSize',mkrsize)
    plot(axn(22),[3 3]-xshift+((n-1)*0.15), [pc25rwdnorm pc75rwdnorm],'color',[cols{3} 0.4],'LineWidth',lw)
    plot(axn(22),[3 3]-xshift+((n-1)*0.15), medrwdnorm,'color',cols{3},'marker',params.mkr.(id),'MarkerFaceColor',cols{3},'linestyle','none','MarkerSize',mkrsize)
end

set(axn(19:22),'xlim',[0.5 3.5],'ylim',[0 1.8],'xtick',[1 2 3],'xticklabel',{'Hold', 'Run' , 'Rwd'})
set(axn([20,22]),'yticklabel','')

ylabel(axn(19),{'Autocorr. peak range';'(norm. to run)'})
ylabel(axn(21),{'Autocorr. peak range';'(norm. to run)'})

%%  add text
title(axn,'')
font_size_and_color(gcf,8)
texty = 85;
text(axn(1),r.holdwin(1)+0.2,texty,'Hold','Color',holdcol,'FontSize',8,'FontWeight','bold')
text(axn(1),r.runwin(1)+0.2,texty,'Run','Color',runcol1,'FontSize',8,'FontWeight','bold')
text(axn(1),r.rwdwin(1)+0.05,texty,'Reward','Color',rwdcol,'FontSize',8,'FontWeight','bold')

texty = 95;
text(axn(10),f.holdwin(1)+0.2,texty,'Hold','Color',holdcol,'FontSize',8,'FontWeight','bold')
text(axn(10),f.runwin(1)+0.2,texty,'Run','Color',runcol2,'FontSize',8,'FontWeight','bold')
text(axn(10),f.rwdwin(1)+0.05,texty,'Reward','Color',rwdcol,'FontSize',8,'FontWeight','bold')

texty = 1.7;
textx = 0.62;
text(axn(19),textx,texty,'or.','Color','k','FontSize',9,'FontWeight','bold')
text(axn(20),textx,texty,'rad.','Color','k','FontSize',9,'FontWeight','bold')
text(axn(21),textx,texty,'or.','Color','k','FontSize',9,'FontWeight','bold')
text(axn(22),textx,texty,'rad.','Color','k','FontSize',9,'FontWeight','bold')

keyboard
%print(gcf,'-dpdf','-r600','-painters','figure6_trial_MATLABoutput.pdf')