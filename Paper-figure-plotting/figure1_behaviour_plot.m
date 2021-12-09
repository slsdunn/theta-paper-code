function figure1_behaviour_plot(species)

params = get_parameters;
ref = load_reference_table(species,'level','L5|6','modality','A|V','incl','neu');

speedbins = 0:5:300;

IDs = unique(ref.ID,'stable');
for n = 1:numel(IDs)
    
    IDref = ref(contains(ref.ID,IDs{n}),:);
            
    % get speed info
    out.(IDs{n}) = measure_speed_params_across_sessions(IDref,speedbins);
   
    out.(IDs{n}).speedhistmean = mean(out.(IDs{n}).speedhist);
    out.(IDs{n}).speedhiststd  = std(out.(IDs{n}).speedhist);
    
    out.(IDs{n}).meanmovsesh = mean(out.(IDs{n}).movmean);
    out.(IDs{n}).stdmovsesh = std(out.(IDs{n}).movmean);
    
    out.(IDs{n}).meanimmpc = mean(out.(IDs{n}).immpc);
    out.(IDs{n}).stdimmpc  = std(out.(IDs{n}).immpc);
    
    concspeed = cell2mat(out.(IDs{n}).concspeedcell);
    
    out.(IDs{n}).concmovmean = mean(concspeed(concspeed>10));
    out.(IDs{n}).concmovstd  = std(concspeed(concspeed>10));
    out.(IDs{n}).concspeedhist = histcounts(concspeed,speedbins,'Normalization','cdf');  
    out.(IDs{n}).maxs  = max(concspeed);
    
    % get trial info
    out.(IDs{n}).trialinfo = get_trial_info(IDref);
   
    out.(IDs{n}).trialinfo.holdtot_pc = 100*out.(IDs{n}).trialinfo.holdtot_s./out.(IDs{n}).t_tot;
    out.(IDs{n}).trialinfo.meanholdpc = mean(out.(IDs{n}).trialinfo.holdtot_pc);
    out.(IDs{n}).trialinfo.stdholdpc = std(out.(IDs{n}).trialinfo.holdtot_pc);
    
%     
%     r.(IDs{n}).Apc = IDref.A_Perf(contains(IDref.Modality,'A'),3);
%     r.(IDs{n}).Vpc = IDref.V_Perf(contains(IDref.Modality,'V'),3);
%     
%     r.(IDs{n}).meanVpc = mean(r.(IDs{n}).Vpc);
%     r.(IDs{n}).meanApc = mean(r.(IDs{n}).Apc);
%     
    
end


switch species
    case 'F'
        chancelevel = 0.25;
    case 'R'
        chancelevel = 0.5;
end


plotorder = params.(species).plotorder_animal_linprobe;
axn = figure1_behaviour_makeFigure;
title(axn,'')

meancol = [0.2 0.2 0.2];
sdcol  = [0.2 0.2 0.2];

for n = 1:numel(plotorder)
    
    swarmchart(axn(1),ones(length(out.(plotorder{n}).trialinfo.propcorrect_A),1)*n,out.(plotorder{n}).trialinfo.propcorrect_A,30,params.col.(plotorder{n}),'filled','marker',params.mkr.(plotorder{n}),'XJitterWidth',0.5);
    swarmchart(axn(2),ones(length(out.(plotorder{n}).trialinfo.propcorrect_V),1)*n,out.(plotorder{n}).trialinfo.propcorrect_V,30,params.col.(plotorder{n}),'filled','marker',params.mkr.(plotorder{n}),'XJitterWidth',0.5);
   
    plot(axn(1),[n n],[out.(plotorder{n}).trialinfo.mean_propcorrA-out.(plotorder{n}).trialinfo.sd_propcorrA , out.(plotorder{n}).trialinfo.mean_propcorrA+out.(plotorder{n}).trialinfo.sd_propcorrA],'color',sdcol,'LineWidth',0.75)
    plot(axn(2),[n n],[out.(plotorder{n}).trialinfo.mean_propcorrV-out.(plotorder{n}).trialinfo.sd_propcorrV , out.(plotorder{n}).trialinfo.mean_propcorrV+out.(plotorder{n}).trialinfo.sd_propcorrV],'color',sdcol,'LineWidth',0.75)
   
    plot(axn(1),[n-0.1 n+0.1],[out.(plotorder{n}).trialinfo.mean_propcorrA-out.(plotorder{n}).trialinfo.sd_propcorrA , out.(plotorder{n}).trialinfo.mean_propcorrA-out.(plotorder{n}).trialinfo.sd_propcorrA],'color',sdcol,'LineWidth',0.75)
    plot(axn(1),[n-0.1 n+0.1],[out.(plotorder{n}).trialinfo.mean_propcorrA+out.(plotorder{n}).trialinfo.sd_propcorrA , out.(plotorder{n}).trialinfo.mean_propcorrA+out.(plotorder{n}).trialinfo.sd_propcorrA],'color',sdcol,'LineWidth',0.75)
    plot(axn(2),[n-0.1 n+0.1],[out.(plotorder{n}).trialinfo.mean_propcorrV-out.(plotorder{n}).trialinfo.sd_propcorrV , out.(plotorder{n}).trialinfo.mean_propcorrV-out.(plotorder{n}).trialinfo.sd_propcorrV],'color',sdcol,'LineWidth',0.75)
    plot(axn(2),[n-0.1 n+0.1],[out.(plotorder{n}).trialinfo.mean_propcorrV+out.(plotorder{n}).trialinfo.sd_propcorrV , out.(plotorder{n}).trialinfo.mean_propcorrV+out.(plotorder{n}).trialinfo.sd_propcorrV],'color',sdcol,'LineWidth',0.75)

    plot(axn(1),[n-0.3 n+0.3],[out.(plotorder{n}).trialinfo.mean_propcorrA out.(plotorder{n}).trialinfo.mean_propcorrA],'color',meancol,'LineWidth',1.5)
    plot(axn(2),[n-0.3 n+0.3],[out.(plotorder{n}).trialinfo.mean_propcorrV out.(plotorder{n}).trialinfo.mean_propcorrV],'color',meancol,'LineWidth',1.5)

   
    plot(axn(3),speedbins(1:end-1),out.(plotorder{n}).speedhistmean,'LineWidth',1.5,'color',params.col.(plotorder{n}))
    shade_between_lines(axn(3),speedbins(1:end-1)',[(out.(plotorder{n}).speedhistmean-out.(plotorder{n}).speedhiststd)', (out.(plotorder{n}).speedhistmean+out.(plotorder{n}).speedhiststd)'],params.col.(plotorder{n}),0.35)
    
    swarmchart(axn(4),ones(length(out.(plotorder{n}).movmean),1)*n,out.(plotorder{n}).movmean,30,params.col.(plotorder{n}),'filled','marker',params.mkr.(plotorder{n}),'XJitterWidth',0.5);
    plot(axn(4),[n-0.1 n+0.1],[out.(plotorder{n}).meanmovsesh-out.(plotorder{n}).stdmovsesh , out.(plotorder{n}).meanmovsesh-out.(plotorder{n}).stdmovsesh],'color',sdcol,'LineWidth',0.75)
    plot(axn(4),[n-0.1 n+0.1],[out.(plotorder{n}).meanmovsesh+out.(plotorder{n}).stdmovsesh , out.(plotorder{n}).meanmovsesh+out.(plotorder{n}).stdmovsesh],'color',sdcol,'LineWidth',0.75)
    plot(axn(4),[n n],[out.(plotorder{n}).meanmovsesh-out.(plotorder{n}).stdmovsesh, out.(plotorder{n}).meanmovsesh+out.(plotorder{n}).stdmovsesh],'color',sdcol,'LineWidth',0.75)
    plot(axn(4),[n-0.3 n+0.3],[out.(plotorder{n}).meanmovsesh out.(plotorder{n}).meanmovsesh],'color',meancol,'LineWidth',1.5)
   
end

na = numel(params.(species).plotorder_animal_linprobe_lbl);

plotXYlines(axn(1),chancelevel,'lineExtent',[0 na+1],'orientation','horizontal','color',[0.65 0.65 0.65],'linewidth',1)
plotXYlines(axn(2),chancelevel,'lineExtent',[0 na+1],'orientation','horizontal','color',[0.65 0.65 0.65],'linewidth',1)

set(axn(1),'xlim',[0.25 na+1-0.25],'ylim',[0 1],'xtick',1:na,'xticklabel',params.(species).plotorder_animal_linprobe_lbl)
set(axn(2),'xlim',[0.25 na+1-0.25],'ylim',[0 1],'xtick',1:na,'xticklabel',params.(species).plotorder_animal_linprobe_lbl,'YColor','none')
set(axn(3),'xlim',[0 85])
% legend(axn(3),params.(species).plotorder_animal_linprobe_lbl)
set(axn(4),'xlim',[0.25 na+1-0.25],'ylim',[0 45],'xtick',1:na,'xticklabel',params.(species).plotorder_animal_linprobe_lbl)

ylabel(axn(1),'Prop. correct','fontname','Arial','fontsize',8)
xlabel(axn(1),'AUD','fontname','Arial','fontsize',8,'FontWeight','bold')
xlabel(axn(2),'VIS','fontname','Arial','fontsize',8,'FontWeight','bold')
ylabel(axn(3),'Prop. of session','fontname','Arial','fontsize',8)
xlabel(axn(3),'Speed (cm^{-1})','Interpreter','tex','fontname','Arial','fontsize',8)
ylabel(axn(4),'Average speed (cm^{-1})','Interpreter','tex','fontname','Arial','fontsize',8)


keyboard
%print(gcf,'-dpdf','-r600','-painters','figure1_rat_behaviour.pdf')

switch species
    case 'F'
        out.lin_probe_speeds     = [out.KIW.meanmovsesh, out.EMU.meanmovsesh, out.BEA.meanmovsesh];
        out.lin_probe_mean_speed = mean([out.KIW.meanmovsesh, out.EMU.meanmovsesh, out.BEA.meanmovsesh]);
        out.lin_probe_std_speed  = std([out.KIW.meanmovsesh, out.EMU.meanmovsesh, out.BEA.meanmovsesh]);
        
        out.lin_probe_Acorrect      = [out.KIW.trialinfo.mean_propcorrA, out.EMU.trialinfo.mean_propcorrA, out.BEA.trialinfo.mean_propcorrA];
        out.lin_probe_mean_Acorrect = mean([out.KIW.trialinfo.mean_propcorrA, out.EMU.trialinfo.mean_propcorrA, out.BEA.trialinfo.mean_propcorrA]);
        out.lin_probe_std_Acorrect  = std([out.KIW.trialinfo.mean_propcorrA, out.EMU.trialinfo.mean_propcorrA, out.BEA.trialinfo.mean_propcorrA]);
        
        out.lin_probe_Vcorrect      = [out.KIW.trialinfo.mean_propcorrV, out.EMU.trialinfo.mean_propcorrV, out.BEA.trialinfo.mean_propcorrV];
        out.lin_probe_mean_Vcorrect = mean([out.KIW.trialinfo.mean_propcorrV, out.EMU.trialinfo.mean_propcorrV, out.BEA.trialinfo.mean_propcorrV]);
        out.lin_probe_std_Vcorrect  = std([out.KIW.trialinfo.mean_propcorrV, out.EMU.trialinfo.mean_propcorrV, out.BEA.trialinfo.mean_propcorrV]);
    case 'R'
        out.lin_probe_speeds     = [out.DBLU.meanmovsesh, out.ERED.meanmovsesh, out.DRED.meanmovsesh];
        out.lin_probe_mean_speed = nanmean([out.DBLU.meanmovsesh, out.ERED.meanmovsesh, out.DRED.meanmovsesh]);
        out.lin_probe_std_speed  = nanstd([out.DBLU.meanmovsesh, out.ERED.meanmovsesh, out.DRED.meanmovsesh]);
        
        out.lin_probe_Acorrect      = [out.DBLU.trialinfo.mean_propcorrA, out.ERED.trialinfo.mean_propcorrA, out.DRED.trialinfo.mean_propcorrA];
        out.lin_probe_mean_Acorrect = nanmean([out.DBLU.trialinfo.mean_propcorrA, out.ERED.trialinfo.mean_propcorrA, out.DRED.trialinfo.mean_propcorrA]);
        out.lin_probe_std_Acorrect  = nanstd([out.DBLU.trialinfo.mean_propcorrA, out.ERED.trialinfo.mean_propcorrA, out.DRED.trialinfo.mean_propcorrA]);
        
        out.lin_probe_Vcorrect      = [out.DBLU.trialinfo.mean_propcorrV, out.ERED.trialinfo.mean_propcorrV, out.DRED.trialinfo.mean_propcorrV];
        out.lin_probe_mean_Vcorrect = nanmean([out.DBLU.trialinfo.mean_propcorrV, out.ERED.trialinfo.mean_propcorrV, out.DRED.trialinfo.mean_propcorrV]);
        out.lin_probe_std_Vcorrect  = nanstd([out.DBLU.trialinfo.mean_propcorrV, out.ERED.trialinfo.mean_propcorrV, out.DRED.trialinfo.mean_propcorrV]);
end
        
 

save(fullfile(params.(species).processedDataPath,'figure1_behaviour_data.mat'),'-struct','out')

end

function out = measure_speed_params_across_sessions(IDref,speedbins)
 for n = 1:size(IDref,1)
        [speed, t] = load_tracking_speed(IDref(n,:));
        speed(isnan(speed)) = [];   
        
        out.t_tot(n)   = t(end);
        out.movmean(n) = mean(speed(speed>10));
        out.movstd(n)  = mean(speed(speed>10));
        out.immpc(n)   = percent_high(speed<5);
        out.imm_t(n)   = out.t_tot(n)*(out.immpc(n)/100);
        
        out.speedhist(n,:) = histcounts(speed,speedbins,'Normalization','cdf');
        
        out.concspeedcell{n,1} = speed;       
              
 end
end

function out = get_trial_info(IDref)
   for n = 1:size(IDref,1)
        trials = load_trials_table(IDref(n,:),'clean');
                
        out.holdtot_s(n) = nansum(trials.HoldTime)/1000;
        out.runtot_s(n)  = nansum(trials.ReactionTime);
        out.prop_correct(n) = sum(trials.Correct)/size(trials,1);
        out.hold_times{n,1} = trials.HoldTime;
   end
   
   out.med_propcorr = nanmedian(out.prop_correct);
   out.mean_propcorr = nanmean(out.prop_correct);
   out.holdtimes = cell2mat(out.hold_times);
   out.totntrials = size(out.holdtimes,1);
   
   out.propcorrect_A = out.prop_correct(contains(IDref.Modality,'A'));
   out.propcorrect_V = out.prop_correct(contains(IDref.Modality,'V'));
   out.med_propcorrA = nanmedian(out.propcorrect_A);
   out.med_propcorrV = nanmedian(out.propcorrect_V);
   out.mean_propcorrA = nanmean(out.propcorrect_A);
   out.mean_propcorrV = nanmean(out.propcorrect_V);
   
   out.sd_propcorrA = nanstd(out.propcorrect_A);
   out.sd_propcorrV = nanstd(out.propcorrect_V);
   
   out.holdcount(1) = sum(out.holdtimes == 2500);
   out.holdcount(2) = sum(out.holdtimes == 2750);
   out.holdcount(3) = sum(out.holdtimes == 3000);
   out.holdcount(4) = sum(out.holdtimes == 3250);
   out.holdcount(5) = sum(out.holdtimes == 3500);
   
   out.holdpc(1) = sum(out.holdtimes == 2500)/out.totntrials*100;
   out.holdpc(2) = sum(out.holdtimes == 2750)/out.totntrials*100;
   out.holdpc(3) = sum(out.holdtimes == 3000)/out.totntrials*100;
   out.holdpc(4) = sum(out.holdtimes == 3250)/out.totntrials*100;
   out.holdpc(5) = sum(out.holdtimes == 3500)/out.totntrials*100;
   
end