%singleCellMatFiles=getRegexFilePaths(pwd,'SlopeOffsetBiophysicsData_gNaP_*_gKS_*_Cell.mat');
singleCellMatFiles=getRegexFilePaths(pwd,'AllPeakSlopeOffsetBiophysicsData_gNaP_*_gKS_*_Cell.mat');

numPts=20;
numPts=30;
%numPts=40;
gnapVector=NaN(numPts,1);
gksVector=NaN(numPts,1);

slopeMatrix=NaN(numPts,numPts);
entryPhaseMatrix=NaN(numPts,numPts);
for i=1:length(singleCellMatFiles)
	data=load(singleCellMatFiles{i});
	try
		gnapIdx=data.gnapIdx;
		gksIdx=data.gksIdx;

		slopeMatrix(gnapIdx,gksIdx)=data.phasePrecessSlopeDegPerSec;
		entryPhaseMatrix(gnapIdx,gksIdx)=data.entryPhase;

		gnapVector(gnapIdx)=data.gnap;
		gksVector(gksIdx)=data.gks;
	end
end

%load('SlopeOffsetBiophysicsData.mat')
figure
%imagesc(gks,gnap,slopeMatrix)
omarPcolor(gksVector,gnapVector,slopeMatrix)
colormap(flipud(parula))
h1=colorbar
xlabel('G_{KS} (mS/cm^2)')
ylabel('G_{NaP} (mS/cm^2)')
ylabel(h1,'Phase precession slope (degrees/sec)')
%caxis([-230 -20])
caxis([-250 -30])
saveas(gcf,'gNaP_gKS_AllPeakPhasePrecessionSlopeHeatMap.tif')

figure
%imagesc(gksVector,gnapVector,entryPhaseMatrix)
omarPcolor(gksVector,gnapVector,entryPhaseMatrix)
colormap(parula)
%colormap(jet)
h2=colorbar
%caxis([235 275])
caxis([250 275])
xlabel('G_{KS} (mS/cm^2)')
ylabel('G_{NaP} (mS/cm^2)')
ylabel(h2,'Entry phase (degrees)')

saveas(gcf,'gNaP_gKS_AllPeakPhaseOffsetHeatMap.tif')
