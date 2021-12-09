
function axn = figure2_example_data_makeFigure
% function to make figure: figure1

fig = figure('units','centimeters','position',[11.0331      10.4246      17.0127      8.81063]);
fig.Name = 'figure1' ;

axn(1) = axes('next','add','units','centimeters','Position',[0.5        1.35      2.7401           5],'View', [0  90]);
title('axes1','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(2) = axes('next','add','units','centimeters','Position',[0.5           7           2           2],'View', [0  90]);
title('axes2','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(3) = axes('next','add','units','centimeters','Position',[3.5         7.4        4.75         1.3],'View', [0  90]);
title('axes3','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(4) = axes('next','add','units','centimeters','Position',[3.5         0.8        4.75         6.5],'View', [0  90]);
title('axes4','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(5) = axes('next','add','units','centimeters','Position',[8.8        1.35      2.7401           5],'View', [0  90]);
title('axes5','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(6) = axes('next','add','units','centimeters','Position',[8.8      6.8148           2           2],'View', [0  90]);
title('axes6','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(7) = axes('next','add','units','centimeters','Position',[11.8          7.4         4.75          1.3],'View', [0  90]);
title('axes7','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(8) = axes('next','add','units','centimeters','Position',[11.8          0.8         4.75          6.5],'View', [0  90]);
title('axes8','Units', 'normalized', 'Position', [0.5, 0.5]);


