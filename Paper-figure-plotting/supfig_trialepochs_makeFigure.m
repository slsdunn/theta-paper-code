
function axn = supfig_trialepochs_makeFigure
% function to make figure: supfig_trialepochs

fig = figure('units','centimeters','position',[17.9          0.7         17.4         24.7]);
fig.Name = 'supfig_trialepochs' ;

axn(1) = axes('next','add','units','centimeters','Position',[3.25         19.5            2          4.5],'View', [0  90]);
title('axes1','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(2) = axes('next','add','units','centimeters','Position',[5.5         19.5            2          4.5],'View', [0  90]);
title('axes2','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(3) = axes('next','add','units','centimeters','Position',[7.75         19.5            2          4.5],'View', [0  90]);
title('axes3','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(4) = axes('next','add','units','centimeters','Position',[3.25           13            2          4.5],'View', [0  90]);
title('axes4','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(5) = axes('next','add','units','centimeters','Position',[5.5           13            2          4.5],'View', [0  90]);
title('axes5','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(6) = axes('next','add','units','centimeters','Position',[7.75           13            2          4.5],'View', [0  90]);
title('axes6','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(7) = axes('next','add','units','centimeters','Position',[10           13            2          4.5],'View', [0  90]);
title('axes7','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(8) = axes('next','add','units','centimeters','Position',[12.25           13            2          4.5],'View', [0  90]);
title('axes8','Units', 'normalized', 'Position', [0.5, 0.5]);


