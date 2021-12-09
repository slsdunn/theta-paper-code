function supfigure_spectrograms_ferret

params = get_parameters;
ref = load_reference_table('F','incl','neu','modality','A|V','level','L5|6');

COIs = {'oCL','rCL'};
for nc = 1:2
    [f.(COIs{nc}).trialtbl, f.(COIs{nc}).trialneu,f.(COIs{nc}).trialspd] = load_trial_data(ref,COIs{nc},1,'HoldEnd',5);
end

axn = supfigure_spectrograms_ferret_makeFigure;
ids = params.F.plotorder_recside_linprobe;
tvec = 0:1/1000:10;

% oCL, indivual ferrets, hold time = 3.5s
COI = 'oCL';
ax2plot = [1 2; 3 4; 5 6; 7 8; 9 10];
for n = 1:5
    idx = and(contains(f.(COI).trialtbl.IDside,ids{n}),f.(COI).trialtbl.HoldTime==3500);
    mspeed  = mean(f.(COI).trialspd(:,idx),2);
    sdspeed = std(f.(COI).trialspd(:,idx),[],2);
    
    shade_between_lines(axn(ax2plot(n,1)),tvec,[mspeed-sdspeed mspeed+sdspeed],params.col.(ids{n}),0.3)
    plot(axn(ax2plot(n,1)),tvec,mspeed,'color',params.col.(ids{n}))
    plot_mean_spectrogram(axn(ax2plot(n,2)),f.(COI).trialneu(:,idx),[2 12],1,1)
    plotXYlines(axn(ax2plot(n,1)),[5-3.5 5],'lineExtent',[0 100])
    plotXYlines(axn(ax2plot(n,2)),[5-3.5 5])
    title(axn(ax2plot(n,1)),params.lbl.(ids{n}),'Interpreter','tex','Position',[0.8 0.5])
    title(axn(ax2plot(n,2)),'')
    set(axn(ax2plot(n,1)),'ylim',[0 85],'ytick',[0 50],'YTickLabel','')
    set(axn(ax2plot(n,2)),'ytick',[5 10],'YTickLabel','','XTickLabel','')
end

% oCL, all ferrets, different hold times
COI = 'oCL';
hts = [2500 2750 3000 3250 3500];
ax2plot = [11 12; 13 14; 15 16; 17 18; 19 20];
for n = 1:5
    idx = f.(COI).trialtbl.HoldTime==hts(n);
    mspeed  = mean(f.(COI).trialspd(:,idx),2);
    sdspeed = std(f.(COI).trialspd(:,idx),[],2);
    
    shade_between_lines(axn(ax2plot(n,1)),tvec,[mspeed-sdspeed mspeed+sdspeed],'k',0.3)
    plot(axn(ax2plot(n,1)),tvec,mspeed,'color','k')
    plot_mean_spectrogram(axn(ax2plot(n,2)),f.(COI).trialneu(:,idx),[2 12],1,1)
    plotXYlines(axn(ax2plot(n,1)),[5-(hts(n)/1000) 5],'lineExtent',[0 100])
    plotXYlines(axn(ax2plot(n,2)),[5-(hts(n)/1000) 5])
    title(axn(ax2plot(n,1)),'')
    title(axn(ax2plot(n,2)),'')
    set(axn(ax2plot(n,1)),'ylim',[0 85],'ytick',[0 50],'YTickLabel','')
    set(axn(ax2plot(n,2)),'ytick',[5 10],'YTickLabel','','XTickLabel','')
end

% rCL, indivual ferrets, hold time = 3.5s
COI = 'rCL';
ax2plot = [21 22; 23 24; 25 26; 27 28; 29 30];
for n = 1:5
    idx = and(contains(f.(COI).trialtbl.IDside,ids{n}),f.(COI).trialtbl.HoldTime==3500);
    if sum(idx)==0
        continue
    end
    mspeed  = mean(f.(COI).trialspd(:,idx),2);
    sdspeed = std(f.(COI).trialspd(:,idx),[],2);
    
    shade_between_lines(axn(ax2plot(n,1)),tvec,[mspeed-sdspeed mspeed+sdspeed],params.col.(ids{n}),0.3)
    plot(axn(ax2plot(n,1)),tvec,mspeed,'color',params.col.(ids{n}))
    plot_mean_spectrogram(axn(ax2plot(n,2)),f.(COI).trialneu(:,idx),[2 12],1,1)
    plotXYlines(axn(ax2plot(n,1)),[5-3.5 5],'lineExtent',[0 100])
    plotXYlines(axn(ax2plot(n,2)),[5-3.5 5])
    title(axn(ax2plot(n,1)),params.lbl.(ids{n}),'Interpreter','tex','Position',[0.8 0.6])
    title(axn(ax2plot(n,2)),'')
    set(axn(ax2plot(n,1)),'ylim',[0 85],'ytick',[0 50],'YTickLabel','')
    set(axn(ax2plot(n,2)),'ytick',[5 10],'YTickLabel','','XTickLabel','')
end


% rCL, all ferrets, different hold times
COI = 'rCL';
hts = [2500 2750 3000 3250 3500];
ax2plot = [31 32; 33 34; 35 36; 37 38; 39 40];
for n = 1:5
    idx = f.(COI).trialtbl.HoldTime==hts(n);
    if sum(idx)==0
        continue
    end
    mspeed  = mean(f.(COI).trialspd(:,idx),2);
    sdspeed = std(f.(COI).trialspd(:,idx),[],2);
    
    shade_between_lines(axn(ax2plot(n,1)),tvec,[mspeed-sdspeed mspeed+sdspeed],'k',0.3)
    plot(axn(ax2plot(n,1)),tvec,mspeed,'color','k')
    plot_mean_spectrogram(axn(ax2plot(n,2)),f.(COI).trialneu(:,idx),[2 12],1,1)
    plotXYlines(axn(ax2plot(n,1)),[5-(hts(n)/1000) 5],'lineExtent',[0 100])
    plotXYlines(axn(ax2plot(n,2)),[5-(hts(n)/1000) 5])
    title(axn(ax2plot(n,1)),'')
    title(axn(ax2plot(n,2)),'')
    set(axn(ax2plot(n,1)),'ylim',[0 85],'ytick',[0 50],'YTickLabel','')
    set(axn(ax2plot(n,2)),'ytick',[5 10],'YTickLabel','','XTickLabel','')
end

equalise_colour_bars
title(axn([11,31]),'All ferrets','Position',[0.5 1.2])
set(axn,'xlim',[0.5 9.5])
set(axn([9,29]),'YTickLabel',[0 50])
set(axn([10,30]),'xtick',[1 3 5 7 9],'XTickLabel',[-4 -2 0 2 4],'ytick',[5 10],'YTickLabel',[5 10])
set(axn([20,40]),'xtick',[1 3 5 7 9],'XTickLabel',[-4 -2 0 2 4])
xlabel(axn([10,30]),'Time from stimulus onset (s)')
ylabel(axn(9),{'Speed','(cms^{-1})'},'interpreter','tex')
ylabel(axn(10),{'Frequency','(Hz)'})
cb = colorbar(axn(40),'Location','southoutside','Position',[0.9286    0.0669    0.0516    0.0197]);
cb.Label.String = {'Power/Freq.', '(dB/Hz)'};
font_size_and_color(gcf,8)
delete(axn(23:26))


%print(gcf,'-dpdf','-r600','-painters','supfigure_spectrograms_ferret_MATLABoutput.pdf')