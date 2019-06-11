%gnap=linspace(0,0.1,6);
%gks=linspace(0,2,6);
clear all
close all
clc

delete *mat

ALL_PEAKS=1;


%slopeMatrix=NaN(length(gnap),length(gks));
%entryPhaseMatrix=NaN(length(gnap),length(gks));
disp('NEW2')
%for n=1:length(gnap)
%parpool(20)
%parpool(4)

%parfor n=1:4
numPts=40;
parfor n=1:40
	numPts=40;
	
	gnap1=0.06
	gks1=0.4
	gnap2=0.06
	gks2=0.6
	%gks2=0.4
	%gnap=linspace(0,0.1,40);
	%gnap=linspace(0,0.1,20);
	%gks=linspace(0,2,20);
	%gnap=linspace(0,0.1,20);
	%gsyn12=linspace(0,0.3,20);
	%gsyn21=linspace(0,0.3,20);
	%gsyn12=linspace(0,0.15,numPts);
	%gsyn21=linspace(0,0.15,numPts);
	gsyn12=linspace(0,0.25,numPts);
	gsyn21=linspace(0,0.25,numPts);
	  for k=1:length(gsyn21)
		tic
		%[phasePrecessSlope,entryPhase]=hippocampalPrecessingSingleCell(gnap(n),gks(k));
		%try
		hippocampalPrecessingTwoCellNetworkParFor(gnap1,gks1,gnap2,gks2,gsyn12(n),gsyn21(k),n,k)		
		%catch ME
		%	disp(sprintf('error with gnap %d gks %d: %s',ME.message,n,k))
		%end
		%slopeMatrix(n,k)=phasePrecessSlope*1000;
		%entryPhaseMatrix(n,k)=entryPhase
		toc
	  end
end

%entryPhaseMatrix(end,1)=NaN;
%slopeMatrix(end,1)=NaN;

%save('SlopeOffsetBiophysicsData.mat', 'slopeMatrix','entryPhaseMatrix','gnap','gks')

plotSynHeatMapFromMatFiles
%plotPhasePrecessionHeatMap

