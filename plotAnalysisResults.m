function [exitStatus] = plotAnalysisResults(processedDataPath)
	processedData=load(processedDataPath);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%peak response heat map
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	numEncodingStrategies=size(processedData.modelPeakResponseHeatMaps,3);
	
	diRanks=processedData.param1Vals	
	
	speedValues=processedData.param2Vals;

	%approximateRestValue=-55;
	approximateRestValue=-55;


	heatMapInput.diRanks=diRanks;
	heatMapInput.speedValues=speedValues;
	
	titleStrs={'Logarithmic time coding','Linear time coding'};
	for linearTimeCoding2=1:numEncodingStrategies
		currHeatMatrix=processedData.modelPeakResponseHeatMaps(:,:,linearTimeCoding2)-approximateRestValue;
		modelResponseVarName='Peak response (mV)';
		climVals=[8 15];

		plotCurrHeatMap


		currHeatMatrix=processedData.modelPeakResponsePositions(:,:,linearTimeCoding2);
		modelResponseVarName='Peak response position (cm)';
		climVals=[30 80];

		plotCurrHeatMap
		
		currHeatMatrix=processedData.modelAvgThetaSeqTimeSlopes(:,:,linearTimeCoding2);
		modelResponseVarName='Avg. theta sequence slope (sec^{-1})';
		climVals=[0 15];

		plotCurrHeatMap
	end

	saveAllOpenFigures	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%peak response heat map
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	exitStatus=1;
