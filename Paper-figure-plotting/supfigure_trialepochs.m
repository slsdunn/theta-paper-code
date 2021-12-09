function supfigure_trialepochs

params = get_parameters;
axn = supfig_trialepochs_makeFigure;


%% rat
ref = load_reference_table('R','incl','neu','level','L5|6','modality','A|V','ID','linearprobe');

R.xcfft = load_results_tables(ref,'xcorr_trial_epochs',1:32);

plotord = params.R.plotorder_recside_linprobe;
titleIDs = {'R1','R2','R3'};
for  n = 1:numel(plotord)
    
   ids = plotord{n};
   
    
    add_shaded_areas(axn(n),[0 2],[32-(params.oCL.(ids)-0.3)+1 32-(params.oCL.(ids)+0.3)+1],'k',0.2)
    if ~isempty(params.pCL.(ids))
    add_shaded_areas(axn(n),[0 2],[32-(params.pCL.(ids)-0.3)+1 32-(params.pCL.(ids)+0.3)+1],'k',0.2)   
    add_shaded_areas(axn(n),[0 2],[32-(params.rCL.(ids)-0.3)+1 32-(params.rCL.(ids)+0.3)+1],'k',0.2)
    end
    
   xcfft = R.xcfft(contains(ref.IDside,ids),:);
   quantify_fft_xcorr_trial_epochs__depth_plot(axn(n),xcfft,params.col.hold,params.col.R,params.col.rwd,0.3)
      
   %legend
   title(axn(n),titleIDs{n},'Interpreter','tex','Position',[0.5 1])
end

%% ferret
ref = load_reference_table('F','incl','neu','level','L5|6','modality','A|V','ID','linearprobe');

F.xcfft = load_results_tables(ref,'xcorr_trial_epochs',1:32);

plotord = params.F.plotorder_recside_linprobe;
titleIDs = {'F1_{L}','F1_{R}','F2_{L}','F3_{L}','F3_{R}'};
for  n = 1:numel(plotord)
    
   ids = plotord{n};
   
    
    add_shaded_areas(axn(n+3),[0 2],[32-(params.oCL.(ids)-0.3)+1 32-(params.oCL.(ids)+0.3)+1],'k',0.2)
    if ~isempty(params.pCL.(ids))
    add_shaded_areas(axn(n+3),[0 2],[32-(params.pCL.(ids)-0.3)+1 32-(params.pCL.(ids)+0.3)+1],'k',0.2)   
    add_shaded_areas(axn(n+3),[0 2],[32-(params.rCL.(ids)-0.3)+1 32-(params.rCL.(ids)+0.3)+1],'k',0.2)
    end
    
   xcfft = F.xcfft(contains(ref.IDside,ids),:);
   quantify_fft_xcorr_trial_epochs__depth_plot(axn(n+3),xcfft,params.col.hold,params.col.F,params.col.rwd,0.3)
      
   %legend
   title(axn(n+3),titleIDs{n},'Interpreter','tex','Position',[0.5 1])
end

%% tidy fig
set(axn(1:8),'xlim',[0.15 0.85])
set(axn([2,3,5,6,7,8]),'yticklabels','')
xlabel(axn([2,6]),'Autocorr. peak range')
set(axn([1,4]),'ytick',2:5:32,'yticklabels',flip(0:0.5:3.2))
set(axn(1:8),'ytick',2:5:32,'YminorGrid','on')
ylabel(axn([1,4]),'Depth (mm)')
font_size_and_color(gcf,8)

%print(gcf,'-dpdf','-r600','-painters','supfigure_trialepochs_MATLABoutput.pdf')
