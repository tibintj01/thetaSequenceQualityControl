classdef SimulationBatch < handle

	properties(Constant)
		numValuesPerParam=1;
		runPar=1;
	end

	properties
		simsCategory='single_cell_precession_tuning';
		modifiedObjName1='cellsObj';
		modifiedObjName2='cellsObj';
		simArray
		
		searchParamNames
		searchParamVectors
		numSimsPerVar
		baseSim

		paramSearchAnalysisObj
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%public methods
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Constructor
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function thisObj=SimulationBatch(baseSim)
			thisObj.setSearchParamVectors();
			searchParamNames=fieldnames(thisObj.searchParamVectors);
			numSimsPerVar=length(thisObj.searchParamVectors.(searchParamNames{1}));

			thisObj.searchParamNames=searchParamNames;
			thisObj.baseSim=baseSim;
			%thisObj.searchParamNames=searchParamNames;
			%thisObj.searchParamVectors=searchParamVectors;
			thisObj.numSimsPerVar=numSimsPerVar;
			thisObj.populateSimArray();
		end

		function run(thisObj) 
			disp(sprintf('running batch of simulations for %s........',thisObj.simsCategory))
			disp('Varying:')
			parameters=thisObj.searchParamNames
		
			if(SimulationBatch.runPar==1)
				parfor i=1:thisObj.numSimsPerVar
					rng(i)
					for j=1:thisObj.numSimsPerVar
						thisObj.simArray(i,j).run()	
						thisObj.simArray(i,j).save()	
					end
				end
			else
				for i=1:thisObj.numSimsPerVar
					for j=1:thisObj.numSimsPerVar
						thisObj.simArray(i,j).run()	
						thisObj.simArray(i,j).save()	
					end
				end
	
			end
		end

		function displayContent(thisObj)
			figH=figure;
			count=0;
			for i=1:thisObj.numSimsPerVar
				for j=1:thisObj.numSimsPerVar
					count=count+1;
					subplot(thisObj.numSimsPerVar,thisObj.numSimsPerVar,count)
					thisObj.simArray(i,j).visualizeConfig(figH)
				end
			end
		end
		
		function displayResults(thisObj)
			figH=figure;
			count=0;
			for i=1:thisObj.numSimsPerVar
				for j=1:thisObj.numSimsPerVar
					count=count+1;
					subplot(thisObj.numSimsPerVar,thisObj.numSimsPerVar,count)
					thisObj.simArray(i,j).dispV_traces(figH)
				end
			end
			thisObj.simArray(1,1).configuration.simParams.extEnvObj.displayContent();
		end
		function runAnalysis(thisObj)
			figRankTransform=figure(1112);
			figPhasePosCoding=figure(1113);
			count=0;

			paramSearchAnalysisObj(thisObj.numSimsPerVar,thisObj.numSimsPerVar)=SimPhaseCodingEvaluation();
			for i=1:thisObj.numSimsPerVar
				for j=1:thisObj.numSimsPerVar
					count=count+1;

					phaseCodingEvaluationObj=SimPhaseCodingEvaluation(thisObj.simArray(i,j));
					
					%figure(figRaster)	
					figRaster=figure;
					%subplot(thisObj.numSimsPerVar,thisObj.numSimsPerVar,count)
					axRaster1=subplot(10,10,[1 90]);
					phaseCodingEvaluationObj.runPlotRaster(figRaster);
					title(removeUnderscores(thisObj.simArray(i,j).simParamsIDStr))
					%maxFigManual2d(10,3,18)
					
					figure(figRankTransform)
					subplot(thisObj.numSimsPerVar,thisObj.numSimsPerVar,count)
					phaseCodingEvaluationObj.runRankTransformAnalysis(figRankTransform); 				
					
					figure(figPhasePosCoding)	
					subplot(thisObj.numSimsPerVar,thisObj.numSimsPerVar,count)
					phaseCodingEvaluationObj.runPhaseCodeAnalysis(figPhasePosCoding); 				
				
					%figPhaseDistr=figure;
					figure(figRaster)
					%subplot(thisObj.numSimsPerVar,thisObj.numSimsPerVar,count)
					%phaseCodingEvaluationObj.runSpikeTimeDistributionAnalysis(figPhaseDistr);
					axRaster2=subplot(10,10,[91 100]);
					phaseCodingEvaluationObj.runSpikeTimeDistributionAnalysis(figRaster);
					%title(removeUnderscores(thisObj.simArray(i,j).simParamsIDStr))
					linkaxes([axRaster1 axRaster2],'x')
					maxFigManual2d(10,3,28)
					
					paramSearchAnalysisObj(i,j)=copy(phaseCodingEvaluationObj);;
				end
			end

			figure(figRaster)
			maxFigManual2d(10,2,18)

			figure(figRankTransform)
			maxFigManual2d(3,1,18)

			figure(figPhasePosCoding)
			maxFigManual2d(3,1,18)
			
			%figure(figPhaseDistr)

			thisObj.paramSearchAnalysisObj=paramSearchAnalysisObj;
		
			%saveAllOpenFigures

		end
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%private methods
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods(Access=private)
		function populateSimArray(thisObj)
			%simVector(numSims)=Simulation;
			%thisObj.simVector=simVector;
			searchParamNames=thisObj.searchParamNames;
			searchParamVectors=thisObj.searchParamVectors;

			checked=zeros(length(searchParamNames),length(searchParamNames));

			count=0;	
			%pairwise parameter vector search
			for varyParamIdx1=1:length(searchParamNames)
				paramSearchVector1=searchParamVectors.(searchParamNames{varyParamIdx1});
				for varyParamIdx2=1:length(searchParamNames)
					paramSearchVector2=searchParamVectors.(searchParamNames{varyParamIdx2});
					if(varyParamIdx1~=varyParamIdx2)
							
						for i=1:thisObj.numSimsPerVar
							for j=1:thisObj.numSimsPerVar
								if(~checked(varyParamIdx1,varyParamIdx2) && ~checked(varyParamIdx2,varyParamIdx1))

									overrideParamValues=[paramSearchVector1(i) paramSearchVector2(j)];
									overrideParamNames={searchParamNames{varyParamIdx1}, searchParamNames{varyParamIdx2}};			
									searchModifyInfo.overrideParamValues=overrideParamValues;
									searchModifyInfo.overrideParamNames=overrideParamNames;
									searchModifyInfo.modifiedObjName1=thisObj.modifiedObjName1;
									searchModifyInfo.modifiedObjName2=thisObj.modifiedObjName2;
									searchModifyInfo.batchCategory=thisObj.simsCategory;										
									count=count+1;
									modifiedSim=Simulation(thisObj.baseSim.configuration,searchModifyInfo);
									%simVector(count)=copy(modifiedSim);
									simArray(j,i)=copy(modifiedSim); %param1 along x, param2 along y dimension
								end
							end
						end
					end
					checked(varyParamIdx1,varyParamIdx2)=1;
				end
			end
			thisObj.simArray=simArray;
		end


		function setSearchParamVectors(thisObj)

			%gksBar=linspace(0,1,SimulationBatch.numValuesPerParam);
			%gnapBar=linspace(0,0.1,SimulationBatch.numValuesPerParam);
			gksBar=linspace(0,1,SimulationBatch.numValuesPerParam);
			gnapBar=linspace(0.05,0.15,SimulationBatch.numValuesPerParam);

			thisObj.searchParamVectors=struct();


			thisObj.searchParamVectors.gksBar=gksBar;
			thisObj.searchParamVectors.gnapBar=gnapBar;
		end
	end
end
