filePathRegex='simData_DI_SORTED_PERM_RANK_5040.00000_CONSTANT_RUN_SPEED_*_USE_LINEAR_DELAYS_0.00000.mat'
dataDir='/scratch/ojahmed_fluxm/tibintj/results/backToIntegrator/raw_data';

filePaths=getRegexFilePaths(dataDir,filePathRegex);

for i=1:length(filePaths)

	disp(sprintf('opening %s.....',filePaths{i}))

	data=load(filePaths{i});
	currSimObj=data.thisObj;

	spikingTimeWindowStart=currSimObj.externalInputObj.currInjectorMatrix(1,1).pulseStartTime;
	spikingTimeWindowEnd=currSimObj.externalInputObj.currInjectorMatrix(1,end).pulseEndTime;

	spikingTimeWindowDuration=spikingTimeWindowEnd-spikingTimeWindowStart;
	disp(sprintf('Time window: %.5f msec',spikingTimeWindowDuration))
end
