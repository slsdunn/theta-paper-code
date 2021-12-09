
function axn = supfigure2_depth_profile_makeFigure
% function to make figure: supfigure2_depth_profile

fig = figure('units','centimeters','position',[10.4         15.5          8.5            5]);
fig.Name = 'supfigure2_depth_profile' ;

axn(1) = axes('next','add','units','centimeters','Position',[0.3           1      2.0829         3.8],'View', [0  90]);
title('axes1','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(2) = axes('next','add','units','centimeters','Position',[3.3           1         1.5         3.8],'View', [0  90]);
title('axes2','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(3) = axes('next','add','units','centimeters','Position',[4.9           1         1.5         3.8],'View', [0  90]);
title('axes3','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(4) = axes('next','add','units','centimeters','Position',[6.5           1        0.85         3.8],'View', [0  90]);
title('axes4','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(5) = axes('next','add','units','centimeters','Position',[7.45           1        0.85         3.8],'View', [0  90]);
title('axes5','Units', 'normalized', 'Position', [0.5, 0.5]);


