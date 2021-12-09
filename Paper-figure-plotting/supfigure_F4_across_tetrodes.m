function supfigure_F4_across_tetrodes

params = get_parameters;

%% power vs speed

load(fullfile(params.F.processedDataPath,'L5L6_speed_vs_signal.mat'),'motion_vs_signal');



ref = load_reference_table('F','ID','ANI','modality','A|V');

motion_vs_signal(~contains(motion_vs_signal.ID,'ANI'),:)=[];
motion_vs_signal(~ismember(motion_vs_signal.ExtFile,ref.ExtractedFile),:)=[];

T1_4 = motion_vs_signal(contains(motion_vs_signal.RecSide,'L'),:);
T5_8 = motion_vs_signal(contains(motion_vs_signal.RecSide,'R'),:);

plotcol = params.col.F;
lw = 1;
ylimits = [0.5 32.5];
pval = 0.05/32;
param2plot = 'b1';
xrange = [9.9 55.1];
msize = 10;
patchw = 0.25;
patchcol = [0.5 0.5 0.5];
patcha = 0.3;

axn = supfigure_F4_across_tetrodes_makeFigure;


%% plot power vs speed
 plotXYlines(axn(1),4.5:4:32,'orientation','horizontal','lineExtent',[-0.5 0.5],'color',[0.4 0.4 0.4],'linestyle','-','linewidth',0.8)
 plotXYlines(axn(1),0,'lineExtent',[0.5 32.5],'color',[0.2 0.2 0.2],'linestyle','-')
   add_shaded_areas(axn(1), [-0.5 0.5],[params.atr.ANIL-patchw params.atr.ANIL+patchw],patchcol,patcha) 
   add_shaded_areas(axn(1), [-0.5 0.5],[params.atr.ANIR+16-patchw params.atr.ANIR+patchw+16],patchcol,patcha)  
all_sessions_during_motion_across_probe__speed_vs_signal(axn(1),T1_4,{'medianSpeed','medianPdB'},param2plot,xrange,pval,plotcol,msize,lw,ylimits,0)
all_sessions_during_motion_across_probe__speed_vs_signal(axn(1),T5_8,{'medianSpeed','medianPdB'},param2plot,xrange,pval,plotcol,msize,lw,ylimits,16)

set(axn(1),'xlim',[-0.1 0.15],'ycolor','none','GridAlpha',0.5)


text(axn(1),-0.15,2.5,'T1')
text(axn(1),-0.15,6.5,'T2')
text(axn(1),-0.15,10.5,'T3')
text(axn(1),-0.15,14.5,'T4')
text(axn(1),-0.15,18.5,'T5')
text(axn(1),-0.15,22.5,'T6')
text(axn(1),-0.15,26.5,'T7')
text(axn(1),-0.15,30.5,'T8')

%% atropine
ref  = load_reference_table('F','incl','neu','modality','ATR');
aref = load_atropine_dose_table(0.6,'greater',1);

atropineref = ref(ismember(ref.ExtractedFile,aref.ExtractedFile),:);

% first non-atropine session following atropine sessions in aref
controlblocks.ANI = {'BlockA-19','BlockA-30','BlockA-33','Block-65','BlockA-72','BlockA-76','BlockA-79'};
controlrefidx2    = and(contains(ref.ID,'ANI'),ismember(ref.Block,controlblocks.ANI));
controlref        = ref(controlrefidx2,:);

% load data
ANIL.atr = load_results_tables(atropineref(contains(atropineref.IDside,'ANIL'),:),'xcorr_vs_speed',1:16,params);
ANIL.con = load_results_tables(controlref(contains(controlref.IDside,'ANIL'),:),'xcorr_vs_speed',1:16,params);
ANIR.atr = load_results_tables(atropineref(contains(atropineref.IDside,'ANIR'),:),'xcorr_vs_speed',1:16,params);
ANIR.con = load_results_tables(controlref(contains(controlref.IDside,'ANIR'),:),'xcorr_vs_speed',1:16,params);

% plot
lshift = 0.125;
plot_mov_vs_imm_atr_vs_con(axn(2),axn(3),ANIL,lshift,0,params)
plot_mov_vs_imm_atr_vs_con(axn(2),axn(3),ANIR,lshift,16,params)

set(axn(2:3),'ydir','reverse','ycolor','none','GridAlpha',0.5,'ylim',ylimits,'YMinorGrid','on')

title(axn,'')
xlabel(axn(1),{'Speed vs power', [char(946) '_{1}']},'interpreter','tex')
xlabel(axn(2:3),{'Autocorr. peak','range'})
font_size_and_color(gcf,8)
%print(gcf,'-dpdf','-r600','-painters','supfig_F4_across_tetrodes.pdf')
end


function all_sessions_during_motion_across_probe__speed_vs_signal(ax1,speedData,vars2mdl,param2plot,xrange,pval,plotcol,msize,lw,ylimits,yplotshift)

% ax = axes 
% speedData = table of speed vs signal data;
% vars2mdl = 'medianSpeed','medianFreq','medianPdB', etc
% param2plot = b0, b1 (regression coefficients), r2, corrcoeff r
% xrange = range of x (ie for specifiying speed range >10cm/s & <95th pct
% pval = pval thresh for filling plot point

xrangeIn = cell(size(speedData,1),32);
xrangeIn(:) = {xrange};
vars2mdlIn = cell(size(speedData,1),32);
vars2mdlIn(:) = {vars2mdl};
plotYN = cell(size(speedData,1),32);
plotYN(:) = {false};

[~, fits] = cellfun(@linear_fit_of_table_or_struct_vars,speedData.ChannelData,vars2mdlIn,xrangeIn,plotYN,'uniformoutput',0);

% fits = [b0,b1,r2,pval,   corrcoeff_r,corrcoeff_p];
           %using fitlm      % using corrcoeff
                    
switch param2plot
    case 'b0'
        ncol = 1;
        pcol = 4;
    case 'b1'
        ncol = 2;
        pcol = 4;
    case 'r2'
        ncol = 3;
        pcol = 4;
    case 'corrcoeff_r'
        ncol = 5;
        pcol = 6;
end


medParam = NaN(32,1);
nchan    = size(fits,2);

for nc = 1:nchan
    
    chandata = fits(:,nc);
    chandata = cell2mat(chandata);
    if isempty(chandata)
        continue
    end
    
    sig_idx  = chandata(:,pcol) < pval;   
    sig_vals = chandata(sig_idx,ncol);
    
    scatter(ax1,chandata(:,ncol), yplotshift+(nc)*ones(length(chandata(:,ncol)),1),msize,'o','MarkerEdgeColor',plotcol)
    
    scatter(ax1,sig_vals, yplotshift+(nc)*ones(length(sig_vals),1),msize,'o','MarkerEdgeColor',plotcol,'MarkerFaceColor',plotcol)
    
    medParam(nc) = nanmedian(chandata(:,ncol));
    
    plot(ax1,[medParam(nc) medParam(nc)], [yplotshift+(nc)-0.1 yplotshift+(nc)+0.1],'k')
    
end

% plot(ax,medParam,0:nchan-1,'color',[0 0 0 0.7],'LineWidth',lw)

set(ax1,'YDir','reverse','ylim',ylimits,'YMinorGrid','on')  

xlabel(ax1,{param2plot; vars2mdl{1}; 'vs' ; vars2mdl{2}})

end

function plot_mov_vs_imm_atr_vs_con(ax1,ax2,ANI,lshift,yplotshift,params)
for n = 1:16
   atrchan = vertcat(ANI.atr{:,n});
   conchan = vertcat(ANI.con{:,n});
   if isempty(atrchan)
       continue
   end
   
   movatr = atrchan.peakrangenorm(atrchan.Speed>20);
   immatr = atrchan.peakrangenorm(atrchan.Speed<5);
   movcon = conchan.peakrangenorm(conchan.Speed>20);
   immcon = conchan.peakrangenorm(conchan.Speed<5);   
   
   % imm control
   plot(ax1,[prctile(immcon,25) prctile(immcon,75)], [n-lshift+yplotshift n-lshift+yplotshift],'color',[params.col.imm 0.6],'linewidth',1.5)
   scatter(ax1,[nanmedian(immcon) nanmedian(immcon)],[n-lshift+yplotshift n-lshift+yplotshift],10,params.col.imm,'filled','marker','o')
   % imm atropine
   plot(ax1,[prctile(immatr,25) prctile(immatr,75)], [n+lshift+yplotshift n+lshift+yplotshift],'color',[params.col.atr 0.6],'linewidth',1.5)
   scatter(ax1,[nanmedian(immatr) nanmedian(immatr)],[n+lshift+yplotshift n+lshift+yplotshift],10,params.col.atr,'filled','marker','o')
   
   % mov control
   plot(ax2,[prctile(movcon,25) prctile(movcon,75)], [n-lshift+yplotshift n-lshift+yplotshift],'color',[params.col.F 0.6],'linewidth',1.5)
   scatter(ax2,[nanmedian(movcon) nanmedian(movcon)],[n-lshift+yplotshift n-lshift+yplotshift],10,params.col.F,'filled','marker','o')
   % mov atropine
   plot(ax2,[prctile(movatr,25) prctile(movatr,75)], [n+lshift+yplotshift n+lshift+yplotshift],'color',[params.col.atr 0.6],'linewidth',1.5)
   scatter(ax2,[nanmedian(movatr) nanmedian(movatr)],[n+lshift+yplotshift n+lshift+yplotshift],10,params.col.atr,'filled','marker','o')
   
end
end