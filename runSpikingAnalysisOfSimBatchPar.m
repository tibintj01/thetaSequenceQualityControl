function [exitStatus] =runSpikingAnalysisOfSimBatchPar(paramName1,paramName2,paramName3,param1Vals,param2Vals,param3Vals,i,j,k)
    if(iscell(param1Vals))
        param1Vals=cell2mat(param1Vals);
    end
    if(iscell(param2Vals))
        param2Vals=cell2mat(param2Vals);
    end
    if(iscell(param3Vals))
        param3Vals=cell2mat(param3Vals);
    end
	directory_names
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %run specific variables
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    modelSpikeCountHeatMaps=NaN(length(param1Vals),length(param2Vals),length(param3Vals));
    modelUndSpikeCountHeatMaps=NaN(length(param1Vals),length(param2Vals),length(param3Vals));

	%try                
		filePath=getRegexFilePath(DATA_DIR,sprintf('simData_%s_%.5f_%s_%.5f_%s_%.5f.mat',paramName1,param1Vals(i),paramName2,param2Vals(j),paramName3,param3Vals(k)));
		tic
		disp('loading saved sim data....')
				%matfileObj=matfile(filePath);
		data=load(filePath);
		toc
		
		
		currSimObj=data.thisObj;
	
		%currSimObj.analysisObj
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%collect spikes that occur during place inputs
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		spikingTimeWindowStart=currSimObj.externalInputObj.currInjectorMatrix(1,1).pulseStartTime;
		spikingTimeWindowEnd=currSimObj.externalInputObj.currInjectorMatrix(1,end).pulseEndTime;

		spikeTimesL2=currSimObj.cellsObj.spikeTimesL2;
		spikeTimesInt=currSimObj.cellsObj.spikeTimesInt;
		
		spikeTimesL2_InWindow=spikeTimesL2(spikeTimesL2>spikingTimeWindowStart & spikeTimesL2<spikingTimeWindowEnd);
		spikeTimesInt_InWindow=spikeTimesInt(spikeTimesInt>spikingTimeWindowStart & spikeTimesInt<spikingTimeWindowEnd);
		
		numSpikesDuringInput_L2=length(spikeTimesL2_InWindow);
		numSpikesDuringInput_Int=length(spikeTimesInt_InWindow);
		
		dt=currSimObj.configuration.simParams.dt;

		l2_spikeIndices=round(spikeTimesL2/dt);
		l2_SpikePositions=currSimObj.externalEnvObj.rodentPositionVsTime(l2_spikeIndices);
		l2_SpikeRunningSpeeds=currSimObj.externalEnvObj.rodentRunningSpeed(l2_spikeIndices);

		l2_cellTypeLabel=zeros(size(l2_SpikePositions));
		
		int_spikeIndices=round(spikeTimesInt/dt);
		int_SpikePositions=currSimObj.externalEnvObj.rodentPositionVsTime(int_spikeIndices);
		int_SpikeRunningSpeeds=currSimObj.externalEnvObj.rodentRunningSpeed(int_spikeIndices);
		
		int_cellTypeLabel=ones(size(int_SpikePositions));

		modelSpikeCountHeatMaps(i,j,k)=numSpikesDuringInput_L2;
		modelUndSpikeCountHeatMaps(i,j,k)=numSpikesDuringInput_Int;

		newPositions=[l2_SpikePositions(:); int_SpikePositions(:)];
		newSpeeds=[l2_SpikeRunningSpeeds(:);int_SpikeRunningSpeeds(:)];
		newLabels=[l2_cellTypeLabel(:);int_cellTypeLabel(:)];
		

		newDIs=param1Vals(i)*ones(size(newPositions));
		
		newT=array2table([newLabels(:), newSpeeds(:), newPositions(:),newDIs(:)],'VariableNames',{'ReadoutType','Speed','Position', 'DIrank'});

		
	%catch ME
	%	disp(ME.message)
	%	disp(sprintf('skipping %d_%d_%d....',i,j,k))
	%end	
	
    disp('saving analysis results.....')
    tic
    processedDataPathSpikeCount=fullfile(PROCESSED_DATA_DIR,sprintf('%s_SpikeCountAnalysisResults_%d_%d_%d.mat',simName,i,j,k));
    processedDataPathSpeedPosition=fullfile(PROCESSED_DATA_DIR,sprintf('%s_SpeedPositionSpikeTable_%d_%d_%d.mat',simName,i,j,k));
    
    save(processedDataPathSpikeCount,'modelSpikeCountHeatMaps','modelUndSpikeCountHeatMaps'...
            ,'param1Vals', 'param2Vals', 'param3Vals', 'paramName1', 'paramName2', 'paramName3', 'simName','DATA_DIR','FIGURE_DIR','PROCESSED_DATA_DIR')
   
	%0 is L2, 1 is Integrator 
	save(processedDataPathSpeedPosition,'newT')
	toc
    
    %plotAnalysisResults(processedDataPath)
    exitStatus=1;
