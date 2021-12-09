function supfigure_reward

params = get_parameters;

ref = load_reference_table('F','incl','neu','level','L5|6','modality','A|V','ID','linearprobe');

F.xcfft = load_results_tables(ref,'xcorr_trial_epochs',1:32);


axn = supfigure_reward_makeFigure;



%% hold vs reward vs other immobility
plotord = params.F.plotorder_recside_linprobe;
saveFolder = 'xcorr_other_imm';
chan = 1:32;
for n = 1:numel(plotord)
    
    ids = plotord{n};
    idref = ref(contains(ref.IDside,ids),:);
    
    plotdat.(ids) = load_results_tables(idref,saveFolder,chan);
    
end
for  n = 1:numel(plotord)
    
   ids = plotord{n};
   plotdatid = plotdat.(ids);
   
   medpr = NaN(1,32);
   iqrpr = NaN(32,2);
   
   for nc = 1:32
      chandat = vertcat(plotdatid{:,nc}); 
      peakrng = chandat.peakrangenorm;
      medpr(nc)   = mean(peakrng);
      iqrpr(nc,1) = prctile(peakrng,25);
      iqrpr(nc,2) = prctile(peakrng,75);
   end
    
    add_shaded_areas(axn(n),[0 2],[32-(params.oCL.(ids)-0.3)+1 32-(params.oCL.(ids)+0.3)+1],'k',0.2)
    if ~isempty(params.pCL.(ids))
    add_shaded_areas(axn(n),[0 2],[32-(params.pCL.(ids)-0.3)+1 32-(params.pCL.(ids)+0.3)+1],'k',0.2)   
    add_shaded_areas(axn(n),[0 2],[32-(params.rCL.(ids)-0.3)+1 32-(params.rCL.(ids)+0.3)+1],'k',0.2)
    end
    shade_between_lines(axn(n),iqrpr,flip(1:32),'b',0.3)
    plot(axn(n),medpr,flip(1:32),'color','b','LineWidth',2,'DisplayName','other immobility')
   xcfft = F.xcfft(contains(ref.IDside,ids),:);
   quantify_fft_xcorr_trial_epochs__depth_plot(axn(n),xcfft,params.col.hold,params.col.F,params.col.rwd,0.3)
    delete(findall(axn(n),'color',params.col.F))
    delete(findall(axn(n),'facecolor',params.col.F))
   
   %legend
   title(ids)
end

%% correct vs error trials
load(fullfile(params.F.refPath,'spout_coordinates.mat'),'spoutcoords'); % load table of spout positions for each session

thresh.spoutradius = 8;
plotord = params.F.plotorder_recside_linprobe;
correctcol = params.col.rwd;
incorrectcol = [0.7 0.05 0.05];

for  n = 1:numel(plotord)
    
   ids = plotord{n};
   xcfft = F.xcfft(contains(ref.IDside,ids),:);
   idref = ref(contains(ref.IDside,ids),:);
   corrdata.(ids)   = cell(size(xcfft,1),32);  
   incorrdata.(ids) = cell(size(xcfft,1),32);  
   
   for ns = 1:size(xcfft,1)
       sxcfft = xcfft(ns,:);
       idx = cellfun(@isempty,sxcfft);
       if all(idx)
           continue
       end
       sref = idref(ns,:);
       mdata = load_metadata(sref);
       t_neu = load_neural_timeline(mdata);
       [xpos,ypos] = load_tracking_location(sref,mdata,t_neu);
       trials  = sxcfft{find(~idx,1)};
       scoord  = spoutcoords(contains(spoutcoords.ExtFile,sref.ExtractedFile{1}),:);
       corridx = logical(trials.Correct);
       incorridx = ~trials.Correct;
       for nc = 1:32
           chandat = sxcfft{1,nc};
           corrdatidx   = ~chandat.Rwd_nan_idx & chandat.Rwd_win_idx & corridx;
           incorrdatidx = ~chandat.Rwd_nan_idx & chandat.Rwd_win_idx & incorridx;
           
           corrdat = chandat(corrdatidx,:);
           incorrdat = chandat(incorrdatidx,:);
           
           if ~isempty(corrdat)
               corrxpos = extract_epochs_from_signal(xpos,transpose(1:length(t_neu)),corrdat.Rwd_win_start,1000);
               corrxpos = mean(corrxpos(:,:,1));
               corrypos = extract_epochs_from_signal(ypos,transpose(1:length(t_neu)),corrdat.Rwd_win_start,1000);
               corrypos = mean(corrypos(:,:,1));
           else
               corrxpos =[];
               corrypos =[];
           end
           
            if ~isempty(incorrdat) 
           incorrxpos = extract_epochs_from_signal(xpos,transpose(1:length(t_neu)),incorrdat.Rwd_win_start,1000);
           incorrxpos = mean(incorrxpos(:,:,1));
           incorrypos = extract_epochs_from_signal(ypos,transpose(1:length(t_neu)),incorrdat.Rwd_win_start,1000);
           incorrypos = mean(incorrypos(:,:,1));
           else
               incorrxpos =[];
               incorrypos =[];
           end
           for nsp = [10 11 12 1 2]
               [xspout.(['s' num2str(nsp)]),yspout.(['s' num2str(nsp)])] = plot_circle(scoord.(['Spout' num2str(nsp)])(1),scoord.(['Spout' num2str(nsp)])(2),thresh.spoutradius,0);
               incorrposidx.(['s' num2str(nsp)]) = inpolygon(incorrxpos,incorrypos,xspout.(['s' num2str(nsp)]),yspout.(['s' num2str(nsp)]));          
               corrposidx.(['s' num2str(nsp)]) = inpolygon(corrxpos,corrypos,xspout.(['s' num2str(nsp)]),yspout.(['s' num2str(nsp)]));
           end
           incorrposidx.atspout =  incorrposidx.s10 | incorrposidx.s11 | incorrposidx.s12 | incorrposidx.s1 | incorrposidx.s2 ;
           corrposidx.atspout =  corrposidx.s10 | corrposidx.s11 | corrposidx.s12 | corrposidx.s1 | corrposidx.s2 ;
 
           incorrdat = incorrdat(incorrposidx.atspout,:);   
           
           corrdata.(ids)(ns,nc)  = {corrdat.Rwd_peakrangenorm};  
           incorrdata.(ids)(ns,nc) = {incorrdat.Rwd_peakrangenorm}; 
           
           not_at_spout.(ids).(['C' num2str(nc)])(ns,1) = sum(~corrposidx.atspout);
           not_at_spout.(ids).(['C' num2str(nc)])(ns,2) = sum(~incorrposidx.atspout);
          
       end
       
       
   end

end

for n=1:numel(plotord)
   ids = plotord{n};
    
   med_corr = NaN(1,32);
    med_err = NaN(1,32);
    
    qr_corr = NaN(32,2);
    qr_err = NaN(32,2);
    
   for nc = 1:32 
    
   chancorr =  corrdata.(ids)(:,nc);
   chancorr = cell2mat(chancorr);
   
   chanerr =  incorrdata.(ids)(:,nc);
   chanerr = cell2mat(chanerr);
   
       if isempty(chancorr)
           continue
       end
       if size(chancorr,1)==1
           continue
       end
    
    med_corr(nc) = median(chancorr);
    med_err(nc) = median(chanerr);
    
    qr_corr(nc,1) = prctile(chancorr,25);
    qr_corr(nc,2) = prctile(chancorr,75);
    qr_err(nc,1) = prctile(chanerr,25);
    qr_err(nc,2) = prctile(chanerr,75);
   

   end
   
   add_shaded_areas(axn(n+5),[0 2],[32-(params.oCL.(ids)-0.3)+1 32-(params.oCL.(ids)+0.3)+1],'k',0.2)
    if ~isempty(params.pCL.(ids))
    add_shaded_areas(axn(n+5),[0 2],[32-(params.pCL.(ids)-0.3)+1 32-(params.pCL.(ids)+0.3)+1],'k',0.2)   
    add_shaded_areas(axn(n+5),[0 2],[32-(params.rCL.(ids)-0.3)+1 32-(params.rCL.(ids)+0.3)+1],'k',0.2)
    end
shade_between_lines(axn(n+5),qr_corr,flip(1:32),correctcol,0.3)
plot(axn(n+5),med_corr,flip(1:32),'color',correctcol,'LineWidth',2,'DisplayName','Correct')
shade_between_lines(axn(n+5),qr_err,flip(1:32),incorrectcol,0.3)
plot(axn(n+5),med_err,flip(1:32),'color',incorrectcol,'LineWidth',2,'DisplayName','Error')
set(axn(n+5),'ylim',[0.5 32.5],'ytick',[3, 8, 13, 18, 23, 28],'yticklabel',[30 25 20 15 10 5])
%legend(axn(n+5),'Interpreter','none','Location','best')
   title(ids)
end
set(axn(1:10),'xlim',[0.15 0.75])


%% hold vs reward sliding window
IDS = {'KIWL','BEAL','BEAR'};
titleIDs = {'F1_{L}','F3_{L}','F3_{R}'};
plotax = [11 12 13; 14 15 16; 17 18 19];
for ni = 1:3
idref = ref(contains(ref.IDside,IDS{ni}),:);

rwdtbl = load_results_tables(idref,'xcorr_across_reward_slidingwin',params.rCL.(idref.IDside{1}));
rwdtblconc = vertcat(rwdtbl{:});
maxt = max(rwdtblconc.WinStartT);
tline1 = -1:0.1:maxt;


holdtbl = load_results_tables(idref,'xcorr_across_hold_slidingwin',params.rCL.(idref.IDside{1}));
holdtblconc = vertcat(holdtbl{:});
maxt = max(holdtblconc.WinStartT);
tline2 = -1:0.1:maxt;



allpeakrwd  = NaN(size(rwdtblconc,1),length(tline1));
allfreqrwd  = NaN(size(rwdtblconc,1),length(tline1));
allspeedrwd = NaN(size(rwdtblconc,1),length(tline1));

nrow=1;
for n = 1:size(rwdtbl,1)
     sTbl = rwdtbl{n};   
     if isempty(sTbl)
        continue
     end
      sTbl(sTbl.Correct==0,:)=[];
    for nt = 1:max(sTbl.Trial)
  
             trialdata = sTbl(sTbl.Trial==nt,:);
       
             if max(trialdata.WinStartT) < 10
                 continue
             end
                       
    allpeakrwd(nrow,1:size(trialdata,1))  = trialdata.peakrangenorm;
    allfreqrwd(nrow,1:size(trialdata,1))  = trialdata.freq;
    allspeedrwd(nrow,1:size(trialdata,1)) = trialdata.Speed;    
    nrow = nrow+1;
    end
    
end

allpeakhld  = NaN(size(holdtblconc,1),length(tline2));
allfreqhld  = NaN(size(holdtblconc,1),length(tline2));
allspeedhld = NaN(size(holdtblconc,1),length(tline2));

nrow=1;
for n = 1:size(rwdtbl,1)
     sTbl = holdtbl{n};   
     if isempty(sTbl)
        continue
     end
      sTbl(sTbl.Correct==0,:)=[];
    for nt = 1:max(sTbl.Trial)
  
             trialdata = sTbl(sTbl.Trial==nt,:);
       
    allpeakhld(nrow,1:size(trialdata,1))  = trialdata.peakrangenorm;
    allfreqhld(nrow,1:size(trialdata,1))  = trialdata.freq;
    allspeedhld(nrow,1:size(trialdata,1)) = trialdata.Speed;    
    nrow = nrow+1;
    end
    
end


medpeakrwd = nanmedian(allpeakrwd);
p25peakrwd  = prctile(allpeakrwd,25);
p75peakrwd  = prctile(allpeakrwd,75);
medfreqrwd = nanmedian(allfreqrwd);
p25freqrwd  = prctile(allfreqrwd,25);
p75freqrwd  = prctile(allfreqrwd,75);
medspeedrwd = nanmedian(allspeedrwd);
p25speedrwd  = prctile(allspeedrwd,25);
p75speedrwd  = prctile(allspeedrwd,75);

medpeakhld = nanmedian(allpeakhld);
p25peakhld  = prctile(allpeakhld,25);
p75peakhld  = prctile(allpeakhld,75);
medfreqhld = nanmedian(allfreqhld);
p25freqhld  = prctile(allfreqhld,25);
p75freqhld  = prctile(allfreqhld,75);
medspeedhld = nanmedian(allspeedhld);
p25speedhld  = prctile(allspeedhld,25);
p75speedhld  = prctile(allspeedhld,75);


shade_between_lines(axn(plotax(ni,1)),tline1,[p25peakrwd;p75peakrwd]',params.col.rwd,0.5)
plot(axn(plotax(ni,1)),tline1,medpeakrwd,'color',params.col.rwd)
shade_between_lines(axn(plotax(ni,1)),tline2,[p25peakhld;p75peakhld]',params.col.hold,0.5)
plot(axn(plotax(ni,1)),tline2,medpeakhld,'color',params.col.hold)
plotXYlines(axn(plotax(ni,1)),0,'color','k','linewidth',0.5,'linestyle',':')
ylim(axn(plotax(ni,1)),[0.2 0.8])
title(axn(plotax(ni,1)),titleIDs{ni},'position',[0.5 1],'Interpreter','tex')
set(axn(plotax(ni,1)),'ygrid','on','xlim',[-1.25 10])

shade_between_lines(axn(plotax(ni,2)),tline1,[p25freqrwd;p75freqrwd]',params.col.rwd,0.5)
plot(axn(plotax(ni,2)),tline1,medfreqrwd,'color',params.col.rwd)
shade_between_lines(axn(plotax(ni,2)),tline2,[p25freqhld;p75freqhld]',params.col.hold,0.5)
plot(axn(plotax(ni,2)),tline2,medfreqhld,'color',params.col.hold)
plotXYlines(axn(plotax(ni,2)),0,'color','k','linewidth',0.5,'linestyle',':')
ylim(axn(plotax(ni,2)),[3.5 6.5])
set(axn(plotax(ni,2)),'ygrid','on','xlim',[-1.25 10])

shade_between_lines(axn(plotax(ni,3)),tline1,[p25speedrwd;p75speedrwd]',params.col.rwd,0.5)
plot(axn(plotax(ni,3)),tline1,medspeedrwd,'color',params.col.rwd)
shade_between_lines(axn(plotax(ni,3)),tline2,[p25speedhld;p75speedhld]',params.col.hold,0.5)
plot(axn(plotax(ni,3)),tline2,medspeedhld,'color',params.col.hold)
plotXYlines(axn(plotax(ni,3)),0,'color','k','linewidth',0.5,'linestyle',':')
ylim(axn(plotax(ni,3)),[0 55])
set(axn(plotax(ni,3)),'ygrid','on','xlim',[-1.25 10],'ytick',[0 20 40])


end

xlabel(axn(16),'Time from sensor activation (s)')
title(axn(1:10),'')
title(axn([12,13,15,16,18,19]),'')
set(axn([2,3,4,5,7,8,9,10,14:19]),'yticklabels','')
set(axn([11,12,14,15,17,18]),'xticklabels','')
set(axn([1,6]),'ytick',2:5:32,'yticklabels',flip(0:0.5:3.2))
set(axn(1:10),'ytick',2:5:32,'YminorGrid','on')
ylabel(axn([1,6]),'Depth (mm)')
xlabel(axn(3),'Autocorr. peak range')
xlabel(axn(8),'Autocorr. peak range')
ylabel(axn(11),{'Autocorr.','peak range'})
ylabel(axn(12),{'Frequency';'(Hz)'})
ylabel(axn(13),{'Speed';'(cms^{-1})'},'interpreter','tex')

font_size_and_color(gcf,8)

%print(gcf,'-dpdf','-r600','-painters','supfigure_reward_MATLABoutput.pdf')