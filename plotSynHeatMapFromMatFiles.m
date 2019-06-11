%twoCellMatFiles=getRegexFilePaths(pwd,'SlopeOffsetTwoCellBiophysicsData*.mat');
%numPts=10;
%ALL_PEAKS=1;
%ALL_PEAKS=0;

if(ALL_PEAKS)
	twoCellMatFiles=getRegexFilePaths(pwd,'AllPeaksSlopeOffsetTwoCellBiophysicsData*PLACE*.mat');
else
	twoCellMatFiles=getRegexFilePaths(pwd,'SlopeOffsetTwoCellBiophysicsData*PLACE*.mat');
end

%numPts=20;
%numPts=30;
%numPts=4;
gsyn12Vector=NaN(numPts,1);
gsyn21Vector=NaN(numPts,1);

slopeRatioMatrix=NaN(numPts,numPts);
slopeDiffMatrix=NaN(numPts,numPts);
entryPhaseDiffMatrix=NaN(numPts,numPts);

placeFieldWidthDiffMatrix=NaN(numPts,numPts);

for i=1:length(twoCellMatFiles)
	data=load(twoCellMatFiles{i});
	%try
		gsyn12Idx=data.gsyn12Idx;
		gsyn21Idx=data.gsyn21Idx;

		slopeRatioMatrix(gsyn12Idx,gsyn21Idx)=data.phasePrecessSlopeDegPerSec1/data.phasePrecessSlopeDegPerSec2;
		slopeDiffMatrix(gsyn12Idx,gsyn21Idx)=data.phasePrecessSlopeDegPerSec1-data.phasePrecessSlopeDegPerSec2;

		entryPhaseDiffMatrix(gsyn12Idx,gsyn21Idx)=data.entryPhase1-data.entryPhase2;
		
		%placeFieldWidthDiffMatrix(gsyn12Idx,gsyn21Idx)=data.placeFieldWidth1-data.placeFieldWidth2;
		placeFieldWidthDiffMatrix(gsyn12Idx,gsyn21Idx)=(data.placeFieldWidth1)/data.placeFieldWidth2;

		gsyn12Vector(gsyn12Idx)=data.gsyn12;
		gsyn21Vector(gsyn21Idx)=data.gsyn21;
	%end
end
gnap1=data.gnap1;
gnap2=data.gnap2;
gks1=data.gks1;
gks2=data.gks2;

%load('SlopeOffsetBiophysicsData.mat')
figure
%imagesc(gsyn21,gsyn12,slopeRatioMatrix)
%omarPcolor(gsyn21Vector,gsyn12Vector,slopeRatioMatrix)
omarPcolor(gsyn21Vector,gsyn12Vector,slopeDiffMatrix)
daspect([1 1 1])

centerCmap(slopeDiffMatrix)


%colormap(flipud(parula))
%colormap((parula))
colormap(blackOuterColorMap)
h1=colorbar
xlabel('G_{syn21} (mS/cm^2)')
ylabel('G_{syn12} (mS/cm^2)')
%ylabel(h1,'Phase precession slope (degrees/sec)')
%ylabel(h1,'Phase precession slope ratio')
ylabel(h1,'Phase precession rate difference (deg/sec)')
%title({'Coupling strength and phase precession rate difference',sprintf('G_{NaP1}=%.2f, G_{KS1}=%.2f, G_{NaP2}=%.2f, G_{KS2}=%.2f',gnap1,gks1,gnap2,gks2)})
title({'Coupling strength and 1st peak phase precession rate difference',sprintf('G_{NaP1}=%.2f, G_{KS1}=%.2f, G_{NaP2}=%.2f, G_{KS2}=%.2f',gnap1,gks1,gnap2,gks2)})
shading flat
%caxis([-70 70])
%caxis([-20 20])
if(ALL_PEAKS)
	%saveas(gcf,'AllPeaks_gsyn12_gsyn21_PhasePrecessionSlopeHeatMap.tif')
	saveas(gcf,'AllPeaks_gsyn12_gsyn21_PhasePrecessionSlopeHeatMap.tif')
else
	%saveas(gcf,'gsyn12_gsyn21_PhasePrecessionSlopeHeatMap.tif')
	saveas(gcf,'gsyn12_gsyn21_PhasePrecessionSlopeHeatMap.tif')
end

figure
%imagesc(gsyn21Vector,gsyn12Vector,entryPhaseDiffMatrix)
omarPcolor(gsyn21Vector,gsyn12Vector,entryPhaseDiffMatrix)
daspect([1 1 1])
%colormap(flipud(parula))
%colormap((parula))
colormap(blackOuterColorMap)
h2=colorbar
title({'Coupling strength and place field entry phase difference',sprintf('G_{NaP1}=%.2f, G_{KS1}=%.2f, G_{NaP2}=%.2f, G_{KS2}=%.2f',gnap1,gks1,gnap2,gks2)})

centerCmap(entryPhaseDiffMatrix)

xlabel('G_{syn21} (mS/cm^2)')
ylabel('G_{syn12} (mS/cm^2)')
ylabel(h2,'Entry phase (degrees)')

shading flat
if(ALL_PEAKS)
	saveas(gcf,'AllPeaks_gsyn12_gsyn21_PhaseOffsetHeatMap.tif')
else
	saveas(gcf,'gsyn12_gsyn21_PhaseOffsetHeatMap.tif')
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%place field width diff plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
%imagesc(gsyn21Vector,gsyn12Vector,entryPhaseDiffMatrix)
omarPcolor(gsyn21Vector,gsyn12Vector,placeFieldWidthDiffMatrix)
daspect([1 1 1])
%colormap(flipud(parula))
colormap((parula))
%colormap(blackOuterColorMap)
colormap(blackMiddleColorMap)
h2=colorbar
title({'Coupling strength and place field width ratio',sprintf('G_{NaP1}=%.2f, G_{KS1}=%.2f, G_{NaP2}=%.2f, G_{KS2}=%.2f',gnap1,gks1,gnap2,gks2)})

shading flat
centerCmap1(placeFieldWidthDiffMatrix)
xlabel('G_{syn21} (mS/cm^2)')
ylabel('G_{syn12} (mS/cm^2)')
%ylabel(h2,'Place field width (msec)')
ylabel(h2,'Place field ratio')

if(ALL_PEAKS)
        saveas(gcf,'AllPeaks_gsyn12_gsyn21_PhaseFieldWidthDiffHeatMap.tif')
else
        saveas(gcf,'gsyn12_gsyn21_PhaseFieldWidthDiffHeatMap.tif')
end



