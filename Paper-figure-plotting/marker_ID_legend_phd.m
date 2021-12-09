function ax1 = marker_ID_legend_phd(species,x,y,with_recsides)

%
% ax = marker_ID_legend_phd(species,x,y)
%
params = get_parameters;
switch species
    case 'F'
        if with_recsides
        IDs = {'KIWR','KIWL','EMUL','BEAR','BEAL'};%,'ANIR','ANIL'};
        IDs2 = {'F1_{\itr}';'F1_{\itl}';'F2_{\itl}';'F3_{\itr}';'F3_{\itl}'}; %;'F4_R';'F4_L'};
        ax1 = add_axes([x,y, 1,1.75]);    
        else
        IDs = {'KIW', 'EMU','BEA','ANI'};
        IDs2 = {'F1';'F2';'F3';'F4'};
        ax1 = add_axes([x,y, 1,1.5]);
        end
    case 'R'
        if with_recsides
        IDs = {'DBLUR', 'EREDR','DREDR'};
        IDs2 = {'R1';'R2';'R3'};
        ax1 = add_axes([x,y, 1,1]);
        else
        IDs = {'DBLUR', 'EREDR','DREDR'};
        IDs2 = {'R1';'R2';'R3'};
        ax1 = add_axes([x,y, 1,1]);
        end
end

for n = 1:length(IDs)
    
scatter(ax1,1, 4 - n, 70,params.col.(IDs{n}),'filled','marker',params.mkr.(IDs{n}))
text(ax1,2, 4-n,IDs2{n},'FontSize',12,'interpreter','tex')
end

set(ax1,'XColor','none','ycolor','none')