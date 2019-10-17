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
    modelPeakResponseHeatMaps=NaN(length(param1Vals),length(param2Vals),length(param3Vals));
    modelPeakResponsePositions=NaN(length(param1Vals),length(param2Vals),length(param3Vals));
    modelUndPeakResponseHeatMaps=NaN(length(param1Vals),length(param2Vals),length(param3Vals));
    modelUndPeakResponsePositions=NaN(length(param1Vals),length(param2Vals),length(param3Vals));
    %modelPeakResponseThetaPhase=NaN(length(param1Vals),length(param2Vals),length(param3Vals));
    modelAvgThetaSeqTimeSlopes=NaN(length(param1Vals),length(param2Vals),length(param3Vals));
    
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
					%if(k==1)
					currModelResponses=currSimObj.analysisObj.cycleL2PeakResponses;
					%elseif(k==2)
					currModelUndelayedResponses=currSimObj.analysisObj.cycleL2UndelayedPeakResponses;
					%end
					currModelThetaTimeSlopes=currSimObj.analysisObj.cycleSeqTimeSlopes;
					currModelThetaTimeSlopes=currModelThetaTimeSlopes(currModelThetaTimeSlopes>0);
					avgThetaTimeSlope=nanmean(currModelThetaTimeSlopes);
					
					[maxResponse,maxCycleIdx]=max(currModelResponses);
					maxResponsePosition=currSimObj.analysisObj.cyclePositions(maxCycleIdx);
					
					modelPeakResponseHeatMaps(i,j,k)=maxResponse;
					modelPeakResponsePositions(i,j,k)=maxResponsePosition;
				
					[maxUndelayedResponse,maxCycleIdx]=max(currModelUndelayedResponses);
					maxUndelayedResponsePosition=currSimObj.analysisObj.cyclePositions(maxCycleIdx);
					
					
					modelUndPeakResponseHeatMaps(i,j,k)=maxUndelayedResponse;
					modelUndPeakResponsePositions(i,j,k)=maxUndelayedResponsePosition;
					
				       
				  
					modelAvgThetaSeqTimeSlopes(i,j,k)=avgThetaTimeSlope;
					%modelPeakResponseThetaPhase(i,j,k)=
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
    
    save(processedDataPath,'modelAvgThetaSeqTimeSlopes','modelPeakResponseHeatMaps','modelPeakResponsePositions','modelUndPeakResponseHeatMaps','modelUndPeakResponsePositions'...
            ,'param1Vals', 'param2Vals', 'param3Vals', 'paramName1', 'paramName2', 'paramName3', 'simName','DATA_DIR','FIGURE_DIR','PROCESSED_DATA_DIR')
	toc
    
    plotAnalysisResults(processedDataPath)
    exitStatus=1;
