clear
params = get_parameters;
ref = load_reference_table('F','incl','neu','level','L5','modality','A|V');

IDs = {'KIW','BEA','BEA'};
recsides = {'L','L','R'};
COI = 'rad';
ax2plot = [11 12 13; 14 15 16; 17 18 19];

longcol  = [204,121,167]/255;
shortcol = [0 158 115]/255; 

axn = supfigure_reward_makeFigure;


for nID = 1:3
    
    ID = IDs{nID};
    recside = recsides{nID};
    
    idref = ref(and(contains(ref.ID,ID),contains(ref.RecSide,recside)),:);
    
    rwdtbl = load_results_tables(idref,'xcorr_across_reward_slidingwin',params.rCL.(idref.IDside{1}));
    rwdtblconc = vertcat(rwdtbl{:});
    maxt = max(rwdtblconc.WinStartT);
    tline1 = -1:0.1:maxt;
    
    
    for n = 1:size(idref,1)
        stbl = rwdtbl{n};
        if isempty(stbl)
            continue
        end
        stbl(stbl.Correct==0,:)=[];
        trials = load_trials_table(idref(n,:));
        
        neasy = trials.TrialNum(trials.Difficulty==0);
        nhard = trials.TrialNum(trials.Difficulty==1);
        
        easytbl{n,1} = stbl(ismember(stbl.Trial,neasy),:);
        hardtbl{n,1} = stbl(ismember(stbl.Trial,nhard),:);
    end
    
    
    
    easyallpeakrwd  = NaN(size(rwdtblconc,1),length(tline1));
    easyallfreqrwd  = NaN(size(rwdtblconc,1),length(tline1));
    easyallspeedrwd = NaN(size(rwdtblconc,1),length(tline1));
    
    nrow=1;
    for n = 1:size(easytbl,1)
        sTbl = easytbl{n};
        if isempty(sTbl)
            continue
        end
        sTbl(sTbl.Correct==0,:)=[];
        for nt = 1:max(sTbl.Trial)
            
            trialdata = sTbl(sTbl.Trial==nt,:);
            
            easyallpeakrwd(nrow,1:size(trialdata,1))  = trialdata.peakrangenorm;
            easyallfreqrwd(nrow,1:size(trialdata,1))  = trialdata.freq;
            easyallspeedrwd(nrow,1:size(trialdata,1)) = trialdata.Speed;
            nrow = nrow+1;
        end
        
    end
    
    
    hardallpeakrwd  = NaN(size(rwdtblconc,1),length(tline1));
    hardallfreqrwd  = NaN(size(rwdtblconc,1),length(tline1));
    hardallspeedrwd = NaN(size(rwdtblconc,1),length(tline1));
    
    nrow=1;
    for n = 1:size(hardtbl,1)
        sTbl = hardtbl{n};
        if isempty(sTbl)
            continue
        end
        sTbl(sTbl.Correct==0,:)=[];
        for nt = 1:max(sTbl.Trial)
            
            trialdata = sTbl(sTbl.Trial==nt,:);
            
            hardallpeakrwd(nrow,1:size(trialdata,1))  = trialdata.peakrangenorm;
            hardallfreqrwd(nrow,1:size(trialdata,1))  = trialdata.freq;
            hardallspeedrwd(nrow,1:size(trialdata,1)) = trialdata.Speed;
            nrow = nrow+1;
        end
        
    end
    
    meanpeakrwd = nanmean(easyallpeakrwd);
    stdpeakrwd  = nanstd(easyallpeakrwd);
    meanfreqrwd = nanmean(easyallfreqrwd);
    stdfreqrwd  = nanstd(easyallfreqrwd);
    meanspeedrwd = nanmean(easyallspeedrwd);
    stdspeedrwd  = nanstd(easyallspeedrwd);
    
    medpeakrwd = nanmedian(easyallpeakrwd);
    p25peakrwd  = prctile(easyallpeakrwd,25);
    p75peakrwd  = prctile(easyallpeakrwd,75);
    medfreqrwd = nanmedian(easyallfreqrwd);
    p25freqrwd  = prctile(easyallfreqrwd,25);
    p75freqrwd  = prctile(easyallfreqrwd,75);
    medspeedrwd = nanmedian(easyallspeedrwd);
    p25speedrwd  = prctile(easyallspeedrwd,25);
    p75speedrwd  = prctile(easyallspeedrwd,75);
    
    
    meanpeakrwd2 = nanmean(hardallpeakrwd);
    stdpeakrwd2  = nanstd(hardallpeakrwd);
    meanfreqrwd2 = nanmean(hardallfreqrwd);
    stdfreqrwd2  = nanstd(hardallfreqrwd);
    meanspeedrwd2 = nanmean(hardallspeedrwd);
    stdspeedrwd2  = nanstd(hardallspeedrwd);
    
    medpeakrwd2 = nanmedian(hardallpeakrwd);
    p25peakrwd2  = prctile(hardallpeakrwd,25);
    p75peakrwd2  = prctile(hardallpeakrwd,75);
    medfreqrwd2 = nanmedian(hardallfreqrwd);
    p25freqrwd2  = prctile(hardallfreqrwd,25);
    p75freqrwd2  = prctile(hardallfreqrwd,75);
    medspeedrwd2 = nanmedian(hardallspeedrwd);
    p25speedrwd2  = prctile(hardallspeedrwd,25);
    p75speedrwd2  = prctile(hardallspeedrwd,75);
    
    
    
    
    axes(axn(ax2plot(nID,1)))
    shade_between_lines(gca,tline1,[p25peakrwd;p75peakrwd]',longcol,0.3)
    plot(tline1,medpeakrwd,'color',longcol)
    shade_between_lines(gca,tline1,[p25peakrwd2;p75peakrwd2]',shortcol,0.3)
    plot(tline1,medpeakrwd2,'color',shortcol)
    ylim([0.1 0.8])    
    plotXYlines(gca,0,'color','k','linewidth',0.5,'linestyle',':')
    title([idref.IDside{1} ' ' COI ' chan'],'Position',[0.5 1])
    set(gca,'ygrid','on','XTickLabel','')
    
    axes(axn(ax2plot(nID,2)))
    shade_between_lines(gca,tline1,[p25freqrwd;p75freqrwd]',longcol,0.3)
    plot(tline1,medfreqrwd,'color',longcol)
    shade_between_lines(gca,tline1,[p25freqrwd2;p75freqrwd2]',shortcol,0.3)
    plot(tline1,medfreqrwd2,'color',shortcol)
    ylim([3.5 6.5])
    plotXYlines(gca,0,'color','k','linewidth',0.5,'linestyle',':')
    set(gca,'ygrid','on','XTickLabel','')
    title(gca,'')
    
    axes(axn(ax2plot(nID,3)))
    shade_between_lines(gca,tline1,[p25speedrwd;p75speedrwd]',longcol,0.3)
    plot(tline1,medspeedrwd,'color',longcol)
    shade_between_lines(gca,tline1,[p25speedrwd2;p75speedrwd2]',shortcol,0.3)
    plot(tline1,medspeedrwd2,'color',shortcol)
    plotXYlines(gca,0,'color','k','linewidth',0.5,'linestyle',':')
    ylim([0 55])
    set(gca,'ygrid','on')
    title(gca,'')

    xlabel('Time from reward start (s)')
    link_axes_in_figure(gcf,'x')
    
    set(gca,'xlim',[-1.25 10])
end

legend({'Long','Short'})
ylabel(axn(11),{'Autocorr.'; 'peak range'});
ylabel(axn(12),{'Frequency'; '(Hz)'});
ylabel(axn(13),{'Speed'; '(cms^{-1})'},'interpreter','tex');

set(axn(14:19),'yticklabel','')

font_size_and_color(gcf,8)
%print(gcf,'-dpdf','-r600','-painters','supfigure_reward_long_short.pdf')

