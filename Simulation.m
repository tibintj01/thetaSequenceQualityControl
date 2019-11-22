classdef Simulation < handle & matlab.mixin.Copyable 
	%encapsulate data and actions of simulation to keep my interface and implementation details separate
	properties(Constant)
		%SIM_NAME='just spiking conductances, no theta, large time constant output unit';
		%SIM_NAME='timeConstantPhaseCoding';
		%CONSTANT_TIME_MAX=3200
		%CONSTANT_TIME_MAX=3600
		%CONSTANT_TIME_MAX=4500
		%CONSTANT_TIME_MAX=7500
		CONSTANT_TIME_MAX=10000
		MAX_SIM_TIME=10000
		%CONSTANT_TIME_MAX=5000
		%CONSTANT_TIME_MAX=7000
		%CONSTANT_TIME_MAX=10000
		%OVERWRITE=1;
		%'just spiking conductances, theta, time constant vs phase locking';
	end

	properties
		configuration
		currentModifyInfo
		saveDir	
	
		cellsObj
		internalConnectivityObj
		externalInputObj
		thetaPopInputObj

		externalEnvObj

		analysisObj
		
		simParamsIDStr

		currentRunStatus='NOT_INSTANTIATED';
		currentSaveStatus='NOT_SAVED';
	end
	
	methods
		function thisObj=Simulation(simConfig,currentModifyInfo)
			if(nargin>=1)
				%by value; so that elements of batch (copied simulation objects) do not interact
				thisObj.configuration=copy(simConfig);
				thisObj.cellsObj=copy(simConfig.simParams.simCells);
				thisObj.externalEnvObj=copy(simConfig.simParams.extEnvObj);
				
				thisObj.externalInputObj=copy(thisObj.cellsObj.externalInputObj);
				thisObj.thetaPopInputObj=copy(thisObj.cellsObj.inhThetaInputArray);
				thisObj.internalConnectivityObj=copy(thisObj.cellsObj.internalConnObj); 
				%thisObj.thetaPopInputObj=copy(simConfig.simParams.thetaPopInput); 
				%by reference; access directly from simulation object
				%thisObj.thetaPopInputObj=thisObj.cellsObj.thetaPopInput; 
				%thisObj.thetaPopInputObj=thisObj.cellsObj.inhThetaInputArray; 
				%thisObj.internalConnectivityObj=thisObj.cellsObj.internalConnObj;
				%thisObj.externalInputObj=thisObj.cellsObj.externalInputObj;



				thisObj.currentRunStatus='instantiated_NOT_RUN';
			end

			if(nargin==2)
				thisObj.currentModifyInfo=currentModifyInfo;
			%	thisObj.modifyParams()
			%	%thisObj.cellsObj.externalInputObj=thisObj.externalInputObj;
			%	%thisObj.cellsObj.inhThetaInputArray=thisObj.thetaPopInputObj;
			%	%thisObj.cellsObj.internalConnObj=thisObj.internalConnectivityObj;
			end
			saveDir=sprintf(thisObj.configuration.saveDirectoryBaseRawData,thisObj.currentModifyInfo.batchCategory);
                        if(~isdir(fullfile(saveDir)))
                                mkdir(fullfile(saveDir))
                        %elseif(Simulation.OVERWRITE==1)
                        %        delete(fullfile(saveDir,'*.mat'))
                        end
			thisObj.saveDir=saveDir;
		end
		
		function run(thisObj)
			disp('running sim with.....')
			%disp(thisObj.currentModifyInfo)
			%disp(thisObj.cellsObj.gksBar)
			%disp(thisObj.cellsObj.gnapBar)
			disp(thisObj.cellsObj.gl)
			disp(thisObj.externalInputObj.currAmp)
			%fds
			%thisObj.configuration.simParams.simCells.go(); %different copy!!
			thisObj.currentRunStatus='instantiatedAndRunning........';
			thisObj.cellsObj.go();
			thisObj.currentRunStatus='instantiatedAndRan';
			
			thisObj.analysisObj=copy(SimPhaseCodingEvaluation(thisObj,1));
			thisObj.currentRunStatus='ranAndAnalyzed';
		end
		
		function save(thisObj)
			%thisObj.simParamsIDStr=sprintf('%s_%.5f_%s_%.5f_Connectivity_%s',thisObj.currentModifyInfo.overrideParamNames{1},thisObj.currentModifyInfo.overrideParamValues(1),thisObj.currentModifyInfo.overrideParamNames{2},thisObj.currentModifyInfo.overrideParamValues(2), thisObj.internalConnectivityObj.connectivityTypeStr)
			%thisObj.simParamsIDStr=sprintf('%s_%.5f_%s_%.5f_Connectivity_%s',thisObj.currentModifyInfo.overrideParamNames{1},thisObj.currentModifyInfo.overrideParamValues(1),thisObj.currentModifyInfo.overrideParamNames{2},thisObj.currentModifyInfo.overrideParamValues(2), thisObj.internalConnectivityObj.connectivityTypeStr)
			
			%thisObj.simParamsIDStr=Simulation.SIM_NAME;
			%thisObj.simParamsIDStr=sprintf('%s_%.5f_%s_%.5f_Connectivity_%s',thisObj.currentModifyInfo.overrideParamNames{1},thisObj.currentModifyInfo.overrideParamValues(1),thisObj.currentModifyInfo.overrideParamNames{2},thisObj.currentModifyInfo.overrideParamValues(2), thisObj.internalConnectivityObj.connectivityTypeStr)
			thisObj.simParamsIDStr=sprintf('%s_%.5f_%s_%.5f_%s_%.5f',thisObj.currentModifyInfo.overrideParamNames{1},thisObj.currentModifyInfo.overrideParamValues(1),thisObj.currentModifyInfo.overrideParamNames{2},thisObj.currentModifyInfo.overrideParamValues(2),thisObj.currentModifyInfo.overrideParamNames{3},thisObj.currentModifyInfo.overrideParamValues(3));
			
			saveDir=thisObj.saveDir;

			disp(sprintf('saving to: %s/.....',saveDir))
			%if(~isdir(fullfile(saveDir,thisObj.simParamsIDStr)))
			%	mkdir(fullfile(saveDir,thisObj.simParamsIDStr))
			%end

			saveFileName=sprintf('simData_%s.mat',thisObj.simParamsIDStr);
			thisObj.currentSaveStatus='saving';
			save(fullfile(saveDir,saveFileName),'thisObj','-v7.3')
			thisObj.currentSaveStatus='saved';
		end
	
		function [figH]=visualizeConfig(thisObj,figH)
                        if(exist('figH'))
                                figure(figH)
                        else
                                figH=figure
                        end

                        gnapMatrix=thisObj.cellsObj.gnapMatrix;
                        gksMatrix=thisObj.cellsObj.gksMatrix;

                        %cmap=jet(thisObj.cellsObj.numPlaces);
                        cmap=copper(thisObj.cellsObj.numPlaces);
                        for pIdx=1:thisObj.cellsObj.numPlaces
                                for cIdx=1:thisObj.cellsObj.numCellsPerPlace
                                        gksVal=gksMatrix(cIdx,pIdx);
                                        gnapVal=gnapMatrix(cIdx,pIdx);
                                        plot(gksVal,gnapVal,'o','Color',cmap(pIdx,:),'MarkerFaceColor',cmap(pIdx,:),'MarkerSize',10)
                                        hold on
                                end
                        end

                        xlabel('g_{KS} (nS/cm^2)')
                        ylabel('g_{NaP} (nS/cm^2)')

                        %xlim([0 1.5])
                        %ylim([0 0.15])
                        xlim([0 Inf])
                        ylim([0 Inf])

                        %daspect([1 1 1])

                        cb=colorbar
                        ylabel(cb,'Place No.')

                        if(thisObj.cellsObj.numPlaces>1)
                                caxis([1 thisObj.cellsObj.numPlaces])
                        end
                        colormap(copper)
                        maxFigManual2d(3,1,18)
                        title('Intrinsic conductances across place network')

			%thisObj.externalInputObj.displayContent();
                        %uberTitle('external place depolarizing input')
                end


		function [figRaster,figPhasePosCoding,figSpaceCompress,figSeqTempMatch]=visualizeSpikeTimings(thisObj)

			%figRankTransform=figure(1112);
                        %figPhasePosCoding=figure(1113);
                        %figSpaceCompress=figure(1114);
                        figPhasePosCoding=figure;
                        figSpaceCompress=figure;

			%phaseCodingEvaluationObj=SimPhaseCodingEvaluation(thisObj);
			%phaseCodingEvaluationObjStage1=SimPhaseCodingEvaluation(thisObj,1);
			phaseCodingEvaluationObjStage1=thisObj.analysisObj;
			%phaseCodingEvaluationObjStage2=SimPhaseCodingEvaluation(thisObj,2);

			figSeqTempMatch=figure;
			[figSeqTempMatch]=phaseCodingEvaluationObjStage1.setThetaSeqTimeSlopes(thisObj);

			figRaster=figure;
			%subplot(thisObj.numSimsPerVar,thisObj.numSimsPerVar,count)
			%axRaster1=subplot(10,10,[1 50]);
			%axRaster1=subplot(10,10,[1 30]);
			axRaster1=subplot(10,10,[1 20]);
			%phaseCodingEvaluationObj.runPlotRaster(figRaster);
			phaseCodingEvaluationObjStage1.runPlotRasterSingleDelayed(thisObj,figRaster);
			%phaseCodingEvaluationObj.runPlotRasterSingleDelayed(figRaster);
			xticklabels({})
			xlabel('')
			%title(removeUnderscores(thisObj.simParamsIDStr))
			if(FeedForwardConnectivity.USE_LINEAR_DELAYS)
				title('Linearly precessing CA3 spike times')
			else
				title('Logarithmically precessing CA3 spike times')
			end
			%axRaster2=subplot(10,10,[31 60]);
			axRaster2=subplot(10,10,[21 40]);
			%phaseCodingEvaluationObj.runPlotRasterDoubleDelayed(figRaster);
			phaseCodingEvaluationObjStage1.runPlotRasterDoubleDelayed(thisObj,figRaster);
			%phaseCodingEvaluationObjStage2.runPlotRasterDoubleDelayed(figRaster);
			%title('Logarithmically precessed and delayed spikes times seen by CA1 soma')
			title('Precessed and delayed spikes times seen by CA1 soma')
			xticklabels({})
			xlabel('')

			%maxFigManual2d(10,3,18)

			%analyzePhasePrecession=0;
			analyzePhasePrecession=1;

			if(analyzePhasePrecession && ThetaPopInput.amplitudeDefault>0)
				%figure(figRankTransform)
				%subplot(thisObj.numSimsPerVar,thisObj.numSimsPerVar,count)
				%phaseCodingEvaluationObj.runRankTransformAnalysis(figRankTransform);

				figure(figPhasePosCoding)
				%subplot(thisObj.numSimsPerVar,thisObj.numSimsPerVar,count)
				phaseCodingEvaluationObjStage1.runPhaseCodeAnalysis(thisObj,figPhasePosCoding,figSpaceCompress);
			end

			%figPhaseDistr=figure;
			figure(figRaster)
			%subplot(thisObj.numSimsPerVar,thisObj.numSimsPerVar,count)
			%phaseCodingEvaluationObj.runSpikeTimeDistributionAnalysis(figPhaseDistr);
			%{
			axRaster2=subplot(10,10,[51 60]);
			phaseCodingEvaluationObj.runSpikeTimeDistributionAnalysis(figRaster);
			%title(removeUnderscores(thisObj.simArray(i,j).simParamsIDStr))
			thisObj.thetaPopInputObj.addTroughLines(figRaster);
			ylabel('spike count')
			xticklabels({})
			xlabel('')
			%}

			%axRaster3=subplot(10,10,[61 70]);
			axRaster3=subplot(10,10,[41 50]);
			thetaSample=squeeze(thisObj.thetaPopInputObj.conductanceTimeSeries(1,1,:));
			simTimeAxis=thisObj.configuration.simParams.timeAxis;
			decFactor=1;
			plot(simTimeAxis(1:decFactor:end),thetaSample(1:decFactor:end),'Color','b','LineWidth',3)
			ylim([-Inf Inf])	
			ylabel('Theta g_{inh}')
			xticklabels({})
			xlabel('')

			%axRaster4=subplot(10,10,[71 80]);
			axRaster4=subplot(10,10,[51 60]);
			%axRaster4=subplot(10,10,[71 100]);
			thisObj.externalInputObj.displayContentSubplot(figRaster);
			%xticklabels({})
			%xlabel('')
			xticklabels({})
			xlabel('')

			%axRaster5=subplot(10,10,[81 90]);
			%axRaster5=subplot(10,10,[81 100]);
			axRaster5=subplot(10,10,[81 100]);
			outputVmTrace=squeeze(thisObj.cellsObj.vL2);
			
			%feedfwdGsyn=squeeze(thisObj.cellsObj.gsynL2-thisObj.cellsObj.gsynL2_I);
			feedfwdGsyn_I=squeeze(-thisObj.cellsObj.gsynL2_I);
			feedfwdGsyn_E=squeeze(thisObj.cellsObj.gsynL2);
			feedfwdIsyn=squeeze(thisObj.cellsObj.l2IsynRecord+thisObj.cellsObj.l2EsynRecord);
			yyaxis left
			plot(simTimeAxis,outputVmTrace,'k-','LineWidth',2)
			ylabel('Seq. decoder (mV)')
			xlabel('Time (msec)')
			%ylim([-Inf Inf])
			ylim([-60 10])
			%ylim([-60 -40])
			%ylim([-60 -35])

			yyaxis right
			pH=plot(simTimeAxis,feedfwdGsyn_I,'-','Color','b','LineWidth',2)
			hold on
			pH2=plot(simTimeAxis,feedfwdGsyn_E,'-','Color','g','LineWidth',2)
			%pH2=plot(simTimeAxis,feedfwdGsyn_E,'-','Color',getGrayRGB(),'LineWidth',2)
			%ylabel('Feedfwd synaptic conductance (mS/cm^2)')
                        ylabel('g_{syn} (mS/cm^2)')
                        %ylabel('g_{syn}')
			ylim([-0.1 0.2])	
			%ylim([-0.1 0.1])	
			%ylabel('Feedforward synaptic current (pA)')
			
			pH.Color(4)=0.2; %make transparent
			pH2.Color(4)=0.2; %make transparent
			
			ax=gca;
			ax.YAxis(1).Color='k'
			ax.YAxis(2).Color='k'

			%axRaster6=subplot(10,10,[91 100]);
			%axRaster6=subplot(10,10,[81 100]);
			
			axRaster6=subplot(10,10,[61 80]);
			outputVmTrace=squeeze(thisObj.cellsObj.vInt);

			feedfwdGsyn_I=squeeze(-thisObj.cellsObj.gsynInt_I);
                        feedfwdGsyn_E=squeeze(thisObj.cellsObj.gsynInt);
                        %feedfwdIsyn=squeeze(thisObj.cellsObj.l2IsynRecord+thisObj.cellsObj.l2EsynRecord);

                        yyaxis left
			pH0=plot(simTimeAxis,outputVmTrace,'k-','LineWidth',2)
                        %ylabel('Integrator (mV)')
                        ylabel('Control (mV)')
                        xlabel('Time (msec)')
                        %ylim([-Inf Inf])
			ylim([-60 10])
			%ylim([-60 -40])
			%ylim([-60 -35])
			%ylim([-60 0])

			yyaxis right
                        pH=plot(simTimeAxis,feedfwdGsyn_I,'-','Color','b','LineWidth',2)
                        hold on
                        pH2=plot(simTimeAxis,feedfwdGsyn_E,'-','Color','g','LineWidth',2)
                        %pH2=plot(simTimeAxis,feedfwdGsyn_E,'-','Color',getGrayRGB(),'LineWidth',2)
                        ylabel('g_{syn} (mS/cm^2)')
			ylim([-0.1 0.2])	
			%ylim([-0.1 0.1])	
                        %ylabel('g_{syn}')
			xticklabels({})
			xlabel('')
			
			pH.Color(4)=0.2; %make transparent
			pH2.Color(4)=0.2; %make transparent
			
			legend([pH0 pH pH2],'V_m', '-g_{inh}','g_{exc}')
			legend boxoff	
			ax=gca;
			ax.YAxis(1).Color='k'
			ax.YAxis(2).Color='k'
			%xlim([0 simTimeAxis(end)+150])
			xlim([0 Simulation.CONSTANT_TIME_MAX])
			linkaxes([axRaster1 axRaster2 axRaster3 axRaster4 axRaster5 axRaster6],'x')
			%linkaxes([axRaster1 axRaster2 axRaster3 axRaster4 axRaster5],'x')
			%linkaxes([axRaster1 axRaster2 axRaster3 axRaster4],'x')
			%axes(axRaster3)
			xlim([0 Simulation.CONSTANT_TIME_MAX])
			
			%linkaxes([axRaster1 axRaster2 axRaster3 axRaster4],'x')
			%setFigFontTo(24)
			figure(figSpaceCompress)
			%xlim([-Inf Inf])	
			%xlim([-50 50])	
			%xlim([-50 50])	
			%xlim([-10 20])	
		end	
	
		function dispV_traces(thisObj,figH)
			if(exist('figH'))
				figure(figH)
			else
				figH=figure
			end
			nr=thisObj.configuration.simParams.numCellsPerPlace;
			nc=thisObj.configuration.simParams.numPlaces;

			timeAxis=thisObj.configuration.simParams.timeAxis;

			count=0;
			axHs=[];
			rescaleSec=1;

			%cmap=jet(nc);
			cmap=copper(nc);
			for r=1:nr
				for c=1:nc
					count=count+1;
					
					%axH=subplot(nr,nc,count);
					yyaxis left
					plot(timeAxis/rescaleSec,squeeze(thisObj.cellsObj.v(r,c,:)),'Color',cmap(c,:))
					%title(thisObj.configuration.simParams.simCells.getCellIDstr(r,c))
					xlabel('Time (sec)')
					ylabel('V_m (mV)')

					yyaxis right
					%plot(timeAxis/rescaleSec,squeeze(thisObj.cellsObj.inaRecord(r,c,:)),'r-','LineWidth',3)	
					%hold on
					%plot(timeAxis/rescaleSec,squeeze(thisObj.cellsObj.ikRecord(r,c,:)),'b-','LineWidth',3)
					%plot(timeAxis/rescaleSec,squeeze(thisObj.cellsObj.iksRecord(r,c,:)),'k-','LineWidth',3)
					%ylim([-20 20])
					plot(timeAxis/rescaleSec,squeeze(thisObj.cellsObj.nks(r,c,:)),'k-','LineWidth',3)
					ylim([0 1])
					hold on	
					%axHs=[axHs axH];
					if(r==1)
						%title(sprintf('Place %d',c))
					end
				end
			end
			
			
			
			%linkaxes(axHs,'xy')
			xlim([timeAxis(1) timeAxis(end)]/rescaleSec)
			yyaxis left
			ylim([-80 10])
		            hold on
			thisObj.thetaPopInputObj.addTroughLines(figH)
			title(removeUnderscores(thisObj.simParamsIDStr))
			uberTitle('Place cell networks')
			%maxFigManual2d(1,1,10)	
			maxFigManual2d(3,1,28)
			
		end
	end

	methods(Access=private)
		function modifyParams(thisObj)
			currentModifyInfo=thisObj.currentModifyInfo;

			paramName1=currentModifyInfo.overrideParamNames{1};
			paramName2=currentModifyInfo.overrideParamNames{2};
			paramName3=currentModifyInfo.overrideParamNames{3};
			
			paramValue1=currentModifyInfo.overrideParamValues(1);
			paramValue2=currentModifyInfo.overrideParamValues(2);
			paramValue3=currentModifyInfo.overrideParamValues(3);
			
			if(contains(currentModifyInfo.modifiedObjName1,'.'))
				parseIdx=strfind(currentModifyInfo.modifiedObjName1,'.');
				preObjName=currentModifyInfo.modifiedObjName1(1:(parseIdx-1));
				postObjName=currentModifyInfo.modifiedObjName1((parseIdx+1):end);
				thisObj.(preObjName).(postObjName).(paramName1)=paramValue1;	
			else
				thisObj.(currentModifyInfo.modifiedObjName1).(paramName1)=paramValue1;	
			end
				
			thisObj.(currentModifyInfo.modifiedObjName2).(paramName2)=paramValue2;
			try
				thisObj.(currentModifyInfo.modifiedObjName3).(paramName3)=paramValue3;
			catch ME
				disp('Note: 3rd parameter not encapsulated in object!')
			end
		end
	end

end
