
function axn = supfigure_F4_across_tetrodes_makeFigure
% function to make figure: plot_histology_trace_and_psds_

fig = figure('units','centimeters','position',[5            1         17.4         24.7]);
fig.Name = 'plot_histology_trace_and_psds_' ;

axn(1) = axes('next','add','units','centimeters','Position',[2  10   4  11],'View', [0  90]);
title('axes1','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(2) = axes('next','add','units','centimeters','Position',[6.2           10            3           11],'View', [0  90]);
title('axes2','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(3) = axes('next','add','units','centimeters','Position',[9.4           10            3           11],'View', [0  90]);
title('axes3','Units', 'normalized', 'Position', [0.5, 0.5]);


