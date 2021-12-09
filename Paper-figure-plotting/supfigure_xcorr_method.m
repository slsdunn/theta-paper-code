function supfigure_xcorr_method


params = get_parameters;   

r.ID = 'DBLUR';
r.ref = load_reference_table('R','ID',r.ID(1:4),'incl','neu','level','L5|6');
r.nsession = 10;
r.sref = r.ref(r.nsession,:);
r.mdata = load_metadata(r.sref);
r.cdata = load_neural_mapped(r.sref,r.mdata,[params.rCL.(r.ID)],'cleansignal');  
r.flt_desc = {'2_highpass';'49_51_bandstop'};
r.cdata = cheby2_filtfilthd(r.cdata,r.flt_desc{1},1000);
r.cdata = cheby2_filtfilthd(r.cdata,r.flt_desc{2},1000);
r.t_neu = load_neural_timeline(r.mdata);

r.nsegments    = floor(length(r.t_neu)/params.xcorr.win_samples);

r.dataepochsrCL = reshape(r.cdata(1:params.xcorr.win_samples*r.nsegments,1),params.xcorr.win_samples,r.nsegments);    
r.nanidxrCL     = any(isnan(r.dataepochsrCL));
r.dataepochsrCL(:,r.nanidxrCL) = [];
[r.XC_rCL,r.xcTbl_rCL]  = quantify_xcorr_epochs(r.dataepochsrCL(:,:,1),params.xcorr.R.freq_range,params.xcorr.freqResolution);


ref_freqs = params.xcorr.R.freq_range(1): params.xcorr.freqResolution:params.xcorr.R.freq_range(2);
[refXC, refED, refRange, refP1range, refT1range, refT2range] = create_sine_ref_xcorrs(ref_freqs,size(r.dataepochsrCL,1));

nseg = 536;
dataepoch = r.dataepochsrCL(:,nseg,1);
xcepoch   = r.XC_rCL(:,nseg);
xcepochrep = repmat(xcepoch,1,length(ref_freqs));
epochtbl = r.xcTbl_rCL(nseg,:);

ED  = naneucdist(xcepochrep',refXC');
normED = ED./refED';
[md,mi]= min(normED); 
freq = ref_freqs(mi);

samplefreq1 = 4.5;
sampleidx1  = ref_freqs==samplefreq1;
samplefreq2 = 13;
sampleidx2  = ref_freqs==samplefreq2;

t = 0:0.001:0.999;
egsine1 = sin(2*pi*4*t);
egsine2 = sin(2*pi*5*t);
egsine3 = sin(2*pi*6*t);
egxc1   = xcorr(egsine1);
egxc1 = egxc1/max(egxc1);
egxc2   = xcorr(egsine2);
egxc2 = egxc2/max(egxc2);
egxc3   = xcorr(egsine3);
egxc3 = egxc3/max(egxc3);

bgsinecol = [[43 38 26]/255 0.5];
txtpos = [1400,1];
sincol = [0.6 0.6 0.6];
%% plot
axn = supfigure_xcorr_method_makeFigure2;

plot(axn(1),dataepoch,'k','linewidth',0.5)
set(axn(1),'xcolor','none','ycolor','none')
plot(axn(2),xcepoch,'k','linewidth',0.5)
set(axn(2),'xcolor','none','ycolor','none')
imagesc(axn(3),xcepochrep')
plot(axn(3),[100 600] ,[-3 -3] ,'k', 'clipping','off','LineWidth',1.5)
text(axn(3),120,-10,'500 ms','FontName','Arial','FontSize',8)
set(axn(3),'ylim',[0 length(ref_freqs)],'ycolor','none','xcolor','none')


plot_trace_across_chans(axn(4),[egsine1;egsine2;egsine3]','scalefactor',0.4,'linewidth',0.5,'color',sincol);
set(axn(4),'xcolor','none','ycolor','none')

plot_trace_across_chans(axn(5),[egxc1;egxc2;egxc3]','scalefactor',0.4,'linewidth',0.5,'color',sincol);
set(axn(5),'xcolor','none','ycolor','none')


imagesc(axn(6),refXC')
plot(axn(6),[100 600] ,[104 104] ,'k', 'clipping','off','LineWidth',1.5)
set(axn(6),'ylim',[0 length(ref_freqs)],'Xcolor','none','ytick',1:20:101,'YTickLabel',ref_freqs(1:20:101),'ydir','reverse')
text(axn(6),120,111,'500 ms','FontName','Arial','FontSize',8)
ylabel(axn(6),'Sine frequency (Hz)')


plot(axn(7),ED,1:length(ED),'k')
set(axn(7),'ylim',[0 length(ref_freqs)],'ydir','reverse','xlim',[7.5 22.5],'ycolor','none')
xlabel(axn(7),{'Euc.', 'Dist.'})

plot(axn(8),refED,1:length(refED),'color',sincol)
set(axn(8),'ylim',[0 length(ref_freqs)],'ydir','reverse','xlim',[17.8 18.8],'xtick',[18 18.5],'ycolor','none','XAxisLocation','top','color','none','xcolor',sincol)

plot(axn(9),normED,1:length(normED),'k')
plotXYlines(axn(9),find(sampleidx1),'orientation','horizontal','color',[0.5 0.5 0.5])
plotXYlines(axn(9),mi,'orientation','horizontal','color',[0.5 0.5 0.5])
plotXYlines(axn(9),find(sampleidx2),'orientation','horizontal','color',[0.5 0.5 0.5])
set(axn(9),'ylim',[0 length(ref_freqs)],'ydir','reverse','xlim',[0.4 1.2],'ycolor','none')
xlabel(axn(9),{'Norm.', 'Euc. Dist.'})

plot(axn(10),refXC(:,sampleidx1),'color',[0.8 0.1 0.1 0.5])
plot(axn(10),xcepoch,'k')
text(axn(10),txtpos(1),txtpos(2),{['ED = ' num2str(round(normED(sampleidx1),2))];['sine freq. = ' num2str(samplefreq1) ' Hz']},'FontName','Arial','FontSize',8)

plot(axn(11),refXC(:,mi),'color',bgsinecol)
plot_rectangle(axn(11),1000,1222,1,-1,[0.5 0.5 0.5],0.8,':')
plot(axn(11),xcepoch,'k')
text(axn(11),txtpos(1),txtpos(2),{['ED = ' num2str(round(normED(mi),2))];['sine freq. = ' num2str(ref_freqs(mi)) ' Hz']},'FontName','Arial','FontSize',8)

plot(axn(12),refXC(:,sampleidx2),'color',[0.8 0.1 0.1 0.5])
plot(axn(12),xcepoch,'k')
text(axn(12),txtpos(1),txtpos(2),{['ED = ' num2str(round(normED(sampleidx2),2))];['sine freq. = ' num2str(samplefreq2) ' Hz']},'FontName','Arial','FontSize',8)
plot(axn(12),[1650 1900] ,[-1 -1] ,'k', 'clipping','off','LineWidth',1.5)
text(axn(12),1650,-1.2,'250 ms','FontName','Arial','FontSize',8)

set(axn(10:12),'xcolor','none','xlim',[1000 1999])

maxcurve  = refXC(refP1range(1,mi):refP1range(2,mi),mi);
mincurve1 = refXC(refT1range(1,mi):refT1range(2,mi),mi);
mincurve2 = refXC(refT2range(1,mi):refT2range(2,mi),mi);
[refpeak,refpeaki] = max(maxcurve);
refpeaki = refpeaki + refP1range(1,mi);

shade_between_lines(axn(13),refP1range(1,mi):refP1range(2,mi),[zeros(length(maxcurve),1),maxcurve ],[1 1 0],0.25)
shade_between_lines(axn(13),refT1range(1,mi):refT1range(2,mi),[zeros(length(mincurve1),1),mincurve1 ],[0.5 0 0.8],0.25)
shade_between_lines(axn(13),refT2range(1,mi):refT2range(2,mi),[zeros(length(mincurve2),1),mincurve2 ],[0.5 0 0.8],0.25)
plot(axn(13),refXC(:,mi),'color',bgsinecol)
plot(axn(13),[refpeaki refpeaki],[refpeak refpeak-refRange(mi)],'color',[0.4 0.4 0.4],'LineWidth',3)
plot(axn(13),xcepoch,'color','k')
plot(axn(13),epochtbl.trough1i,epochtbl.trough1,'k','LineStyle','none','Marker','o','MarkerFaceColor','k','MarkerSize',4)
plot(axn(13),epochtbl.trough2i,epochtbl.trough2,'k','LineStyle','none','Marker','o','MarkerFaceColor','k','MarkerSize',4)
plot(axn(13),[epochtbl.peak1i epochtbl.peak1i],[epochtbl.peak1 epochtbl.peak1-epochtbl.peakrange],'color',[0 202 34]/255,'LineWidth',3)
plot(axn(13),epochtbl.peak1i,epochtbl.peak1,'k','LineStyle','none','Marker','o','MarkerFaceColor','k','MarkerSize',4)
plot(axn(13),[1000 epochtbl.peak1i],[epochtbl.peak1 epochtbl.peak1],'color',[0 202 34]/255,'LineWidth',1,'LineStyle','--')
plot(axn(13),[1000 epochtbl.peak1i],[epochtbl.peak1-epochtbl.peakrange epochtbl.peak1-epochtbl.peakrange],'color',[0 202 34]/255,'LineWidth',1,'LineStyle','--')
plot(axn(13),[1000 refpeaki],[refpeak refpeak],'color',[0.4 0.4 0.4],'LineWidth',1,'LineStyle','--')
plot(axn(13),[1000 refpeaki],[refpeak-refRange(mi) refpeak-refRange(mi)],'color',[0.4 0.4 0.4],'LineWidth',1,'LineStyle','--')
plot(axn(13),[1150 1200] ,[-1 -1] ,'k', 'clipping','off','LineWidth',1.5)
text(axn(13),1150,-1.2,'50 ms','FontName','Arial','FontSize',8)

set(axn(13),'xcolor','none','xlim',[1000 1225],'ytick',[-1 0 1])

plot(axn(14),ref_freqs,refRange,'color',sincol)
xlabel(axn(14),'Sine frequency (Hz)')
ylabel(axn(14),{'Sine autocorr.', 'peak range'})

title(axn,'')
font_size_and_color(gcf,8)

%print(gcf,'-dpdf','-r600','-painters','supfigure_xcorr_method_MATLABoutput2.pdf')
end



function [refXC, refED, refRange, refP1range, refT1range, refT2range] = create_sine_ref_xcorrs(ref_freqs,datsize)

reft = 0:1/1000:(datsize-1)/1000;

refXC      = NaN(length(reft)*2-1,length(ref_freqs)); % preallocate
refRange   = NaN(numel(ref_freqs),1);
refPTIdx   = NaN(3,numel(ref_freqs));
refP1range = NaN(2,numel(ref_freqs));
refT1range = NaN(2,numel(ref_freqs));
refT2range = NaN(2,numel(ref_freqs));

for n = 1:numel(ref_freqs) % for each frequency
    refsig = sin(2*pi*ref_freqs(n)*reft);  % calc sine
    refxc = xcorr(refsig,refsig);          % autocorrelogram of sine
    refxc = refxc./max(refxc);
    refXC(:,n) = refxc;
    
    %% find peak range for reference sine autocorrelogram
    [maxP,minP] = findMinMax(refxc,0.05,'fixed');   % find extrema

    midpeaki = find(maxP(:,1)==datsize);  % find peak/troughs of interest (first peak after centre)
    peak1 = maxP(midpeaki+1,:);
    trough1i = find(minP(:,1)<peak1(1));
    trough1i = trough1i(end);
    trough2i = find(minP(:,1)>peak1(1));
    trough2i = trough2i(1);
    trough1 = minP(trough1i,:);
    trough2 = minP(trough2i,:);
    
    refRange(n) = peak1(2) - mean([trough1(2),trough2(2)]); % find peak range for sine autocorrelogram
    
    refPTIdx(1,n) = trough1(1);
    refPTIdx(2,n) = peak1(1);
    refPTIdx(3,n) = trough2(1);   
    
    %% find regions over which max/min of data autocorr will be found
    interceptpoints = zero_crossings(refxc);
    belowt1 =interceptpoints(interceptpoints < trough1(1));
    abovet2 =interceptpoints(interceptpoints > trough2(1));
    abovep1 =interceptpoints(interceptpoints > peak1(1));
    belowp1 =interceptpoints(interceptpoints < peak1(1));
    
    refP1range(1,n) = round(belowp1(end));
    refP1range(2,n) = round(abovep1(1));
    refT1range(1,n) = round(belowt1(end));
    refT1range(2,n) = round(belowp1(end));
    refT2range(1,n) = round(abovep1(1));
    refT2range(2,n) = round(abovet2(1));
    
end
refED = vecnorm(refXC); % calc euc. dist of each ref sine AC
end