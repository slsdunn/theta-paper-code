params = get_parameters;


% rat
ref = load_reference_table('R','incl','neu','level','L5|6','modality','A|V','ID','linearprobe');
ids = params.R.IDsides;

r.imm.med = NaN(32,3);
r.imm.pct25 = NaN(32,3);
r.imm.pct75 = NaN(32,3);
r.mov.med = NaN(32,3);
r.mov.pct25 = NaN(32,3);
r.mov.pct75 = NaN(32,3);
for n = 28:32

    xctbls = load_results_tables(ref,'xcorr_vs_speed',n,params);
    
    for nid = 1:3
     
       idtbl = xctbls(contains(ref.IDside,ids{nid}));
       iddat = vertcat(idtbl{:});
       
       r.imm.med(n,nid) = nanmedian(iddat.peakrangenorm(iddat.Speed<5));
       r.imm.pct25(n,nid) = prctile(iddat.peakrangenorm(iddat.Speed<5),25);
       r.imm.pct75(n,nid) = prctile(iddat.peakrangenorm(iddat.Speed<5),75);
       r.mov.med(n,nid) = nanmedian(iddat.peakrangenorm(iddat.Speed>20));
       r.mov.pct25(n,nid) = prctile(iddat.peakrangenorm(iddat.Speed>20),25);
       r.mov.pct75(n,nid) = prctile(iddat.peakrangenorm(iddat.Speed>20),75);
    end
end




% ferret
ref = load_reference_table('F','incl','neu','level','L5|6','modality','A|V','ID','linearprobe');
ids = params.F.IDsides;

f.imm.med = NaN(32,3);
f.imm.pct25 = NaN(32,3);
f.imm.pct75 = NaN(32,3);
f.mov.med = NaN(32,3);
f.mov.pct25 = NaN(32,3);
f.mov.pct75 = NaN(32,3);
for n = 1:32

    xctbls = load_results_tables(ref,'xcorr_vs_speed',n,params);
    
    for nid = 1:5
     
       idtbl = xctbls(contains(ref.IDside,ids{nid}));
       iddat = vertcat(idtbl{:});
       
       f.imm.med(n,nid) = nanmedian(iddat.peakrangenorm(iddat.Speed<5));
       f.imm.pct25(n,nid) = prctile(iddat.peakrangenorm(iddat.Speed<5),25);
       f.imm.pct75(n,nid) = prctile(iddat.peakrangenorm(iddat.Speed<5),75);
       f.mov.med(n,nid) = nanmedian(iddat.peakrangenorm(iddat.Speed>20));
       f.mov.pct25(n,nid) = prctile(iddat.peakrangenorm(iddat.Speed>20),25);
       f.mov.pct75(n,nid) = prctile(iddat.peakrangenorm(iddat.Speed>20),75);
    end
end


axn = supfigure_mov_vs_imm_makeFigure;
patchw = 0.45;
patchcol = [0.5 0.5 0.5];
patcha = 0.3;
ids = params.R.IDsides;
t = params.R.plotorder_animal_lbl;
for n =1:3
shade_between_lines(axn(n),[r.imm.pct25(:,n) r.imm.pct75(:,n)],transpose(1:32),params.col.imm,0.5)
shade_between_lines(axn(n),[r.mov.pct25(:,n) r.mov.pct75(:,n)],transpose(1:32),params.col.(ids{n}),0.5)
plot(axn(n),r.imm.med(:,n),1:32,'color',params.col.imm)
plot(axn(n),r.mov.med(:,n),1:32,'color',params.col.(ids{n}))
if ~isempty(params.oCL.(ids{n}))
   add_shaded_areas(axn(n), [0.1 0.75],[params.oCL.(ids{n})-patchw params.oCL.(ids{n})+patchw],patchcol,patcha) % -1 as plotted from 0-31
end
if ~isempty(params.pCL.(ids{n}))
   add_shaded_areas(axn(n), [0.1 0.75],[params.pCL.(ids{n})-patchw params.pCL.(ids{n})+patchw],patchcol,patcha)
end
if ~isempty(params.rCL.(ids{n}))
   add_shaded_areas(axn(n), [0.1 0.75],[params.rCL.(ids{n})-patchw params.rCL.(ids{n})+patchw],patchcol,patcha)
end
set(axn(n),'YDir','reverse','ylim',[0.5 32.5],'xlim',[0.1 0.75],'YminorGrid','on')
title(axn(n),t{n},'Position',[0.5 1])
end

ids = params.F.IDsides;
t = params.F.plotorder_recside_linprobe_lbl;
for n =1:5
shade_between_lines(axn(n+3),[f.imm.pct25(:,n) f.imm.pct75(:,n)],transpose(1:32),params.col.imm,0.5)
shade_between_lines(axn(n+3),[f.mov.pct25(:,n) f.mov.pct75(:,n)],transpose(1:32),params.col.(ids{n}),0.5)
plot(axn(n+3),f.imm.med(:,n),1:32,'color',params.col.imm)
plot(axn(n+3),f.mov.med(:,n),1:32,'color',params.col.(ids{n}))
if ~isempty(params.oCL.(ids{n}))
   add_shaded_areas(axn(n+3), [0.1 0.75],[params.oCL.(ids{n})-patchw params.oCL.(ids{n})+patchw],patchcol,patcha) % -1 as plotted from 0-31
end
if ~isempty(params.pCL.(ids{n}))
   add_shaded_areas(axn(n+3), [0.1 0.75],[params.pCL.(ids{n})-patchw params.pCL.(ids{n})+patchw],patchcol,patcha)
end
if ~isempty(params.rCL.(ids{n}))
   add_shaded_areas(axn(n+3), [0.1 0.75],[params.rCL.(ids{n})-patchw params.rCL.(ids{n})+patchw],patchcol,patcha)
end
set(axn(n+3),'YDir','reverse','ylim',[0.5 32.5],'xlim',[0.1 0.75],'YminorGrid','on')
title(axn(n+3),t{n},'Position',[0.5 1],'Interpreter','tex')
end

set(axn([2,3,5,6,7,8]),'ycolor','none')
set(axn([1,4]),'ytick',[6:5:32],'yticklabel',[0.5:0.5:3.2])
ylabel(axn(1),'Depth (mm)')
ylabel(axn(4),'Depth (mm)')
xlabel(axn([2,6]),'Autocorr. peak range')

font_size_and_color(gcf,8)

%print(gcf,'-dpdf','-r600','-painters','supfigure_mov_vs_imm_MATLABoutput.pdf')