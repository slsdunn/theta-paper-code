function figure4_mov_vs_imm

params = get_parameters;   

r.ID = 'EREDR';
r.ref = load_reference_table('R','ID',r.ID(1:4),'incl','neu','level','L5|6');

% eq_data_for_scatter = 0;
highcol = [0 202 34]/255; %[0.11,0.35,0.06];
lowcol  = [0 202 34]/255; %[0.50,0.78,0.25]; 
txtpos = [360,0.85];
bgsinecol = [[43 38 26]/255 0.5];
yautocorrlbl = 'r';

% example data
r.nsession = 5;
r.sref = r.ref(r.nsession,:);
r.mdata = load_metadata(r.sref);
r.cdata = load_neural_mapped(r.sref,r.mdata,[params.oCL.(r.ID),params.rCL.(r.ID)],'cleansignal');  
r.flt_desc = {'2_highpass';'49_51_bandstop'};
r.cdata = cheby2_filtfilthd(r.cdata,r.flt_desc{1},1000);
r.cdata = cheby2_filtfilthd(r.cdata,r.flt_desc{2},1000);
r.t_neu = load_neural_timeline(r.mdata);
r.speed = load_tracking_speed(r.sref,r.mdata,r.t_neu);

r.nsegments    = floor(length(r.t_neu)/params.xcorr.win_samples);
r.speedepochs  = reshape(r.speed(1:params.xcorr.win_samples*r.nsegments),params.xcorr.win_samples,r.nsegments);
r.mspeedepochs = mean(r.speedepochs);
r.speednanidx  = isnan(r.mspeedepochs);

r.dataepochsoCL = reshape(r.cdata(1:params.xcorr.win_samples*r.nsegments,1),params.xcorr.win_samples,r.nsegments);    
r.nanidxoCL     = any(isnan(r.dataepochsoCL)) | r.speednanidx;
r.dataepochsoCL(:,r.nanidxoCL) = [];
r.mspeedoCL     = r.mspeedepochs(~r.nanidxoCL);

r.dataepochsrCL = reshape(r.cdata(1:params.xcorr.win_samples*r.nsegments,2),params.xcorr.win_samples,r.nsegments);    
r.nanidxrCL     = any(isnan(r.dataepochsrCL)) | r.speednanidx;
r.dataepochsrCL(:,r.nanidxrCL) = [];
r.mspeedrCL     = r.mspeedepochs(~r.nanidxrCL);
    
isequal(r.mspeedrCL, r.mspeedoCL) % check that data from the 2 channels is coherent

[r.XC_oCL,r.xcTbl_oCL]  = quantify_xcorr_epochs(r.dataepochsoCL(:,:,1),params.xcorr.R.freq_range,params.xcorr.freqResolution);
[r.XC_rCL,r.xcTbl_rCL]  = quantify_xcorr_epochs(r.dataepochsrCL(:,:,1),params.xcorr.R.freq_range,params.xcorr.freqResolution);
r.xcTbl_rCL.Speed = r.mspeedrCL';

r.sessions_oCL = load_mov_vs_imm_sessiondata('R','oCL');
r.sessions_rCL = load_mov_vs_imm_sessiondata('R','rCL');


r.highspeed = 45; 
r.lowspeed  = 0.75; 
[~,r.nepoch_lowspeed] = min(abs(r.mspeedoCL-r.lowspeed));
[~,r.nepoch_highspeed] = min(abs(r.mspeedoCL-r.highspeed));

t = 0:1/1000:1 - 1/1000;
r.highxc = xcorr(sin(2*pi*r.xcTbl_rCL.freq(r.nepoch_highspeed)*t),sin(2*pi*r.xcTbl_rCL.freq(r.nepoch_highspeed)*t));
r.highxc = r.highxc/max(r.highxc);
r.lowxc = xcorr(sin(2*pi*r.xcTbl_rCL.freq(r.nepoch_lowspeed)*t),sin(2*pi*r.xcTbl_rCL.freq(r.nepoch_lowspeed)*t));
r.lowxc = r.lowxc/max(r.lowxc);

%% ferret

f.ID = 'KIW';
f.recside = 'L';
f.IDside = 'KIWL';
f.ref = load_reference_table('F','ID',f.ID,'incl','neu','level','L5|6');
f.ref = f.ref(contains(f.ref.RecSide,f.recside),:);
% example data
f.nsession = 5;
f.sref = f.ref(f.nsession,:);
f.mdata = load_metadata(f.sref);
f.cdata = load_neural_mapped(f.sref,f.mdata,[params.oCL.(f.IDside),params.rCL.(f.IDside)],'cleansignal');
 f.flt_desc = {'1_highpass';'49_51_bandstop'};
f.cdata = cheby2_filtfilthd(f.cdata,f.flt_desc{1},1000);
f.cdata = cheby2_filtfilthd(f.cdata,f.flt_desc{2},1000);
f.t_neu = load_neural_timeline(f.mdata);
f.speed = load_tracking_speed(f.sref,f.mdata,f.t_neu);

f.nsegments    = floor(length(f.t_neu)/params.xcorr.win_samples);
f.speedepochs  = reshape(f.speed(1:params.xcorr.win_samples*f.nsegments),params.xcorr.win_samples,f.nsegments);
f.mspeedepochs = mean(f.speedepochs);
f.speednanidx  = isnan(f.mspeedepochs);

f.dataepochsoCL = reshape(f.cdata(1:params.xcorr.win_samples*f.nsegments,1),params.xcorr.win_samples,f.nsegments);    
f.nanidxoCL     = any(isnan(f.dataepochsoCL)) | f.speednanidx;
f.dataepochsoCL(:,f.nanidxoCL) = [];
f.mspeedoCL     = f.mspeedepochs(~f.nanidxoCL);

f.dataepochsrCL = reshape(f.cdata(1:params.xcorr.win_samples*f.nsegments,2),params.xcorr.win_samples,f.nsegments);    
f.nanidxrCL     = any(isnan(f.dataepochsrCL)) | f.speednanidx;
f.dataepochsrCL(:,f.nanidxrCL) = [];
f.mspeedrCL     = f.mspeedepochs(~f.nanidxrCL);
    
isequal(f.mspeedrCL, f.mspeedoCL) % check that data from the 2 channels is coherent


[f.XC_oCL,f.xcTbl_oCL]  = quantify_xcorr_epochs(f.dataepochsoCL(:,:,1),params.xcorr.F.freq_range,params.xcorr.freqResolution);
[f.XC_rCL,f.xcTbl_rCL]  = quantify_xcorr_epochs(f.dataepochsrCL(:,:,1),params.xcorr.F.freq_range,params.xcorr.freqResolution);
f.xcTbl_rCL.Speed = f.mspeedrCL';

f.sessions_oCL = load_mov_vs_imm_sessiondata('F','oCL');
f.sessions_rCL = load_mov_vs_imm_sessiondata('F','rCL');


f.highspeed = 43; %57.5;
f.lowspeed  = 0.6; %0.1;
[~,f.nepoch_lowspeed] = min(abs(f.mspeedoCL-f.lowspeed));
[~,f.nepoch_highspeed] = min(abs(f.mspeedoCL-f.highspeed));


f.highxc = xcorr(sin(2*pi*f.xcTbl_rCL.freq(f.nepoch_highspeed)*t),sin(2*pi*f.xcTbl_rCL.freq(f.nepoch_highspeed)*t));
f.highxc = f.highxc/max(f.highxc);
f.lowxc = xcorr(sin(2*pi*f.xcTbl_rCL.freq(f.nepoch_lowspeed)*t),sin(2*pi*f.xcTbl_rCL.freq(f.nepoch_lowspeed)*t));
f.lowxc = f.lowxc/max(f.lowxc);

r.ex_idx2 = 75000;
r.ex_idx1 = 50000;


% load data
alldata = readtable(fullfile(params.figDataPath,'figure3rawdata.csv'));

allids = unique(alldata.IDside,'stable');
for n = 1:numel(allids)
    
    iddata = alldata(contains(alldata.IDside,allids{n}),:);
    idsesh = unique(iddata.Session,'stable');
    for ns = 1:numel(idsesh)
        sessions.(allids{n}).oCL.medmov(ns) = nanmedian(iddata.Peakrangenorm(contains(iddata.Session,idsesh{ns})&contains(iddata.MovFlag,'mov')&contains(iddata.Chan,'ori')));  
        sessions.(allids{n}).oCL.medimm(ns) = nanmedian(iddata.Peakrangenorm(contains(iddata.Session,idsesh{ns})&contains(iddata.MovFlag,'imm')&contains(iddata.Chan,'ori')));     
        sessions.(allids{n}).rCL.medmov(ns) = nanmedian(iddata.Peakrangenorm(contains(iddata.Session,idsesh{ns})&contains(iddata.MovFlag,'mov')&contains(iddata.Chan,'rad')));  
        sessions.(allids{n}).rCL.medimm(ns) = nanmedian(iddata.Peakrangenorm(contains(iddata.Session,idsesh{ns})&contains(iddata.MovFlag,'imm')&contains(iddata.Chan,'rad')));     
    end
    
end

%% plot figure 4
axn = figure4_mov_vs_imm_makeFigure;

%% rat example traces + spectrograms
r.tidx = [963 988];
r.nidx = interp1(r.t_neu,1:length(r.t_neu),r.tidx ,'nearest');

plot(axn(1),r.t_neu, r.speed,'k','LineWidth',1);
set(axn(1),'ylim',[-5 90],'ytick',[0 50],'xcolor','none')
title([axn(1) axn(2) axn(3)],'')
ylabel(axn(1),'cms^{-1}','Interpreter','tex')
plot_trace_across_chans(axn(2),r.cdata,'xvec',r.t_neu,'scalefactor',0.75,'color',params.col.R)
linkaxes([axn(1) axn(2)],'x')
set(axn(2),'xlim',[965 985],'xcolor','none','ytick',[1 2],'yTickLabel',{'rad.','or.'})
axn(2).YRuler.TickLabelGapOffset = 3;

r.section   = r.cdata(r.nidx(1):r.nidx(2),2);
r.t_section = r.t_neu(r.nidx(1):r.nidx(2));
r.freq_range = [2 14];
r.SR = 1000;
r.w = 1024;  % window, default is hamming
r.noverlap = 6*r.w/8; % default is 50%
r.N = length(r.section);
r.F = r.freq_range(1):(r.SR/(r.N-1)):r.freq_range(2);

[~,r.F,r.T,r.P] = spectrogram(r.section,r.w,r.noverlap,r.F,r.SR);
r.normP = r.P/max(max(r.P));

% r.sf = surf(axn(3),r.T+r.t_section(1),r.F,10*log10(r.normP), 'EdgeColor','none');
% view(axn(3),0,90)
imagesc(axn(3),r.T+r.t_section(1),r.F,10*log10(r.normP));
set(axn(3),'xlim',[965 985],'ylim',[2 14],'ytick',[4 8 12],'XTickLabel','')
ylabel(axn(3),'Freq. (Hz)')
spectcb = colorbar(axn(3),'southoutside','position',[0.85 0.823, 0.05,0.015]);
spectcb.Label.String = 'dB/Hz';
spectcb.Label.Position = [-39.4 0.7411 0];
caxis(axn(3),[-25 0])

colormap(axn(3),viridis)

l=line(axn(3),[965.5 966.5],[r.freq_range(1)-1 r.freq_range(1)-1]);
l.LineWidth = 1.5;
l.Color = 'k';
set(l,'clipping','off')
text(axn(3),965.7,r.freq_range(1)-2.5,'1 sec')

%% ferret example trace & spectrogram
f.tidx = [860 890];
f.nidx = interp1(f.t_neu,1:length(f.t_neu),f.tidx ,'nearest');

plot(axn(4),f.t_neu, f.speed,'k','LineWidth',1);
set(axn(4),'ylim',[-5 90],'ytick',[0 50],'xcolor','none')
title([axn(4) axn(5) axn(6)],'')
ylabel(axn(4),'cms^{-1}','Interpreter','tex')

plot_trace_across_chans(axn(5),f.cdata,'xvec',f.t_neu,'scalefactor',1.25,'color',params.col.F)
linkaxes([axn(4) axn(5)],'x')
set(axn(5),'xlim',[867 887],'xcolor','none','ytick',[1 2],'yTickLabel',{'rad.','or.'},'ylim',[0.0181    2.6459])
axn(5).YRuler.TickLabelGapOffset = 3;

f.section   = f.cdata(f.nidx(1):r.nidx(2),2);
f.t_section = f.t_neu(f.nidx(1):f.nidx(2));
f.freq_range = [2 14];
f.SR = 1000;
f.w = 1024;  % window, default is hamming
f.noverlap = 6*f.w/8; % default is 50%
f.N = length(f.section);
f.F = f.freq_range(1):(f.SR/(f.N-1)):f.freq_range(2);

[~,f.F,f.T,f.P] = spectrogram(f.section,f.w,f.noverlap,f.F,f.SR);
f.normP = f.P/max(max(f.P));

% f.sf = surf(axn(6),f.T+f.t_section(1),f.F,10*log10(f.normP), 'EdgeColor','none');
% view(axn(6),0,90)
imagesc(axn(6),f.T+f.t_section(1),f.F,10*log10(f.normP));
set(axn(6),'xlim',[867 887],'ylim',[2 14],'ytick',[4 8 12],'XTickLabel','')
ylabel(axn(6),'Freq. (Hz)')
spectcb2 = colorbar(axn(6),'southoutside','position',[0.91 0.653, 0.05,0.015]);
spectcb2.Label.String = 'dB/Hz';
spectcb2.Label.Position = [-39.4 0.7411 0];
caxis(axn(6),[-25 0])

l=line(axn(6),[867.5 868.5],[f.freq_range(1)-1 f.freq_range(1)-1]);
l.LineWidth = 1.5;
l.Color = 'k';
set(l,'clipping','off')
text(axn(6),867.5,f.freq_range(1)-2.5,'1 sec')

colormap(axn(6),viridis)


axn_start = 7;
%% rat dCL
plot(axn(axn_start),r.dataepochsrCL(:,r.nepoch_highspeed,1),'color',params.col.R,'LineWidth',1)
title(axn(axn_start),'')
set(axn(axn_start),'xcolor','none','ycolor','none')

plot(axn(axn_start+1),r.highxc(ceil(size(r.XC_rCL,1)/2):end),'color',bgsinecol,'LineWidth',0.8,'LineStyle','-')
plot(axn(axn_start+1),r.XC_rCL(ceil(size(r.XC_rCL,1)/2):end,r.nepoch_highspeed),'k','LineWidth',1)
plotXYlines(axn(axn_start+1),r.xcTbl_rCL.peak1i(r.nepoch_highspeed)-ceil(size(r.XC_rCL,1)/2),'color',highcol,'lineExtent',[mean([r.xcTbl_rCL.trough1(r.nepoch_highspeed), r.xcTbl_rCL.trough2(r.nepoch_highspeed)])  r.xcTbl_rCL.peak1(r.nepoch_highspeed)],'linestyle','-')
title(axn(axn_start+1),'')
set(axn(axn_start+1),'ylim',[-1 1],'xTick',[0 500 1000],'xcolor','none','ytick',[-1 0 1])
ylabel(axn(axn_start+1),yautocorrlbl)

plot(axn(axn_start+2),r.dataepochsrCL(:,r.nepoch_lowspeed,1),'color',params.col.R,'LineWidth',1)
title(axn(axn_start+2),'')
set(axn(axn_start+2),'xcolor','none','ycolor','none')

plot(axn(axn_start+3),r.lowxc(ceil(size(r.XC_rCL,1)/2):end),'color',bgsinecol,'LineWidth',0.8,'LineStyle','-')
plot(axn(axn_start+3),r.XC_rCL(ceil(size(r.XC_rCL,1)/2):end,r.nepoch_lowspeed),'k','LineWidth',1)
plotXYlines(axn(axn_start+3),r.xcTbl_rCL.peak1i(r.nepoch_lowspeed)-ceil(size(r.XC_rCL,1)/2),'color',lowcol,'lineExtent',[mean([r.xcTbl_rCL.trough1(r.nepoch_lowspeed), r.xcTbl_rCL.trough2(r.nepoch_lowspeed)]) r.xcTbl_rCL.peak1(r.nepoch_lowspeed)],'linestyle','-')
title(axn(axn_start+3),'')
set(axn(axn_start+3),'ylim',[-1 1],'xTick',[0 500 1000],'xticklabel',[0 0.5 1],'ytick',[-1 0 1])
xlabel(axn(axn_start+3), 'Time (s)')
ylabel(axn(axn_start+3),yautocorrlbl) 

cb2 = quantify_fft_xcorr_vs_speed__plot_session(axn(axn_start+4),r.xcTbl_rCL,0,10);
set(cb2,'units','centimeters','position',[6.1235,13.56,0.5,0.5])
add_marginal_histograms(axn(axn_start+4),'axX',axn(axn_start+5),'axY',axn(axn_start+6),'binXW',0.5,'binYW',0.1);
set(axn(axn_start+4),'xlim',[3.5 15],'xtick',2:2:14,'ylim',[0 1],'ytick',[0 0.5 1])
scatter(axn(axn_start+4),r.xcTbl_rCL.freq(r.nepoch_highspeed),r.xcTbl_rCL.peakrangenorm(r.nepoch_highspeed),20,'MarkerFaceColor',highcol,'MarkerEdgeColor','k','marker','d')
scatter(axn(axn_start+4),r.xcTbl_rCL.freq(r.nepoch_lowspeed),r.xcTbl_rCL.peakrangenorm(r.nepoch_lowspeed),22,'MarkerFaceColor',lowcol,'MarkerEdgeColor','k','marker','s')
set(axn(axn_start+5),'xticklabel',[],'yscale','log','ytick',[10 100],'yticklabel',[10 100])
set(axn(axn_start+6),'yticklabel',[],'xscale','log','xtick',[10 100],'xticklabel',[10 100])
title([axn(axn_start+4), axn(axn_start+5),axn(axn_start+6)],'')
xlabel(axn(axn_start+4),'Frequency (Hz)')
ylabel(axn(axn_start+4),'Autocorr. peak range')




%% ferret dCL
plot(axn(axn_start+7),f.dataepochsrCL(:,f.nepoch_highspeed,1),'color',params.col.F,'LineWidth',1)
title(axn(axn_start+7),'')
set(axn(axn_start+7),'xcolor','none','ycolor','none')

plot(axn(axn_start+8),f.highxc(ceil(size(f.XC_rCL,1)/2):end),'color',bgsinecol,'LineWidth',0.8,'LineStyle','-')
plot(axn(axn_start+8),f.XC_rCL(ceil(size(f.XC_rCL,1)/2):end,f.nepoch_highspeed),'k','LineWidth',1)
plotXYlines(axn(axn_start+8),f.xcTbl_rCL.peak1i(f.nepoch_highspeed)-ceil(size(f.XC_rCL,1)/2),'color',highcol,'lineExtent',[mean([f.xcTbl_rCL.trough1(f.nepoch_highspeed), f.xcTbl_rCL.trough2(f.nepoch_highspeed)]) f.xcTbl_rCL.peak1(f.nepoch_highspeed)],'linestyle','-')
title(axn(axn_start+8),'')
set(axn(axn_start+8),'ylim',[-1 1],'xTick',[0 500 1000],'xcolor','none','ytick',[-1 0 1])
ylabel(axn(axn_start+8),yautocorrlbl)

plot(axn(axn_start+9),f.dataepochsrCL(:,f.nepoch_lowspeed,1),'color',params.col.F,'LineWidth',1)
title(axn(axn_start+9),'')
set(axn(axn_start+9),'xcolor','none','ycolor','none')

plot(axn(axn_start+10),f.lowxc(ceil(size(f.XC_rCL,1)/2):end),'color',bgsinecol,'LineWidth',0.8,'LineStyle','-')
plot(axn(axn_start+10),f.XC_rCL(ceil(size(f.XC_rCL,1)/2):end,f.nepoch_lowspeed),'k','LineWidth',1)
plotXYlines(axn(axn_start+10),f.xcTbl_rCL.peak1i(f.nepoch_lowspeed)-ceil(size(f.XC_rCL,1)/2),'color',lowcol,'lineExtent',[mean([f.xcTbl_rCL.trough1(f.nepoch_lowspeed), f.xcTbl_rCL.trough2(f.nepoch_lowspeed)]) f.xcTbl_rCL.peak1(f.nepoch_lowspeed)],'linestyle','-')
title(axn(axn_start+10),'')
set(axn(axn_start+10),'ylim',[-1 1],'xTick',[0 500 1000],'xticklabel',[0 0.5 1],'ytick',[-1 0 1])
xlabel(axn(axn_start+10), 'Time (s)')
ylabel(axn(axn_start+10),yautocorrlbl)

cb2 = quantify_fft_xcorr_vs_speed__plot_session(axn(axn_start+11),f.xcTbl_rCL,0,10);
set(cb2,'units','centimeters','position',[14.63,13.56,0.5,0.5])
add_marginal_histograms(axn(axn_start+11),'axX',axn(axn_start+12),'axY',axn(axn_start+13),'binXW',0.5,'binYW',0.1);
set(axn(axn_start+11),'xlim',[1.5 12],'xtick',2:2:14,'ylim',[0 1],'ytick',[0 0.5 1])
scatter(axn(axn_start+11),f.xcTbl_rCL.freq(f.nepoch_highspeed),f.xcTbl_rCL.peakrangenorm(f.nepoch_highspeed),20,'MarkerEdgeColor','k','MarkerFaceColor',highcol,'marker','d')
scatter(axn(axn_start+11),f.xcTbl_rCL.freq(f.nepoch_lowspeed),f.xcTbl_rCL.peakrangenorm(f.nepoch_lowspeed),22,'MarkerEdgeColor','k','MarkerFaceColor',lowcol,'marker','s')
set(axn(axn_start+12),'xticklabel',[],'yscale','log','ytick',[10 100],'yticklabel',[10 100])
set(axn(axn_start+13),'yticklabel',[],'xscale','log','xtick',[10 100],'xticklabel',[10 100])
title([axn(axn_start+11), axn(axn_start+12),axn(axn_start+13)],'')
xlabel(axn(axn_start+11),'Frequency (Hz)')
ylabel(axn(axn_start+11),'Autocorr. peak range')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% plot group data

msize = 20;
boxcol = [0.2 0.2 0.2];
medcol =[0.1 0.1 0.1];
boxw = 0.8;
xjitw = 0.75;

%rat oCL
COI = 'oCL';
plot_pos1 = [1 4 7;2 5 8];
plot_ord1 = {'DBLUR','EREDR','DREDR'};
for n = 1:3
    ids = plot_ord1{n};
    npoints = numel(sessions.(ids).(COI).medimm);
    plot(axn(axn_start+14),[plot_pos1(1,n)*ones(1,npoints); plot_pos1(2,n)*ones(1,npoints)],[sessions.(ids).(COI).medimm; sessions.(ids).(COI).medmov],'color',[0.5 0.5 0.5 0.25],'linewidth',0.8)
    swarmchart(axn(axn_start+14),plot_pos1(1,n)*ones(npoints,1),sessions.(ids).(COI).medimm,msize,params.col.imm,'filled','XJitter','density','XJitterWidth',xjitw,'marker',params.mkr.(ids))
    swarmchart(axn(axn_start+14),plot_pos1(2,n)*ones(npoints,1),sessions.(ids).(COI).medmov,msize,params.col.(ids),'filled','XJitter','density','XJitterWidth',xjitw,'marker',params.mkr.(ids))
   
    calc_and_plot_box(axn(axn_start+14),sessions.(ids).(COI).medimm,plot_pos1(1,n),boxw,medcol,boxcol)
   calc_and_plot_box(axn(axn_start+14),sessions.(ids).(COI).medmov,plot_pos1(2,n),boxw,medcol,boxcol)
end
% rat rCL
COI = 'rCL';
plot_pos2 = [12 15;13 16];
plot_ord2 = {'DBLUR','EREDR'};
for n = 1:2
     ids = plot_ord2{n};
    npoints = numel(sessions.(ids).(COI).medimm);
    plot(axn(axn_start+14),[plot_pos2(1,n)*ones(1,npoints); plot_pos2(2,n)*ones(1,npoints)],[sessions.(ids).(COI).medimm; sessions.(ids).(COI).medmov],'color',[0.5 0.5 0.5 0.25],'linewidth',0.8)
    swarmchart(axn(axn_start+14),plot_pos2(1,n)*ones(npoints,1),sessions.(ids).(COI).medimm,msize,params.col.imm,'filled','XJitter','density','XJitterWidth',xjitw,'marker',params.mkr.(ids))
    swarmchart(axn(axn_start+14),plot_pos2(2,n)*ones(npoints,1),sessions.(ids).(COI).medmov,msize,params.col.(ids),'filled','XJitter','density','XJitterWidth',xjitw,'marker',params.mkr.(ids))
   
    calc_and_plot_box(axn(axn_start+14),sessions.(ids).(COI).medimm,plot_pos2(1,n),boxw,medcol,boxcol)
   calc_and_plot_box(axn(axn_start+14),sessions.(ids).(COI).medmov,plot_pos2(2,n),boxw,medcol,boxcol)
end

set(axn(axn_start+14),'xlim',[0 16.6],'xtick',[1.5 4.5 7.5 12.5 15.5],'ylim',[0.15 0.7],'ytick',0.2:0.2:0.6,'xticklabel','','xcolor','none')
ylabel(axn(axn_start+14),'Autocorr. peak range')


%ferret oCL
COI = 'oCL';
plot_pos3 = [1 4 7 10 13;2 5 8 11 14];
plot_ord3 = {'KIWL','KIWR','EMUL','BEAL','BEAR'};
for n = 1:5
   ids = plot_ord3{n};
   npoints = numel(sessions.(ids).(COI).medimm);
    plot(axn(axn_start+16),[plot_pos3(1,n)*ones(1,npoints); plot_pos3(2,n)*ones(1,npoints)],[sessions.(ids).(COI).medimm; sessions.(ids).(COI).medmov],'color',[0.5 0.5 0.5 0.25],'linewidth',0.8)
    swarmchart(axn(axn_start+16),plot_pos3(1,n)*ones(npoints,1),sessions.(ids).(COI).medimm,msize,params.col.imm,'filled','XJitter','density','XJitterWidth',xjitw,'marker',params.mkr.(ids))
    swarmchart(axn(axn_start+16),plot_pos3(2,n)*ones(npoints,1),sessions.(ids).(COI).medmov,msize,params.col.(ids),'filled','XJitter','density','XJitterWidth',xjitw,'marker',params.mkr.(ids))
   
    calc_and_plot_box(axn(axn_start+16),sessions.(ids).(COI).medimm,plot_pos3(1,n),boxw,medcol,boxcol)
   calc_and_plot_box(axn(axn_start+16),sessions.(ids).(COI).medmov,plot_pos3(2,n),boxw,medcol,boxcol)
end
%ferret rCL
COI = 'rCL';
plot_pos4 = [18 21 24;19 22 25];
plot_ord4 = {'KIWL','BEAL','BEAR'};
for n = 1:3
    ids = plot_ord4{n};
   npoints = numel(sessions.(ids).(COI).medimm);
    plot(axn(axn_start+16),[plot_pos4(1,n)*ones(1,npoints); plot_pos4(2,n)*ones(1,npoints)],[sessions.(ids).(COI).medimm; sessions.(ids).(COI).medmov],'color',[0.5 0.5 0.5 0.25],'linewidth',0.8)
    swarmchart(axn(axn_start+16),plot_pos4(1,n)*ones(npoints,1),sessions.(ids).(COI).medimm,msize,params.col.imm,'filled','XJitter','density','XJitterWidth',xjitw,'marker',params.mkr.(ids))
    swarmchart(axn(axn_start+16),plot_pos4(2,n)*ones(npoints,1),sessions.(ids).(COI).medmov,msize,params.col.(ids),'filled','XJitter','density','XJitterWidth',xjitw,'marker',params.mkr.(ids))
   
    calc_and_plot_box(axn(axn_start+16),sessions.(ids).(COI).medimm,plot_pos4(1,n),boxw,medcol,boxcol)
   calc_and_plot_box(axn(axn_start+16),sessions.(ids).(COI).medmov,plot_pos4(2,n),boxw,medcol,boxcol)
end

set(axn(axn_start+16),'xlim',[0 25.6],'xtick',[1.5 4.5 7.5 10.5 13.5 18.5 21.5 24.5],'ylim',[0.15 0.7],'ytick',0.2:0.2:0.6,'xticklabel','','TickLabelInterpreter','tex','xcolor','none')
ylabel(axn(axn_start+16),'Autocorr. peak range')

% change in peak range
rdelta = [r.sessions_oCL.oCL_deltaPR;r.sessions_rCL.rCL_deltaPR];
fdelta = [f.sessions_oCL.oCL_deltaPR;f.sessions_rCL.rCL_deltaPR];

histogram(axn(axn_start+15),rdelta,'BinWidth',0.025,'FaceColor',params.col.R,'EdgeColor',params.col.R);
histogram(axn(axn_start+15),fdelta,'BinWidth',0.025,'FaceColor',params.col.F,'EdgeColor',params.col.F);

% set(axn(axn_start+16),'ylim',[-1 1],'yticklabel','','xlim',[0.5 2.5],'xtick',[1 2],'XTickLabel',{'or.','rad.'})
% plotXYlines(axn(axn_start+16),0,'lineExtent',[0.5,2.5],'color','k','linestyle',':','orientation','horizontal')

ylabel(axn(axn_start+15),'Sessions')
xlabel(axn(axn_start+15),'\Delta peak range','Interpreter','tex')



%% text
font_size_and_color(gcf,8)

f.cmap = magma(axn(axn_start+11).CLim(2));
r.cmap = magma(axn(axn_start+4).CLim(2));

text(axn(axn_start+1), txtpos(1),txtpos(2),[num2str(round(r.mspeedrCL(r.nepoch_highspeed),1)) ' cms^{-1}'],'interpreter','tex','FontSize',7,'Color',r.cmap(round(r.mspeedrCL(r.nepoch_highspeed)),:),'FontName','Arial','FontWeight','bold')
text(axn(axn_start+3), txtpos(1),txtpos(2),[num2str(round(r.mspeedrCL(r.nepoch_lowspeed),1)) ' cms^{-1}'],'interpreter','tex','FontSize',7,'Color',r.cmap(round(r.mspeedrCL(r.nepoch_lowspeed)),:),'FontName','Arial','FontWeight','bold')
text(axn(axn_start+8), txtpos(1),txtpos(2),[num2str(round(f.mspeedoCL(f.nepoch_highspeed),1)) ' cms^{-1}'],'interpreter','tex','FontSize',7,'Color',f.cmap(round(f.mspeedrCL(f.nepoch_highspeed)),:),'FontName','Arial','FontWeight','bold')
text(axn(axn_start+10), txtpos(1),txtpos(2),[num2str(round(f.mspeedoCL(f.nepoch_lowspeed),1)) ' cms^{-1}'],'interpreter','tex','FontSize',7,'Color',f.cmap(round(f.mspeedrCL(f.nepoch_lowspeed)),:),'FontName','Arial','FontWeight','bold')

% annotation('textarrow',[8.8/17 8.8/17],[8.8/25.2 9.4/25.2],'String',{'mov.', 'higher'},'FontSize',8,'Linewidth',1.1,'HeadStyle','vback3','HeadLength',7,'HeadWidth',7,'FontName','Arial','color',[0.15 0.15 0.15])
% annotation('textarrow',[8.8/17 8.8/17],[7.2/25.2 6.6/25.2],'String',{'imm.', 'higher'},'FontSize',8,'Linewidth',1.1,'HeadStyle','vback3','HeadLength',7,'HeadWidth',7,'FontName','Arial','color',[0.15 0.15 0.15])

title(axn,'')
keyboard
%print(gcf,'-dpdf','-r600','-painters','figure4_mov_vs_imm_MATLABoutput.pdf')
