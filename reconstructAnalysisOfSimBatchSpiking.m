function [exitStatus] =reconstructAnalysisOfSimBatch(paramName1,paramName2,paramName3,param1Vals,param2Vals,param3Vals)
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
    
	for i = 1:length(param1Vals)
		for j=1:length(param2Vals)
			for k=1:length(param3Vals)
				%try                
					processedDataPath=fullfile(PROCESSED_DATA_DIR,sprintf('%s_SpikeCountAnalysisResults_%d_%d_%d.mat',simName,i,j,k));
					data=load(processedDataPath);

					modelSpikeCountHeatMaps(i,j,k)=data.modelSpikeCountHeatMaps(i,j,k);
					
					modelUndSpikeCountHeatMaps(i,j,k)=data.modelUndSpikeCountHeatMaps(i,j,k);
					
				%catch ME
				%	disp(ME.message)
				%	disp(sprintf('skipping %d_%d_%d....',i,j,k))
				%end	
		
			end
		end
    end
    disp('saving analysis results.....')
    tic
    processedDataPath=fullfile(PROCESSED_DATA_DIR,sprintf('%s_AnalysisResults.mat',simName));
    
    save(processedDataPath,'modelSpikeCountHeatMaps','modelUndSpikeCountHeatMaps'...
            ,'param1Vals', 'param2Vals', 'param3Vals', 'paramName1', 'paramName2', 'paramName3', 'simName','DATA_DIR','FIGURE_DIR','PROCESSED_DATA_DIR')
	toc
    
    %plotSpikeCountAnalysisResults(processedDataPath)
    plotSpikeCountAnalysisLinearVsLogResults(processedDataPath)
    exitStatus=1;
