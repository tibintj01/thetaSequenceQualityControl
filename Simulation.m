classdef Simulation < handle & matlab.mixin.Copyable 
	%encapsulate data and actions of simulation to keep my interface and implementation details separate

	properties
		configuration
		currentModifyInfo
		
		cellsObj
		internalConnectivityObj
		externalInputObj
		thetaPopInputObj

		externalEnvObj
		
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

				%thisObj.thetaPopInputObj=copy(simConfig.simParams.thetaPopInput); 
				%by reference; access directly from simulation object
				%thisObj.thetaPopInputObj=thisObj.cellsObj.thetaPopInput; 
				thisObj.thetaPopInputObj=thisObj.cellsObj.inhThetaInputArray; 
				thisObj.internalConnectivityObj=thisObj.cellsObj.internalConnObj;
				thisObj.externalInputObj=thisObj.cellsObj.externalInputObj;

				thisObj.currentRunStatus='instantiated_NOT_RUN';
			end

			if(nargin==2)
				thisObj.currentModifyInfo=currentModifyInfo;
				thisObj.modifyParams()
			end
		end
		
		function run(thisObj)
			disp('running sim with.....')
			disp(thisObj.currentModifyInfo)
			disp(thisObj.cellsObj.gksBar)
			disp(thisObj.cellsObj.gnapBar)
			%thisObj.configuration.simParams.simCells.go(); %different copy!!
			thisObj.currentRunStatus='instantiatedAndRunning........';
			thisObj.cellsObj.go();
			thisObj.currentRunStatus='instantiatedAndRan';
		end
		
		function save(thisObj)
			%thisObj.simParamsIDStr=sprintf('%s_%.5f_%s_%.5f_Connectivity_%s',thisObj.currentModifyInfo.overrideParamNames{1},thisObj.currentModifyInfo.overrideParamValues(1),thisObj.currentModifyInfo.overrideParamNames{2},thisObj.currentModifyInfo.overrideParamValues(2), thisObj.internalConnectivityObj.connectivityTypeStr)
			thisObj.simParamsIDStr=sprintf('%s_%.5f_%s_%.5f_Connectivity_%s',thisObj.currentModifyInfo.overrideParamNames{1},thisObj.currentModifyInfo.overrideParamValues(1),thisObj.currentModifyInfo.overrideParamNames{2},thisObj.currentModifyInfo.overrideParamValues(2), thisObj.internalConnectivityObj.connectivityTypeStr)
			saveDir=sprintf(thisObj.configuration.saveDirectoryBaseRawData,thisObj.currentModifyInfo.batchCategory);

			disp(sprintf('saving to: %s.....',saveDir))
			if(~isdir(fullfile(saveDir,thisObj.simParamsIDStr)))
				mkdir(fullfile(saveDir,thisObj.simParamsIDStr))
			end

			%save(fullfile(saveDir,thisObj.simParamsIDStr,'simData.mat'),'thisObj','-v7.3')
			%thisObj.currentSaveStatus='saved';
		end
	
		function visualizeConfig(thisObj,figH)
                        if(exist('figH'))
                                figure(figH)
                        else
                                figure
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

                        xlim([0 1.5])
                        ylim([0 0.15])

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


		
		function dispV_traces(thisObj,figH)
			if(exist('figH'))
				figure(figH)
			else
				figure
			end
			nr=thisObj.configuration.simParams.numCellsPerPlace;
			nc=thisObj.configuration.simParams.numPlaces;

			timeAxis=thisObj.configuration.simParams.timeAxis;

			count=0;
			axHs=[];

			%cmap=jet(nc);
			cmap=copper(nc);
			for r=1:nr
				for c=1:nc
					count=count+1;
					
					%axH=subplot(nr,nc,count);
					plot(timeAxis/1000,squeeze(thisObj.cellsObj.v(r,c,:)),'Color',cmap(c,:))
					%title(thisObj.configuration.simParams.simCells.getCellIDstr(r,c))
					xlabel('Time (sec)')
					ylabel('V_m (mV)')
				
					hold on	
					%axHs=[axHs axH];
					if(r==1)
						%title(sprintf('Place %d',c))
					end
				end
			end

			%linkaxes(axHs,'xy')
			xlim([timeAxis(1) timeAxis(end)]/1000)
			ylim([-80 10])
			title(removeUnderscores(thisObj.simParamsIDStr))
			uberTitle('Place cell networks')
			%maxFigManual2d(1,1,10)	
			maxFigManual2d(3,1,14)
		end
	end

	methods(Access=private)
		function modifyParams(thisObj)
			currentModifyInfo=thisObj.currentModifyInfo;

			paramName1=currentModifyInfo.overrideParamNames{1};
			paramName2=currentModifyInfo.overrideParamNames{2};
			
			paramValue1=currentModifyInfo.overrideParamValues(1);
			paramValue2=currentModifyInfo.overrideParamValues(2);

			thisObj.(currentModifyInfo.modifiedObjName1).(paramName1)=paramValue1;	
			thisObj.(currentModifyInfo.modifiedObjName2).(paramName2)=paramValue2;
		end
	end

end
