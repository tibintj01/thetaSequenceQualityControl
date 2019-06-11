load('SlopeOffsetBiophysicsData.mat')
figure
%imagesc(gks,gnap,slopeMatrix)

omarPcolor(gks,gnap,slopeMatrix)
colormap(parula)
h1=colorbar
xlabel('G_{KS} (mS/cm^2)')
ylabel('G_{NaP} (mS/cm^2)')
ylabel(h1,'Phase precession slope (degrees/sec)')

saveas(gcf,'gNaP_gKS_PhasePrecessionSlopeHeatMap.tif')

figure
%imagesc(gks,gnap,entryPhaseMatrix)
omarPcolor(gks,gnap,entryPhaseMatrix)
colormap(parula)
h2=colorbar

xlabel('G_{KS} (mS/cm^2)')
ylabel('G_{NaP} (mS/cm^2)')
ylabel(h2,'Entry phase (degrees)')

saveas(gcf,'gNaP_gKS_PhaseOffsetHeatMap.tif')


%{
figure

omarPcolor(gks,gnap,placeFieldWidthMatrix)
colormap(parula)
h1=colorbar
xlabel('G_{KS} (mS/cm^2)')
ylabel('G_{NaP} (mS/cm^2)')
ylabel(h1,'Place field width (msec)')

saveas(gcf,'gNaP_gKS_PlaceFieldWidthHeatMap.tif')
%}
