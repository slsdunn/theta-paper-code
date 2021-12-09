
function [axn,~] = neural_cleaning_psd_figure
% function to make figure

figure('units','centimeters','position',[5.5          1.5         36.5           20]);

axn(1) = axes('next','add','units','centimeters','Position',[2  14  14   5]);
title('axes1','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(2) = axes('next','add','units','centimeters','Position',[2         9.5           6           3]);
title('axes2','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(3) = axes('next','add','units','centimeters','Position',[9         9.5           6           3]);
title('axes3','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(4) = axes('next','add','units','centimeters','Position',[2  6  6  3]);
title('axes4','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(5) = axes('next','add','units','centimeters','Position',[9  6  6  3]);
title('axes5','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(6) = axes('next','add','units','centimeters','Position',[6         1.5           6           4]);
title('axes6','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(7) = axes('next','add','units','centimeters','Position',[20  11  14   8]);
title('axes7','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(8) = axes('next','add','units','centimeters','Position',[20          1.5           14            8]);
title('axes8','Units', 'normalized', 'Position', [0.5, 0.5]);


