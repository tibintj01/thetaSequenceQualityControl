function [] =maxFigManual2d(sizeFactX,sizeFactY,fontSize)

if(~exist('fontSize'))
	fontSize=12;
end

fig = gcf; % Current figure handle
if(~exist('sizeFactX') || ~exist('sizeFactY'))
	%sizeFactX=6;
	%sizeFactY=6;
	sizeFactX=1;
	sizeFactY=1;
end
%xLength=18;
%yLength=9;
xLength=8;
yLength=11;

set(fig, 'PaperUnits', 'inches');
set(gcf, 'PaperSize',[ xLength*sizeFactX yLength*sizeFactY]);
set(fig, 'PaperPosition', [0,0,(get(fig,'PaperSize'))])
set(fig, 'visible', 'on')

setFigFontTo(fontSize)
setFigTickOut()

allBoxOff

%set(gca, 'fontsize', fontsize);
%set(gca, 'tickdir', 'out');
%{
set(h,'Resize','off');
set(h,'PaperPositionMode','manual');
set(h,'PaperPosition',[0 0 xLength*sizeFactX yLength*sizeFactY]);
set(h,'PaperUnits','centimeters');
set(h,'PaperSize',[ xLength*sizeFactX yLength*sizeFactY]); % IEEE columnwidth = 9cm
set(h,'Position',[0 0 xLength*sizeFactX yLength*sizeFactY]);
%}




