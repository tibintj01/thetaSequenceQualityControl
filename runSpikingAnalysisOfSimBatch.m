function [exitStatus] = runAnalysisOfSimBatch(paramName1,paramName2,paramName3,param1Vals,param2Vals,param3Vals)
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
    modelSpikeRateHeatMaps=NaN(length(param1Vals),length(param2Vals),length(param3Vals));
    modelSpikeRatePositions=NaN(length(param1Vals),length(param2Vals),length(param3Vals));
    modelUndSpikeRateHeatMaps=NaN(length(param1Vals),length(param2Vals),length(param3Vals));
    modelUndSpikeRatePositions=NaN(length(param1Vals),length(param2Vals),length(param3Vals));
    
	for i = 1:length(param1Vals)
		for j=1:length(param2Vals)
			for k=1:length(param3Vals)
				try                
					filePath=getRegexFilePath(DATA_DIR,sprintf('simData_%s_%.5f_%s_%.5f_%s_%.5f.mat',paramName1,param1Vals(i),paramName2,param2Vals(j),paramName3,param3Vals(k)));
					tic
					disp('loading saved sim data....')
							%matfileObj=matfile(filePath);
					data=load(filePath);
					toc
					
					
					currSimObj=data.thisObj;
					
					modelSpikeRateHeatMaps(i,j,k)=maxResponse;
					modelSpikeRatePositions(i,j,k)=maxResponsePosition;
				
					[maxUndelayedResponse,maxCycleIdx]=max(currModelUndelayedResponses);
					maxUndelayedResponsePosition=currSimObj.analysisObj.cyclePositions(maxCycleIdx);
					
					
					modelUndSpikeRateHeatMaps(i,j,k)=maxUndelayedResponse;
					modelUndSpikeRatePositions(i,j,k)=maxUndelayedResponsePosition;
					
				       
				  
					modelAvgThetaSeqTimeSlopes(i,j,k)=avgThetaTimeSlope;
					%modelSpikeRateThetaPhase(i,j,k)=
				catch ME
					disp(ME.message)
					disp(sprintf('skipping %d_%d_%d....',i,j,k))
				end	
		
			end
		end
    end
    disp('saving analysis results.....')
    tic
    processedDataPath=fullfile(PROCESSED_DATA_DIR,sprintf('%s_AnalysisResults.mat',simName));
    
    save(processedDataPath,'modelAvgThetaSeqTimeSlopes','modelSpikeRateHeatMaps','modelSpikeRatePositions','modelUndSpikeRateHeatMaps','modelUndSpikeRatePositions'...
            ,'param1Vals', 'param2Vals', 'param3Vals', 'paramName1', 'paramName2', 'paramName3', 'simName','DATA_DIR','FIGURE_DIR','PROCESSED_DATA_DIR')
	toc
    
    plotAnalysisResults(processedDataPath)
    exitStatus=1;
