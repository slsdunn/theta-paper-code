
function axn = supfigure_mov_vs_imm_makeFigure
% function to make figure: supfig_mov_vs_imm

fig = figure('units','centimeters','position',[17.8594     0.714375      17.4096      24.6856]);
fig.Name = 'supfig_mov_vs_imm' ;

axn(1) = axes('next','add','units','centimeters','Position',[2.25           17            2          4.5],'View', [0  90]);
title('axes1','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(2) = axes('next','add','units','centimeters','Position',[4.5           17            2          4.5],'View', [0  90]);
title('axes2','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(3) = axes('next','add','units','centimeters','Position',[6.75           17            2          4.5],'View', [0  90]);
title('axes3','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(4) = axes('next','add','units','centimeters','Position',[2.25           11            2          4.5],'View', [0  90]);
title('axes4','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(5) = axes('next','add','units','centimeters','Position',[4.5           11            2          4.5],'View', [0  90]);
title('axes5','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(6) = axes('next','add','units','centimeters','Position',[6.75           11            2          4.5],'View', [0  90]);
title('axes6','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(7) = axes('next','add','units','centimeters','Position',[9           11            2          4.5],'View', [0  90]);
title('axes7','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(8) = axes('next','add','units','centimeters','Position',[11.25           11            2          4.5],'View', [0  90]);
title('axes8','Units', 'normalized', 'Position', [0.5, 0.5]);


