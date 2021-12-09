function font_size_and_color(f,fsize)

 % set font size 
set(findall(f,'-property','FontSize'),'FontSize',fsize)
set(findall(f,'Type','Text'),'color',[0.15 0.15 0.15])
set(findall(gcf,'-property','FontName'),'FontName','Arial')