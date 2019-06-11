%gnap=linspace(0,0.1,6);
%gks=linspace(0,2,6);

%slopeMatrix=NaN(length(gnap),length(gks));
%entryPhaseMatrix=NaN(length(gnap),length(gks));
disp('NEW2')
%for n=1:length(gnap)
parpool(18)
parfor n=1:30
	%gnap=linspace(0,0.1,40);
	%gnap=linspace(0,0.1,20);
	%gks=linspace(0,2,20);
	%gnap=linspace(0,0.1,20);
	gnap=linspace(0,0.07,30);
	gks=linspace(0,1,30);
	  for k=1:length(gks)
		gks(k)
		tic
		%[phasePrecessSlope,entryPhase]=hippocampalPrecessingSingleCell(gnap(n),gks(k));
		%try
			hippocampalPrecessingSingleCellParFor(gnap(n),gks(k),n,k);
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

plotHeatMapFromMatFiles
%plotPhasePrecessionHeatMap

