function supfigure_trial_epoch_psds

axn = supfigure_trial_epoch_psds_makeFigure;


[r.DBLU.pxxhold, r.DBLU.pxxrun, r.DBLU.pxxrwd,r.DBLU.fxx] = trial_epoch_psds(axn([1,2]),'R','DBLU','R');
[r.ERED.pxxhold, r.ERED.pxxrun, r.ERED.pxxrwd,r.ERED.fxx] =trial_epoch_psds(axn([3,4]),'R','ERED','R');
[r.DRED.pxxhold, r.DRED.pxxrun, r.DRED.pxxrwd,r.DRED.fxx] =trial_epoch_psds(axn(5),'R','DRED','R');
[f.KIWL.pxxhold, f.KIWL.pxxrun, f.KIWL.pxxrwd,f.KIWL.fxx] =trial_epoch_psds(axn([6,7]),'F','KIW','L');
[f.KIWR.pxxhold, f.KIWR.pxxrun, f.KIWR.pxxrwd,f.KIWR.fxx] =trial_epoch_psds(axn(8),'F','KIW','R');
[f.EMUL.pxxhold, f.EMUL.pxxrun, f.EMUL.pxxrwd,f.EMUL.fxx] =trial_epoch_psds(axn(9),'F','EMU','L');
[f.BEAL.pxxhold, f.BEAL.pxxrun, f.BEAL.pxxrwd,f.BEAL.fxx] =trial_epoch_psds(axn([10,11]),'F','BEA','L');
[f.BEAR.pxxhold, f.BEAR.pxxrun, f.BEAR.pxxrwd,f.BEAR.fxx] =trial_epoch_psds(axn([12,13]),'F','BEA','R');

set(axn(1:13),'xlim',[0 25])

set(axn(1),'ylim',[-0.01 0.8])
set(axn(2),'ylim',[-0.01 0.35])
set(axn(3),'ylim',[-0.01 0.7])
set(axn(4),'ylim',[-0.01 0.65])
set(axn(5),'ylim',[-0.01 0.5])
set(axn(6),'ylim',[-0.01 0.3])
set(axn(7),'ylim',[-0.01 0.65])
set(axn(8),'ylim',[-0.01 0.6])
set(axn(9),'ylim',[-0.01 0.6])
set(axn(10),'ylim',[-0.01 0.6])
set(axn(11),'ylim',[-0.01 0.5])
set(axn(12),'ylim',[-0.01 0.8])
set(axn(13),'ylim',[-0.01 0.5])

set(axn([1,3,6,10,12]),'xticklabel',[])

xlabel(axn([2,7]),'Frequency (Hz)')
ylabel(axn([2,7]),{'Norm.', 'Power/Freq.(a.u)'})

%% harmonic power ratio
params = get_parameters;
fxx = f.KIWL.fxx;
thetarange  = [4 7];
fshift.run = [-2.75 2];
fshift.hold = [-2.5 2.5];
fshift.rwd = [-2.5 2.5];
thetarangei = interp1(fxx,1:numel(fxx),thetarange,'nearest');
COIs = {'oCL','rCL'};
epochs = {'hold','run','rwd'};
f.ids = params.F.plotorder_recside_linprobe;

for n = 1:5
    for nc =1:numel(COIs)
        COI = COIs{nc};
        if isempty(params.(COI).(f.ids{n}))
            continue
        end
        for ne = 1:numel(epochs)
            
            psddat = f.(f.ids{n}).(['pxx' epochs{ne}])(:,nc);
            psddat = 10*log10(psddat);
            
            if ne ==2
            [~,f.(f.ids{n}).(COI).(epochs{ne}).maxpi] = max(psddat(thetarangei(1):thetarangei(2),:));
            else
            [~,f.(f.ids{n}).(COI).(epochs{ne}).maxpi] = maxk(psddat(thetarangei(1):thetarangei(2),:),2);
            end
            f.(f.ids{n}).(COI).(epochs{ne}).maxpi = f.(f.ids{n}).(COI).(epochs{ne}).maxpi+thetarangei(1)-1;
            f.(f.ids{n}).(COI).(epochs{ne}).maxf  = mean(fxx(f.(f.ids{n}).(COI).(epochs{ne}).maxpi));
            f.(f.ids{n}).(COI).(epochs{ne}).freq_range1 = [f.(f.ids{n}).(COI).(epochs{ne}).maxf+fshift.(epochs{ne})(1); f.(f.ids{n}).(COI).(epochs{ne}).maxf+fshift.(epochs{ne})(2)]';
            f.(f.ids{n}).(COI).(epochs{ne}).freq_range2 = [f.(f.ids{n}).(COI).(epochs{ne}).maxf*2+fshift.(epochs{ne})(1); f.(f.ids{n}).(COI).(epochs{ne}).maxf*2+fshift.(epochs{ne})(2)]';
                       
            [~, f.(f.ids{n}).(COI).(epochs{ne}).peakP1] = estimate_psd_peak_power(psddat,fxx,f.(f.ids{n}).(COI).(epochs{ne}).freq_range1);
            [~, f.(f.ids{n}).(COI).(epochs{ne}).peakP2] = estimate_psd_peak_power(psddat,fxx,f.(f.ids{n}).(COI).(epochs{ne}).freq_range2);             
            
            f.(f.ids{n}).(COI).(epochs{ne}).peakratio = f.(f.ids{n}).(COI).(epochs{ne}).peakP2/f.(f.ids{n}).(COI).(epochs{ne}).peakP1;
        end
    end
end

% plot examples
cols = [params.col.imm;params.col.F;params.col.rwd];
COI = 'rCL';
ids = 'BEAR';
for ne = 1:3
psdeg = 10*log10(f.(ids).(['pxx' epochs{ne}])(:,2));
[fidx] = interp1(fxx,1:length(fxx),f.(ids).(COI).(epochs{ne}).freq_range1,'nearest');
peaks  = psdeg(fidx(1):fidx(2));
base = linspace(peaks(1),peaks(end),size(peaks,1));

[fidx2] = interp1(fxx,1:length(fxx),f.(ids).(COI).(epochs{ne}).freq_range2,'nearest');
peaks2  = psdeg(fidx2(1):fidx2(2));
base2 = linspace(peaks2(1),peaks2(end),size(peaks2,1));

plot(axn(14+ne-1),fxx,psdeg,'color',cols(ne,:))
plot(axn(14+ne-1),fxx(fidx(1):fidx(2)),base,'k')
shade_between_lines(axn(14+ne-1),fxx(fidx(1):fidx(2)),[peaks';base]',cols(ne,:),0.3)
plot(axn(14+ne-1),fxx(fidx2(1):fidx2(2)),base2,'k')
shade_between_lines(axn(14+ne-1),fxx(fidx2(1):fidx2(2)),[peaks2';base2]',cols(ne,:),0.3)

end

set(axn(14:16),'xlim',[0 20])
set(axn(14:15),'XTickLabel','')
xlabel(axn(16),'Freq. (Hz)')
ylabel(axn(15),'Power/Freq. (dB/Hz)')

%% plot scatter
mksz = 20;
for n = 1:5
    for nc = 1
        COI = COIs{nc};
        if isempty(params.(COI).(f.ids{n}))
            continue
        end
        for ne = 1:3
        scatter(axn(17),f.(f.ids{n}).(COI).(epochs{ne}).peakP1,f.(f.ids{n}).(COI).(epochs{ne}).peakP2,mksz,'filled','markerfacecolor',cols(ne,:),'marker',params.mkr.(f.ids{n}),'MarkerEdgeColor',cols(ne,:))
        end
    end
end
for n = 1:5
    for nc = 2
        COI = COIs{nc};
        if isempty(params.(COI).(f.ids{n}))
            continue
        end
        for ne = 1:3
            scatter(axn(19),f.(f.ids{n}).(COI).(epochs{ne}).peakP1,f.(f.ids{n}).(COI).(epochs{ne}).peakP2,mksz,'filled','markerfacecolor',cols(ne,:),'marker',params.mkr.(f.ids{n}),'MarkerEdgeColor',cols(ne,:))
        end
    end
end
set(axn(17),'xlim',[-5 50],'ylim',[-7 32],'ytick',[0 10 20 30])
set(axn(19),'xlim',[5 50],'ylim',[-7 32],'ytick',[0 10 20 30])
xlabel(axn([17,19]),'Peak1 power (dB)')
ylabel(axn([17,19]),'Peak2 power (dB)')

%% plot histogram
epochratios = NaN(3,5,2);
for n = 1:5
    for nc = 1:2
        COI = COIs{nc};
        if isempty(params.(COI).(f.ids{n}))
            continue
        end
        for ne = 1:3
            epochratios(ne,n,nc) = f.(f.ids{n}).(COI).(epochs{ne}).peakP2./f.(f.ids{n}).(COI).(epochs{ne}).peakP1;
        end        
    end
end


histogram(axn(18),epochratios(1,:,1),'binwidth',0.1,'FaceColor',params.col.imm,'EdgeColor',params.col.imm)
histogram(axn(18),epochratios(2,:,1),'binwidth',0.1,'FaceColor',params.col.F,'EdgeColor',params.col.F)
histogram(axn(18),epochratios(3,:,1),'binwidth',0.1,'FaceColor',params.col.rwd,'EdgeColor',params.col.rwd)

histogram(axn(20),epochratios(1,:,2),'binwidth',0.1,'FaceColor',params.col.imm,'EdgeColor',params.col.imm)
histogram(axn(20),epochratios(2,:,2),'binwidth',0.1,'FaceColor',params.col.F,'EdgeColor',params.col.F)
histogram(axn(20),epochratios(3,:,2),'binwidth',0.1,'FaceColor',params.col.rwd,'EdgeColor',params.col.rwd)

set(axn(18),'xlim',[-0.35 0.75])
set(axn(20),'xlim',[-0.1 0.75])
xlabel(axn([18,20]),'Peak power ratio')
ylabel(axn([18,20]),'N sessions')


title(axn,'')

font_size_and_color(gcf,8)


%print(gcf,'-dpdf','-r600','-painters','supfigure_trial_epoch_psds2.pdf')

end


function [pxxhold, pxxrun, pxxrwd,fxx] = trial_epoch_psds(axn,species,ID,recside)
try
    ids     = [ID recside];
    params = get_parameters;
    
    thresh.win_samples = params.xcorr.win_samples;
    thresh.win_seconds = params.xcorr.win_seconds;
    thresh.hold_shift   = params.trial_ext.holdshift;
    thresh.imm_speed   = params.speedThresh.immobile;
    thresh.R_maze_arm_ylim = params.trial_ext.R_rwd_ylim;
    switch species
        case 'F'
            thresh.flt_type = '1_highpass';
        case 'R'
            thresh.flt_type = '2_highpass';
    end
    
    ref = load_reference_table(species,'level','L5|6','incl','neu','modality','A|V','ID',ID,'recside',recside);
    COI   = [params.oCL.(ids),params.rCL.(ids)];
    
    pxx_hold = cell(numel(COI),size(ref,1));
    pxx_run  = cell(numel(COI),size(ref,1));
    pxx_rwd  = cell(numel(COI),size(ref,1));
    
    for n = 1:size(ref,1)
        
        sessionref = ref(n,:);
        
        mdata = load_metadata(sessionref);
        % skip if no map
        if mdata.mapID==0 || mdata.mapID==-999
            continue
        end
        % skip if no trials
        trials     = load_trials_table(sessionref,'clean');
        if isempty(trials)
            continue
        end
        cdata = load_neural_mapped(sessionref,mdata,COI,'cleansignal');
        t_neu = load_neural_timeline(mdata);
        speed = load_tracking_speed(sessionref,mdata,t_neu);
        [~,ypos] = load_tracking_location(sessionref,mdata,t_neu);
        
        flt = cheby2_filtfilthd(cdata,thresh.flt_type,1000);
        zcdata = nanzscore(flt,1);
        
        
        %% looking at 1s windows
        % find reward window starting point(sample number) using trial sensor data and speed trace
        reward_win_start    = find_reward_window(species,trials,speed,ypos,t_neu,thresh.win_samples,thresh.win_seconds,thresh.imm_speed,thresh.R_maze_arm_ylim);
        trials_with_rwd_idx = ~isnan(reward_win_start) & trials.Correct; % only looking at correct trials
        reward_win_start    = reward_win_start(trials_with_rwd_idx);
        
        % extract trial epochs from speed trace (for hold and run extract all trials, for reward extract only reward windows)
        hold_neu    = extract_epochs_from_signal(zcdata,t_neu,trials.HoldEnd-thresh.win_seconds-thresh.hold_shift,thresh.win_seconds);
        
        run_neu       = extract_epochs_from_signal(zcdata,t_neu,trials.RespTime-thresh.win_seconds,thresh.win_seconds);
        
        if ~all(trials_with_rwd_idx)
            rwd_neu = extract_epochs_from_signal(zcdata,t_neu,t_neu(reward_win_start),thresh.win_seconds);
        else
            rwd_neu = NaN(size(run_neu));
        end
        
        for nc = 1:numel(COI)
            
            [pxx_hold{nc,n},~] = nanpwelch(hold_neu(:,:,nc),hanning(1000),0,1000);
            [pxx_run{nc,n},~]  = nanpwelch(run_neu(:,:,nc),hanning(1000),0,1000);
            [pxx_rwd{nc,n},fxx]= nanpwelch(rwd_neu(:,:,nc),hanning(1000),0,1000);
            
        end
        
    end
    
    
    for n = 1:numel(COI)
        shade_between_lines(axn(n),fxx,[nanmean(cell2mat(pxx_hold(n,:)),2)-nanstd(cell2mat(pxx_hold(n,:)),[],2),nanmean(cell2mat(pxx_hold(n,:)),2)+nanstd(cell2mat(pxx_hold(n,:)),[],2)],params.col.hold,0.3)
        shade_between_lines(axn(n),fxx,[nanmean(cell2mat(pxx_run(n,:)),2)-nanstd(cell2mat(pxx_run(n,:)),[],2),nanmean(cell2mat(pxx_run(n,:)),2)+nanstd(cell2mat(pxx_run(n,:)),[],2)],params.col.(species),0.3)
        shade_between_lines(axn(n),fxx,[nanmean(cell2mat(pxx_rwd(n,:)),2)-nanstd(cell2mat(pxx_rwd(n,:)),[],2),nanmean(cell2mat(pxx_rwd(n,:)),2)+nanstd(cell2mat(pxx_rwd(n,:)),[],2)],params.col.rwd,0.3)
        
        pxxhold(:,n) = nanmean(cell2mat(pxx_hold(n,:)),2);
        pxxrun(:,n)  = nanmean(cell2mat(pxx_run(n,:)),2);
        pxxrwd(:,n)  = nanmean(cell2mat(pxx_rwd(n,:)),2);
        
        plot(axn(n),fxx,nanmean(cell2mat(pxx_hold(n,:)),2),'color',params.col.hold)
        plot(axn(n),fxx,nanmean(cell2mat(pxx_run(n,:)),2),'color',params.col.(species))
        plot(axn(n),fxx,nanmean(cell2mat(pxx_rwd(n,:)),2),'color',params.col.rwd)
    end
    
    
catch err
    parseError(err)
    keyboard
end
end