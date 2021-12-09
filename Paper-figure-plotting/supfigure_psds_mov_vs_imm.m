function supfigure_psds_mov_vs_imm

params = get_parameters;

%% load data
r.ids = params.R.plotorder_recside_linprobe;
for n = 1:3
    r.(r.ids{n}) = load(fullfile(params.R.processedDataPath,'speed_binned_psd',[r.ids{n} '_mov_vs_imm_psd.mat']));
end
f.ids = params.F.plotorder_recside_linprobe;
for n = 1:5
    f.(f.ids{n}) = load(fullfile(params.F.processedDataPath,'speed_binned_psd',[f.ids{n} '_mov_vs_imm_psd.mat']));
end


%% make figure
axn = supfigure_psds_mov_vs_imm_makeFigure;

%% plot mov vs imm
% rat
for n = 1:3
    plot(axn(n+(n-1)),r.(r.ids{n}).fxx,10*log10(squeeze(r.(r.ids{n}).pxx_mov(:,params.oCL.(r.ids{n}),:))),'color',[params.col.(r.ids{n}) 0.25])
    plot(axn(n+(n-1)),r.(r.ids{n}).fxx,10*log10(squeeze(r.(r.ids{n}).pxx_imm(:,params.oCL.(r.ids{n}),:))),'color',[params.col.imm 0.25])
    
    if ~ isempty(params.rCL.(r.ids{n}))
        plot(axn(n+(n-1)+1),r.(r.ids{n}).fxx,10*log10(squeeze(r.(r.ids{n}).pxx_mov(:,params.rCL.(r.ids{n}),:))),'color',[params.col.(r.ids{n}) 0.25])
        plot(axn(n+(n-1)+1),r.(r.ids{n}).fxx,10*log10(squeeze(r.(r.ids{n}).pxx_imm(:,params.rCL.(r.ids{n}),:))),'color',[params.col.imm 0.25])
    end
end
% ferret
for n = 1:5
    plot(axn(n+(n-1)+5),f.(f.ids{n}).fxx,10*log10(squeeze(f.(f.ids{n}).pxx_mov(:,params.oCL.(f.ids{n}),:))),'color',[params.col.(f.ids{n}) 0.5])
    plot(axn(n+(n-1)+5),f.(f.ids{n}).fxx,10*log10(squeeze(f.(f.ids{n}).pxx_imm(:,params.oCL.(f.ids{n}),:))),'color',[params.col.imm 0.5])
    
    if ~ isempty(params.rCL.(f.ids{n}))
        plot(axn(n+(n-1)+6),f.(f.ids{n}).fxx,10*log10(squeeze(f.(f.ids{n}).pxx_mov(:,params.rCL.(f.ids{n}),:))),'color',[params.col.(f.ids{n}) 0.5])
        plot(axn(n+(n-1)+6),f.(f.ids{n}).fxx,10*log10(squeeze(f.(f.ids{n}).pxx_imm(:,params.rCL.(f.ids{n}),:))),'color',[params.col.imm 0.5])
    end
end
set(axn([1:8,10:15]),'xlim',[0 30])
set(axn([1,3,6,12,14]),'xticklabel',[])
set(axn(1:5),'ylim',[-45 -5])
set(axn([6,8,10,12:15]),'ylim',[-55 -5])
set(axn([7,13,15]),'ylim',[-50 -12])
xlabel(axn([2,7]),'Freq. (Hz)')
ylabel(axn([2,7]),'Power/Frequency (dB/Hz)')

%% harmonic power ratio
fxx = f.KIWL.fxx;
thetarange  = [4 7];
fshift = [-2 3];
thetarangei = interp1(fxx,1:numel(fxx),thetarange,'nearest');
COIs = {'oCL','rCL'};
for n = 1:5
    for nc =1:numel(COIs)
        COI = COIs{nc};
        if isempty(params.(COI).(f.ids{n}))
            continue
        end
        movdat = squeeze(f.(f.ids{n}).pxx_mov(:,params.(COI).(f.ids{n}),:));
        movdat(:,all(isnan(movdat)))=[];
        movdat = 10*log10(movdat);
        
        immdat = squeeze(f.(f.ids{n}).pxx_imm(:,params.(COI).(f.ids{n}),:));
        immdat(:,all(isnan(immdat)))=[];
        immdat = 10*log10(immdat);
        
        [~,f.(f.ids{n}).(COI).maxpi] = maxk(movdat(thetarangei(1):thetarangei(2),:),2);
        f.(f.ids{n}).(COI).maxpi = f.(f.ids{n}).(COI).maxpi+thetarangei(1)-1;
        f.(f.ids{n}).(COI).maxf  = mean(fxx(f.(f.ids{n}).(COI).maxpi));
        f.(f.ids{n}).(COI).freq_range1 = [f.(f.ids{n}).(COI).maxf+fshift(1); f.(f.ids{n}).(COI).maxf+fshift(2)]';
        f.(f.ids{n}).(COI).freq_range2 = [f.(f.ids{n}).(COI).maxf*2+fshift(1); f.(f.ids{n}).(COI).maxf*2+fshift(2)]';
        
        [~,f.(f.ids{n}).(COI).maxpi_imm] = maxk(immdat(thetarangei(1):thetarangei(2),:),2);
        f.(f.ids{n}).(COI).maxpi_imm = f.(f.ids{n}).(COI).maxpi_imm+thetarangei(1)-1;
        f.(f.ids{n}).(COI).maxf_imm  = mean(fxx(f.(f.ids{n}).(COI).maxpi_imm));
        f.(f.ids{n}).(COI).freq_range3 = [f.(f.ids{n}).(COI).maxf_imm+fshift(1); f.(f.ids{n}).(COI).maxf_imm+fshift(2)]';
        f.(f.ids{n}).(COI).freq_range4 = [f.(f.ids{n}).(COI).maxf_imm*2+fshift(1); f.(f.ids{n}).(COI).maxf_imm*2+fshift(2)]';
        
        for nn = 1:size(movdat,2)
            [~, f.(f.ids{n}).(COI).peakP1(nn)] = estimate_psd_peak_power(movdat(:,nn),fxx,f.(f.ids{n}).(COI).freq_range1(nn,:));
            [~, f.(f.ids{n}).(COI).peakP2(nn)] = estimate_psd_peak_power(movdat(:,nn),fxx,f.(f.ids{n}).(COI).freq_range2(nn,:));
            [~, f.(f.ids{n}).(COI).peakP1_imm(nn)] = estimate_psd_peak_power(immdat(:,nn),fxx,f.(f.ids{n}).(COI).freq_range3(nn,:));
            [~, f.(f.ids{n}).(COI).peakP2_imm(nn)] = estimate_psd_peak_power(immdat(:,nn),fxx,f.(f.ids{n}).(COI).freq_range4(nn,:));
        end
    end
end

% plot examples
nsession =1;
movchan = 10*log10(f.KIWL.pxx_mov(:,params.rCL.KIWL,nsession));
[fidx] = interp1(fxx,1:length(fxx),f.(f.ids{n}).(COI).freq_range1(nsession,:),'nearest');
peaks  = movchan(fidx(1):fidx(2));
base = linspace(peaks(1),peaks(end),size(peaks,1));

[fidx2] = interp1(fxx,1:length(fxx),f.(f.ids{n}).(COI).freq_range2(nsession,:),'nearest');
peaks2  = movchan(fidx2(1):fidx2(2));
base2 = linspace(peaks2(1),peaks2(end),size(peaks2,1));

plot(axn(16),fxx,movchan,'color',params.col.F)
plot(axn(16),fxx(fidx(1):fidx(2)),base,'k')
shade_between_lines(axn(16),fxx(fidx(1):fidx(2)),[peaks';base]',params.col.F,0.3)
plot(axn(16),fxx(fidx2(1):fidx2(2)),base2,'k')
shade_between_lines(axn(16),fxx(fidx2(1):fidx2(2)),[peaks2';base2]',params.col.F,0.3)

immchan = 10*log10(f.KIWL.pxx_imm(:,params.rCL.KIWL,nsession));
[fidx] = interp1(fxx,1:length(fxx),f.(f.ids{n}).(COI).freq_range3(nsession,:),'nearest');
peaks  = immchan(fidx(1):fidx(2));
base = linspace(peaks(1),peaks(end),size(peaks,1));

[fidx2] = interp1(fxx,1:length(fxx),f.(f.ids{n}).(COI).freq_range4(nsession,:),'nearest');
peaks2  = immchan(fidx2(1):fidx2(2));
base2 = linspace(peaks2(1),peaks2(end),size(peaks2,1));

plot(axn(17),fxx,immchan,'color',params.col.imm)
plot(axn(17),fxx(fidx(1):fidx(2)),base,'k')
shade_between_lines(axn(17),fxx(fidx(1):fidx(2)),[peaks';base]',params.col.imm,0.3)
plot(axn(17),fxx(fidx2(1):fidx2(2)),base2,'k')
shade_between_lines(axn(17),fxx(fidx2(1):fidx2(2)),[peaks2';base2]',params.col.imm,0.3)

set(axn(16:17),'xlim',[0 20])
set(axn(16),'ylim',[-37 -20],'XTickLabel','')
xlabel(axn(17),'Freq. (Hz)')
ylabel(axn(16:17),'Power (dB/Hz)')

%% plot scatter
mksz = 20;
for n = 1:5
    for nc = 1
        COI = COIs{nc};
         if isempty(params.(COI).(f.ids{n}))
            continue
         end

        scatter(axn(11),f.(f.ids{n}).(COI).peakP1,f.(f.ids{n}).(COI).peakP2,mksz,'filled','markerfacecolor',params.col.(f.ids{n}),'marker',params.mkr.(f.ids{n}),'MarkerEdgeColor',params.col.(f.ids{n}))
        scatter(axn(11),f.(f.ids{n}).(COI).peakP1_imm,f.(f.ids{n}).(COI).peakP2_imm,mksz,'filled','markerfacecolor',params.col.imm,'marker',params.mkr.(f.ids{n}),'MarkerEdgeColor',params.col.imm)
    end
end
for n = 1:5
    for nc = 2
        COI = COIs{nc};
         if isempty(params.(COI).(f.ids{n}))
            continue
         end

        scatter(axn(9),f.(f.ids{n}).(COI).peakP1,f.(f.ids{n}).(COI).peakP2,mksz,'filled','markerfacecolor',params.col.(f.ids{n}),'marker',params.mkr.(f.ids{n}),'MarkerEdgeColor',params.col.(f.ids{n}))
        scatter(axn(9),f.(f.ids{n}).(COI).peakP1_imm,f.(f.ids{n}).(COI).peakP2_imm,mksz,'filled','markerfacecolor',params.col.imm,'marker',params.mkr.(f.ids{n}),'MarkerEdgeColor',params.col.imm)
    end
end
set(axn(11),'xlim',[-5 50],'ylim',[-7 24],'ytick',[0 10 20])
set(axn(9),'xlim',[5 50],'ylim',[-7 24],'ytick',[0 10 20])
xlabel(axn([9,11]),'Peak1 power (dB)')
ylabel(axn([9,11]),'Peak2 power (dB)')

%% plot histogram
movratio = cell(2,8);
immratio = cell(2,8);
m =1;
for n = 1:5
    for nc = 1:2
        COI = COIs{nc};
        if isempty(params.(COI).(f.ids{n}))
            continue
         end
        movratio{nc,m} = f.(f.ids{n}).(COI).peakP2./f.(f.ids{n}).(COI).peakP1;
        immratio{nc,m} = f.(f.ids{n}).(COI).peakP2_imm./f.(f.ids{n}).(COI).peakP1_imm;
        m = m+1;
    end
end
movratio1 = cell2mat(movratio(1,:));
immratio1 = cell2mat(immratio(1,:));
movratio2 = cell2mat(movratio(2,:));
immratio2 = cell2mat(immratio(2,:));


histogram(axn(18),immratio1,'binwidth',0.1,'FaceColor',params.col.imm,'EdgeColor',params.col.imm)
histogram(axn(18),movratio1,'binwidth',0.1,'FaceColor',params.col.F,'EdgeColor',params.col.F)
histogram(axn(19),immratio2,'binwidth',0.1,'FaceColor',params.col.imm,'EdgeColor',params.col.imm)
histogram(axn(19),movratio2,'binwidth',0.1,'FaceColor',params.col.F,'EdgeColor',params.col.F)

set(axn(18),'xlim',[-0.35 0.75])
set(axn(19),'xlim',[-0.25 0.75])
xlabel(axn([18,19]),'Peak power ratio')
ylabel(axn([18,19]),'N sessions')

title(axn,'')

font_size_and_color(gcf,8)

%print(gcf,'-dpdf','-r600','-painters','supfig_psds_mov_vs_imm.pdf')

