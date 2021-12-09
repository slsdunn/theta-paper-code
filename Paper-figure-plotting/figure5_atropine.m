function figure5_atropine
params = get_parameters;

ref  = load_reference_table('F','incl','neu','modality','ATR');
aref = load_atropine_dose_table(0.6,'greater',1);

atropineref = ref(ismember(ref.ExtractedFile,aref.ExtractedFile),:);

% first non-atropine session following atropine sessions in aref
controlblocks.KIW = {'BlockA-3','BlockA-14','BlockA-17'};
controlblocks.ANI = {'BlockA-19','BlockA-30','BlockA-33','Block-65','BlockA-72','BlockA-76','BlockA-79'};
controlrefidx1    = and(contains(ref.ID,'KIW'),ismember(ref.Block,controlblocks.KIW));
controlrefidx2    = and(contains(ref.ID,'ANI'),ismember(ref.Block,controlblocks.ANI));
controlref        = ref(or(controlrefidx1,controlrefidx2),:);

% load data
alldata = readtable(fullfile(params.figDataPath,'figure4rawdata.csv'));
alldata.IDside(:) = {[]};
alldata.IDside(contains(alldata.ID,'KIW')) = {'KIWR'};
alldata.IDside(contains(alldata.ID,'ANI')&contains(alldata.Chan,'periCL')) = {'ANIL'};
alldata.IDside(contains(alldata.ID,'ANI')&contains(alldata.Chan,'subCL')) = {'ANIR'};

atrdata = alldata(contains(alldata.DrugFlag,'A'),:);
condata = alldata(contains(alldata.DrugFlag,'C'),:);


%% example traces
%% atropine example
ID = 'ANIR';
COI = params.atr.(ID);
a.session = 'ANI_BlockA-78_RHS_CX.mat';
a.ref     = atropineref(contains(atropineref.ExtractedFile,a.session),:);
a.mdata   = load_metadata(a.ref);
a.cdata   = load_neural_mapped(a.ref,a.mdata,COI,'cleansignal');
a.cdata   = cheby2_filtfilthd(a.cdata,'1_highpass',1000);
a.cdata   = cheby2_filtfilthd(a.cdata,'49_51_bandstop',1000);
a.t_neu   = load_neural_timeline(a.mdata);
a.speed   = load_tracking_speed(a.ref,a.mdata,a.t_neu);
a.tlims   = [312 332];% [2360 2380][1164 1184]
a.tidx    = [a.tlims(1)-2 a.tlims(2)+2];
a.nidx = interp1(a.t_neu,1:length(a.t_neu),a.tidx ,'nearest');
a.section   = a.cdata(a.nidx(1):a.nidx(2));
a.speed_section = a.speed(a.nidx(1):a.nidx(2));
a.t_section = a.t_neu(a.nidx(1):a.nidx(2));
a.freq_range = [1.5 10];
a.SR = 1000;
a.w = 1024;  % window, default is hamming
a.noverlap = 6*a.w/8; % default is 50%
a.N = length(a.section);
a.F = a.freq_range(1):(a.SR/(a.N-1)):a.freq_range(2);

[~,a.F,a.T,a.P] = spectrogram(a.section,a.w,a.noverlap,a.F,a.SR);
a.normP = a.P/max(max(a.P));

% segment data
a.nsegments    = floor(length(a.t_neu)/params.xcorr.win_samples);
a.speedepochs  = reshape(a.speed(1:params.xcorr.win_samples*a.nsegments),params.xcorr.win_samples,a.nsegments);
a.mspeedepochs = mean(a.speedepochs);
a.speednanidx  = isnan(a.mspeedepochs);

a.dataepochs = reshape(a.cdata(1:params.xcorr.win_samples*a.nsegments,1),params.xcorr.win_samples,a.nsegments);    
a.nanidx     = any(isnan(a.dataepochs)) | a.speednanidx;
a.dataepochs(:,a.nanidx) = [];
a.mspeed     = a.mspeedepochs(~a.nanidx);

[a.XC,a.xcTbl]  = quantify_xcorr_epochs(a.dataepochs(:,:,1),params.xcorr.F.freq_range,params.xcorr.freqResolution);

a.highspeed = 33; 
a.lowspeed  = 0; %0.75; 
[~,a.nepoch_lowspeed] = min(abs(a.mspeed-a.lowspeed));
[~,a.nepoch_highspeed] = min(abs(a.mspeed-a.highspeed));

t = 0:1/1000:1 - 1/1000;
a.highxc = xcorr(sin(2*pi*a.xcTbl.freq(a.nepoch_highspeed)*t),sin(2*pi*a.xcTbl.freq(a.nepoch_highspeed)*t));
a.highxc = a.highxc/max(a.highxc);
a.lowxc = xcorr(sin(2*pi*a.xcTbl.freq(a.nepoch_lowspeed)*t),sin(2*pi*a.xcTbl.freq(a.nepoch_lowspeed)*t));
a.lowxc = a.lowxc/max(a.lowxc);

%% control example
c.session = 'ANI_BlockA-79_RHS_CX.mat';
c.ref     = controlref(contains(controlref.ExtractedFile,c.session),:);
c.mdata   = load_metadata(c.ref);
c.cdata   = load_neural_mapped(c.ref,c.mdata,COI,'cleansignal');
c.cdata   = cheby2_filtfilthd(c.cdata,'1_highpass',1000);
c.cdata   = cheby2_filtfilthd(c.cdata,'49_51_bandstop',1000);
c.t_neu   = load_neural_timeline(c.mdata);
c.speed   = load_tracking_speed(c.ref,c.mdata,c.t_neu);
c.tlims   = [98 118];
c.tidx    = [96 120];
c.nidx = interp1(c.t_neu,1:length(c.t_neu),c.tidx ,'nearest');
c.section   = c.cdata(c.nidx(1):c.nidx(2));
c.speed_section = c.speed(c.nidx(1):c.nidx(2));
c.t_section = c.t_neu(c.nidx(1):c.nidx(2));
c.freq_range = [1.5 10];
c.SR = 1000;
c.w = 1024;  % window, default is hamming
c.noverlap = 6*c.w/8; % default is 50%
c.N = length(c.section);
c.F = c.freq_range(1):(c.SR/(c.N-1)):c.freq_range(2);

[~,c.F,c.T,c.P] = spectrogram(c.section,c.w,c.noverlap,c.F,c.SR);
c.normP = c.P/max(max(c.P));

% segment data
c.nsegments    = floor(length(c.t_neu)/1000);
c.speedepochs  = reshape(c.speed(1:1000*c.nsegments),1000,c.nsegments);
c.mspeedepochs = mean(c.speedepochs);
c.speednanidx  = isnan(c.mspeedepochs);

c.dataepochs = reshape(c.cdata(1:1000*c.nsegments,1),1000,c.nsegments);    
c.nanidx     = any(isnan(c.dataepochs)) | c.speednanidx;
c.dataepochs(:,c.nanidx) = [];
c.mspeed     = c.mspeedepochs(~c.nanidx);

[c.XC,c.xcTbl]  = quantify_xcorr_epochs(c.dataepochs(:,:,1),params.xcorr.F.freq_range,params.xcorr.freqResolution);

c.highspeed = 32.5; %36.5; 
c.lowspeed  = 0.1;%1; 
[~,c.nepoch_lowspeed] = min(abs(c.mspeed-c.lowspeed));
[~,c.nepoch_highspeed] = min(abs(c.mspeed-c.highspeed));

t = 0:1/1000:1 - 1/1000;
c.highxc = xcorr(sin(2*pi*c.xcTbl.freq(c.nepoch_highspeed)*t),sin(2*pi*c.xcTbl.freq(c.nepoch_highspeed)*t));
c.highxc = c.highxc/max(c.highxc);
c.lowxc = xcorr(sin(2*pi*c.xcTbl.freq(c.nepoch_lowspeed)*t),sin(2*pi*c.xcTbl.freq(c.nepoch_lowspeed)*t));
c.lowxc = c.lowxc/max(c.lowxc);



%% plot
axn = figure5_atropine_makeFigure;
title(axn,'')
txtpos = [360,0.85];

% control 20s example trace
plot(axn(1),c.t_section,c.speed_section,'k','linewidth',1)
plot(axn(2),c.t_section,c.section,'color',params.col.F,'linewidth',1)
imagesc(axn(3),c.T+c.t_section(1),c.F,10*log10(c.normP));
plot(axn(3),[c.tlims(end)-2.5 c.tlims(end)-1.5],[0.75 0.75],'k','linewidth',1.5,'clipping','off')
colormap(axn(3),viridis)
set(axn(1:3),'xlim',c.tlims,'clim',[-30 -2],'xticklabel','')
set(axn(2),'xcolor','none','ylim',[-1.57 1.2],'ytick',[-1 0 1])
set(axn(3),'ylim',c.freq_range,'ytick',[4 8])
spectcb = colorbar(axn(3),'eastoutside','position',[0.945    0.79    0.019    0.03]);
spectcb.Label.String = 'dB/Hz';
spectcb.Label.Rotation = 0;
spectcb.Label.Position = [1.0225   14.9968   0];
text(axn(3),c.tlims(end)-2.6,-0.3,'1 sec')
ylabel(axn(1),{'Speed','(cms^{-1})'},'interpreter','tex')
ylabel(axn(2),{'Amp.','(mV)'})
ylabel(axn(3),{'Freq.','(Hz)'})

% atropine 20s example trace
plot(axn(4),a.t_section,a.speed_section,'k','linewidth',1)
plot(axn(5),a.t_section,a.section,'color',params.col.atr,'linewidth',1)
imagesc(axn(6),a.T+a.t_section(1),a.F,10*log10(a.normP));
plot(axn(6),[a.tlims(end)-2.5 a.tlims(end)-1.5],[0.75 0.75],'k','linewidth',1.5,'clipping','off')
set(axn(4:6),'xlim',a.tlims,'clim',[-30 -5],'xticklabel','')
colormap(axn(6),viridis)
set(axn(5),'xcolor','none','ylim',[-1.65 1.2])
set(axn(6),'ylim',a.freq_range,'ytick',[4 8])
spectcb2 = colorbar(axn(6),'eastoutside','position',[0.945    0.595    0.019    0.03]);
spectcb2.Label.String = 'dB/Hz';
spectcb2.Label.Rotation = 0;
spectcb2.Label.Position = [1.0225   14.9968   0];
text(axn(6),a.tlims(end)-2.6,-0.3,'1 sec')
ylabel(axn(4),{'Speed','(cms^{-1})'},'interpreter','tex')
ylabel(axn(5),{'Amp.','(mV)'})
ylabel(axn(6),{'Freq.','(Hz)'})

% moving data autocorrs examples
plot(axn(11),c.dataepochs(:,c.nepoch_highspeed,1),'color',params.col.F,'LineWidth',1)
plot(axn(12),c.highxc(ceil(size(c.XC,1)/2):end),'color',[0.3 0.3 0.3 0.5],'LineWidth',0.8,'LineStyle','-')
plot(axn(12),c.XC(ceil(size(c.XC,1)/2):end,c.nepoch_highspeed),'k','LineWidth',1)
plotXYlines(axn(12),c.xcTbl.peak1i(c.nepoch_highspeed)-ceil(size(c.XC,1)/2),'color','k','lineExtent',[mean([c.xcTbl.trough1(c.nepoch_highspeed), c.xcTbl.trough2(c.nepoch_highspeed)])  c.xcTbl.peak1(c.nepoch_highspeed)],'linestyle','-')
set(axn(11),'xcolor','none','ycolor','none')
set(axn(12),'xcolor','none','ylim',[-1 1])
ylabel(axn(12),'r')
line(axn(12),[650 850],[-0.75 -0.75],'color','k','linewidth',1.5,'clipping','off')
text(axn(12),500,-1.24,'200 ms')
text(axn(12), txtpos(1),txtpos(2),[num2str(round(c.mspeed(c.nepoch_highspeed),1)) ' cms^{-1}'],'interpreter','tex','FontSize',7,'FontName','Arial')

plot(axn(13),a.dataepochs(:,a.nepoch_highspeed,1),'color',params.col.atr,'LineWidth',1)
plot(axn(14),a.highxc(ceil(size(a.XC,1)/2):end),'color',[0.3 0.3 0.3 0.5],'LineWidth',0.8,'LineStyle','-')
plot(axn(14),a.XC(ceil(size(a.XC,1)/2):end,a.nepoch_highspeed),'k','LineWidth',1)
plotXYlines(axn(14),a.xcTbl.peak1i(a.nepoch_highspeed)-ceil(size(a.XC,1)/2),'color','k','lineExtent',[mean([a.xcTbl.trough1(a.nepoch_highspeed), a.xcTbl.trough2(a.nepoch_highspeed)])  a.xcTbl.peak1(a.nepoch_highspeed)],'linestyle','-')
set(axn(13),'xcolor','none','ycolor','none')
set(axn(14),'xcolor','none','ylim',[-1 1])
line(axn(14),[650 850],[-0.75 -0.75],'color','k','linewidth',1.5,'clipping','off')
text(axn(14),500,-1.24,'200 ms')
text(axn(14), txtpos(1),txtpos(2),[num2str(round(a.mspeed(a.nepoch_highspeed),1)) ' cms^{-1}'],'interpreter','tex','FontSize',7,'FontName','Arial')

% immobile data autocorrs examples
plot(axn(7),c.dataepochs(:,c.nepoch_lowspeed,1),'color',params.col.imm,'LineWidth',1)
plot(axn(8),c.lowxc(ceil(size(c.XC,1)/2):end),'color',[0.3 0.3 0.3 0.5],'LineWidth',0.8,'LineStyle','-')
plot(axn(8),c.XC(ceil(size(c.XC,1)/2):end,c.nepoch_lowspeed),'k','LineWidth',1)
plotXYlines(axn(8),c.xcTbl.peak1i(c.nepoch_lowspeed)-ceil(size(c.XC,1)/2),'color','k','lineExtent',[mean([c.xcTbl.trough1(c.nepoch_lowspeed), c.xcTbl.trough2(c.nepoch_lowspeed)])  c.xcTbl.peak1(c.nepoch_lowspeed)],'linestyle','-')
set(axn(7),'xcolor','none','ycolor','none')
set(axn(8),'xcolor','none','ylim',[-1 1])
ylabel(axn(8),'r')
line(axn(8),[650 850],[-0.75 -0.75],'color','k','linewidth',1.5,'clipping','off')
text(axn(8),500,-1.24,'200 ms')
text(axn(8), txtpos(1),txtpos(2),[num2str(round(c.mspeed(c.nepoch_lowspeed),1)) ' cms^{-1}'],'interpreter','tex','FontSize',7,'FontName','Arial')

plot(axn(9),a.dataepochs(:,a.nepoch_lowspeed,1),'color',params.col.atr,'LineWidth',1)
plot(axn(10),a.lowxc(ceil(size(a.XC,1)/2):end),'color',[0.3 0.3 0.3 0.5],'LineWidth',0.8,'LineStyle','-')
plot(axn(10),a.XC(ceil(size(a.XC,1)/2):end,a.nepoch_lowspeed),'k','LineWidth',1)
plotXYlines(axn(10),a.xcTbl.peak1i(a.nepoch_lowspeed)-ceil(size(a.XC,1)/2),'color','k','lineExtent',[mean([a.xcTbl.trough1(a.nepoch_lowspeed), a.xcTbl.trough2(a.nepoch_lowspeed)])  a.xcTbl.peak1(a.nepoch_lowspeed)],'linestyle','-')
set(axn(9),'xcolor','none','ycolor','none')
set(axn(10),'xcolor','none','ylim',[-1 1])
line(axn(10),[650 850],[-0.75 -0.75],'color','k','linewidth',1.5,'clipping','off')
text(axn(10),500,-1.24,'200 ms')
text(axn(10), txtpos(1),txtpos(2),[num2str(round(a.mspeed(a.nepoch_lowspeed),1)) ' cms^{-1}'],'interpreter','tex','FontSize',7,'FontName','Arial')

% group data
boxcol = [0.2 0.2 0.2];
medcol =[0.1 0.1 0.1];
msize = 10;
boxw = 0.3;
plot_pos = [1 4 7;2 5 8];

ids = {'KIWR','ANIL','ANIR'};

for n = 1:numel(ids)
    
    idatr = atrdata(contains(atrdata.IDside,ids{n}),:);
    idcon = condata(contains(condata.IDside,ids{n}),:);
    
    movcon = idcon.Peakrangenorm(contains(idcon.MovFlag,'mov'));
    movatr = idatr.Peakrangenorm(contains(idatr.MovFlag,'mov'));
    immcon = idcon.Peakrangenorm(contains(idcon.MovFlag,'imm'));
    immatr = idatr.Peakrangenorm(contains(idatr.MovFlag,'imm'));
    
    ndatapoints.atr.mov(n) = numel(movatr);
    ndatapoints.atr.imm(n) = numel(immatr);
    ndatapoints.con.mov(n) = numel(movcon);
    ndatapoints.con.imm(n) = numel(immcon);
    
    swarmchart(axn(17),plot_pos(1,n)*ones(size(movcon)),movcon,msize,params.col.F,'filled','XJitter','density','XJitterWidth',0.8,'marker',params.mkr.(ids{n}))
    calc_and_plot_box(axn(17),movcon,plot_pos(1,n),boxw,medcol,boxcol)
   
     swarmchart(axn(17),plot_pos(2,n)*ones(size(movatr)),movatr,msize,params.col.atr,'filled','XJitter','density','XJitterWidth',0.8,'marker',params.mkr.(ids{n}))
    calc_and_plot_box(axn(17),movatr,plot_pos(2,n),boxw,medcol,boxcol)
  
     swarmchart(axn(15),plot_pos(1,n)*ones(size(immcon)),immcon,msize,params.col.imm,'filled','XJitter','density','XJitterWidth',0.8,'marker',params.mkr.(ids{n}))
    calc_and_plot_box(axn(15),immcon,plot_pos(1,n),boxw,medcol,boxcol)
   
     swarmchart(axn(15),plot_pos(2,n)*ones(size(immatr)),immatr,msize,params.col.atr,'filled','XJitter','density','XJitterWidth',0.8,'marker',params.mkr.(ids{n}))
      calc_and_plot_box(axn(15),immatr,plot_pos(2,n),boxw,medcol,boxcol)
     
end

set(axn(15),'ylim',[0 1],'xlim',[0.4 8.6],'xtick',[1.5 4.5 7.5],'xticklabel',{'F1_R','F4_{periCL}','F4_{subCL}'},'TickLabelInterpreter','tex')
set(axn(17),'ylim',[0 1],'xlim',[0.4 8.6],'xtick',[1.5 4.5 7.5],'xticklabel',{'F1_R','F4_{periCL}','F4_{subCL}'},'TickLabelInterpreter','tex')

ylabel(axn(15),'Autocorr. peak range')
ylabel(axn(17),'Autocorr. peak range')

% stats done in R - beta coeffs for single factor model
mov_drugflagC = -0.007;
mov_drugflagC_ci = [-0.033, 0.020];
imm_drugflagC = 0.129;
imm_drugflagC_ci = [0.116, 0.141];

plotXYlines(axn(16),0,'lineExtent',[0 3],'linewidth',0.8,'color',[0.1 0.1 0.1],'linestyle',':','orientation','horizontal')
plot(axn(16),[1 1],imm_drugflagC_ci,'color',[params.col.imm 0.7],'LineWidth',2)
plot(axn(16),[2 2],mov_drugflagC_ci,'color',[params.col.F 0.7],'LineWidth',2)
plot(axn(16),1,imm_drugflagC,'LineStyle','none','Marker','o','MarkerFaceColor',[params.col.imm],'MarkerEdgeColor',[params.col.imm],'MarkerSize',3)
plot(axn(16),2,mov_drugflagC,'LineStyle','none','Marker','o','MarkerFaceColor',[params.col.F],'MarkerEdgeColor',[params.col.F],'MarkerSize',3)

set(axn(16),'xlim',[0.5 2.5],'xcolor','none')
ylabel(axn(16),['LME ' char(946) '_{1} coefficient'],'Interpreter','tex')

font_size_and_color(gcf,8)
keyboard
%print(gcf,'-dpdf','-r600','-painters','figure5_atropine_MATLABoutput.pdf')