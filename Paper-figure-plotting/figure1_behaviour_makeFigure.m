
function axn = figure1_behaviour_makeFigure
% function to make figure: figure1_behaviour

fig = figure('units','centimeters','position',[18.9         10.6          8.5            5]);
fig.Name = 'figure1_behaviour' ;

axn(1) = axes('next','add','units','centimeters','Position',[0.79         1.5         1.5        2.75],'View', [0  90]);
title('axes1','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(2) = axes('next','add','units','centimeters','Position',[2.39         1.5         1.5        2.75],'View', [0  90]);
title('axes2','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(3) = axes('next','add','units','centimeters','Position',[4.73         1.5         1.5        2.75],'View', [0  90]);
title('axes3','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(4) = axes('next','add','units','centimeters','Position',[6.98         1.5         1.5        2.75],'View', [0  90]);
title('axes4','Units', 'normalized', 'Position', [0.5, 0.5]);


