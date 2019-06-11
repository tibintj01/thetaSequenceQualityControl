function [] = setFontTo(fontSize)
	set(findall(gcf,'-property','FontSize'),'FontSize',fontSize)
