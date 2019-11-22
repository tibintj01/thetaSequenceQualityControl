classdef SimPhaseCodingEvaluation < handle & matlab.mixin.Copyable
	%encapsulate data and actions of analysis to keep my interface and implementation details separate
	properties(Constant)
		%useDelayedSpikeTimes=1;
		useDelayedSpikeTimes=0;
	end

	properties
		%simObj
		spikingDataInterface

		%multiple data points per cell objects 
		%allSpikePhasesDataHolder
		%allPeakPhasesDataHolder
		%single data point per cell objects
		%entryPhaseDataHolder
		%placeFieldWidthDataHolder

		cycleSeqTimeSlopes
		cycleSeqTimeOffsets
		cycleRunningSpeeds
		cycleDIs
		cycleCodingStrategy

		cycleL2PeakResponses
		cycleL2UndelayedPeakResponses
		cyclePositions
		
		cyclePeakResponsePhases

		%l2MaxResponseObj		
        
        	tempEncodingDistr

		placeColors
		axisPosition

		cycleStartTimes
	end

	methods
		function thisObj=SimPhaseCodingEvaluation(simObj,delayStageNum)
			%thisObj.figureNum=codingEvalParams.figureNum;
		       	if(nargin==1 || nargin==2)	
				%simObj=simObj;
			
				cmap=copper(simObj.configuration.simParams.numPlaces);
				thisObj.placeColors=cmap;
		
				if(ThetaPopInput.amplitudeDefault>0)	
					thisObj.spikingDataInterface=copy(SpikingDataInterface(simObj,delayStageNum));					
					thisObj.cycleStartTimes=simObj.thetaPopInputObj.getTroughTimes(1,1);
				end

				thisObj.setThetaSeqTimeSlopes(simObj);
				thisObj.setL2responseAnalysis(simObj);
			end
		end

		function setL2responseAnalysis(thisObj,simObj)
			%store association between speed/DI/encoding style and L2 cell response properties
			numCycles=length(thisObj.cycleStartTimes);

			l2Delayed_V=simObj.cellsObj.vL2(1,:);
			l2Undelayed_V=simObj.cellsObj.vInt(1,:);
			
			dt=simObj.configuration.simParams.dt;
			
			cycleL2PeakResponses=NaN(numCycles,1);
			cycleL2UndelayedPeakResponses=NaN(numCycles,1);
			cyclePositions=NaN(numCycles,1);
			cycleL2PeakResponsePhases=NaN(numCycles,1);
			cycleL2UndelayedPeakResponsePhases=NaN(numCycles,1);
		
			for c=1:(numCycles-1)
				currCycleStartTime=thisObj.cycleStartTimes(c);
				currCycleEndTime=thisObj.cycleStartTimes(c+1);
				
				currCycleStartIdx=round(currCycleStartTime/dt);
				currCycleEndIdx=round(currCycleEndTime/dt);

				currL2Delayed_Snippet=l2Delayed_V(currCycleStartIdx:currCycleEndIdx);	
				currL2Undelayed_Snippet=l2Undelayed_V(currCycleStartIdx:currCycleEndIdx);	
			
				%[snippetPeaks,locs]=findpeaks(currL2Delayed_Snippet);
				%[maxL2,delayIdx]=max(snippetPeaks);
				[maxL2,delayIdx]=max(currL2Delayed_Snippet);
				cycleL2PeakResponses(c)=maxL2;

				%cycleL2PeakResponsePhases(c)=(locs(delayIdx)/length(snippetPeaks))*360;
				cycleL2PeakResponsePhases(c)=((delayIdx)/length(currL2Delayed_Snippet))*360;

				%[snippetPeaks,locs]=findpeaks(currL2Undelayed_Snippet);
				%[maxL2,undelayIdx]=max(snippetPeaks);
				[maxL2u,undelayIdx]=max(currL2Undelayed_Snippet);
				cycleL2UndelayedPeakResponses(c)=maxL2u;
				
				%cycleL2UndelayedPeakResponsePhases(c)=(locs(undelayIdx)/length(snippetPeaks))*360;
				cycleL2UndelayedPeakResponsePhases(c)=((undelayIdx)/length(currL2Undelayed_Snippet))*360;

				
				
				midCycleIdx=round((currCycleStartIdx+currCycleEndIdx)/2);
				cyclePositions(c)=simObj.externalEnvObj.rodentPositionVsTime(midCycleIdx);
			end	

			%get theta cycle time windows to extract L2 response properties
			thisObj.cycleL2PeakResponses=cycleL2PeakResponses;
			thisObj.cycleL2UndelayedPeakResponses=cycleL2UndelayedPeakResponses;


			thisObj.cyclePositions=cyclePositions;
		end

		function [fThetaSeq]=setThetaSeqTimeSlopes(thisObj,simObj)
			spikingData=thisObj.spikingDataInterface;
            cycleStartTimes=simObj.thetaPopInputObj.getTroughTimes(1,1);
            
            thetaCycleDuration=1/(simObj.thetaPopInputObj.frequency);

			cycleFirstPhasesMatrix=spikingData.firstSpikePhasePerCellPerCycle;
			numCycles=spikingData.numCycles(1,1);
			thetaSeqTimeSlopes=NaN(numCycles,1);		
			thetaSeqTimeOffsets=NaN(numCycles,1);
        fThetaSeq=figure; 
            cycleColorMap=copper(numCycles)
            colormap(gca,cycleColorMap)
            
			for c=1:numCycles	
				%currCycleFirstSpikeTimes=cycleSpikeSequences.(sprintf('cycle%d',c));
				currCycleFirstSpikePhases=cycleFirstPhasesMatrix(:,:,c);
				currCycleFirstSpikePhasesPerPlace=nanmean(currCycleFirstSpikePhases,1);
				placeSequence=double(~isnan(currCycleFirstSpikePhasesPerPlace));
				currCycleFirstSpikePhasesPerPlace=currCycleFirstSpikePhasesPerPlace(~isnan(currCycleFirstSpikePhasesPerPlace));
	
				dendriticTemplateMatrix=simObj.cellsObj.feedforwardConnObj.dendriticDelayTemplateMatrix;
				dendriticTemplateISIs=diag(fliplr(dendriticTemplateMatrix));
                %dendriticTemplateRelativeTimes=cumsum(dendriticTemplateISIs(end:-1:1));
                %dendriticTemplateRelativeTimes=(dendriticTemplateISIs(end:-1:1));
                %dendriticTemplateRelativeTimes=(dendriticTemplateISIs);
                dendriticTemplateRelativeTimes=(thetaCycleDuration-dendriticTemplateISIs);
				dendriticTemplateRelativeTimes=dendriticTemplateRelativeTimes-min(dendriticTemplateRelativeTimes);
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
				%store theta sequence time slope per cycle
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
                
				 for currCol=1:size(placeSequence,2)
                                         placeSequence(:,currCol)=placeSequence(:,currCol)*currCol;
                                 end
					%placeSequence=double(~isnan(currCycleFirstSpikePhases));
					%for currCol=1:size(placeSequence,2)
					%	placeSequence(:,currCol)=placeSequence(:,currCol)*currCol;
					%end
					%currCycleFirstSpikePhases=currCycleFirstSpikePhases(~isnan(currCycleFirstSpikePhases));
					placeSequence=placeSequence(placeSequence~=0);
                    		placeSequence=placeSequence-min(placeSequence)+1;
				%currCycleFirstSpikePhases=currCycleFirstSpikePhases(~isnan(currCycleFirstSpikePhases))
				%currCycleFirstSpikePhases=sort(currCycleFirstSpikePhases);
				%if(length(currCycleFirstSpikePhases)>3)
				if(length(currCycleFirstSpikePhasesPerPlace)>1)
					%[m,b,R]=getLinearFit(1:length(currCycleFirstSpikePhases),currCycleFirstSpikePhases);
					%[m,b,R]=getLinearFit(placeSequence,currCycleFirstSpikePhases);
					%[m,b,R]=getLinearFit(placeSequence,currCycleFirstSpikePhasesPerPlace);
					%zeroedThetaSeqSpikes=currCycleFirstSpikePhasesPerPlace-currCycleFirstSpikePhasesPerPlace(1);
					%zeroedThetaSeqSpikes=currCycleFirstSpikePhasesPerPlace-min(currCycleFirstSpikePhasesPerPlace);
                    if(c>1)
                        zeroedThetaSeqSpikes=(c-1)*thetaCycleDuration+(currCycleFirstSpikePhasesPerPlace)/360*thetaCycleDuration-cycleStartTimes(c-1);
                    else
                        zeroedThetaSeqSpikes=(c-1)*thetaCycleDuration+(currCycleFirstSpikePhasesPerPlace)/360*thetaCycleDuration;
		    end
                        zeroedThetaSeqSpikes=zeroedThetaSeqSpikes-min(zeroedThetaSeqSpikes);

					[m,b,R]=getLinearFit(zeroedThetaSeqSpikes,placeSequence);
					%figure; plot(placeSequence,currCycleFirstSpikePhases,'b*')
                    figure(fThetaSeq)
				
					plot(zeroedThetaSeqSpikes,placeSequence,'-','Color',cycleColorMap(c,:),'LineWidth',3)
					%plot(currCycleFirstSpikePhasesPerPlace,placeSequence,'-','Color',cycleColorMap(c,:),'LineWidth',3)
					hold on
                    plot(zeroedThetaSeqSpikes,placeSequence,'o','Color',cycleColorMap(c,:))
				
					maxDendDelay=max(dendriticTemplateRelativeTimes);
					plot(dendriticTemplateRelativeTimes,1:length(dendriticTemplateRelativeTimes),'b-','LineWidth',5);%per seconds
                		       plot(dendriticTemplateRelativeTimes,1:length(dendriticTemplateRelativeTimes),'bo');
                 
					thetaSeqTimeOffsets(c)=b;%per seconds
				end
            end
            colorbar(gca)
	
			xlim([0 100])
			
			ylabel('place rank')
			xlabel('Time from spike to end of theta cycle')
			%STOP
			thisObj.cycleSeqTimeSlopes=thetaSeqTimeSlopes;
			thisObj.cycleSeqTimeOffsets=thetaSeqTimeOffsets;
			thisObj.cycleRunningSpeeds=ExternalEnvironment.CONSTANT_RUN_SPEED*ones(size(thetaSeqTimeSlopes));
			thisObj.cycleDIs=CurrentInjectors.DI_SORTED_PERM_RANK*ones(size(thetaSeqTimeSlopes));
			thisObj.cycleCodingStrategy=FeedForwardConnectivity.USE_LINEAR_DELAYS*ones(size(thetaSeqTimeSlopes));
		end	
	
		%function run(thisObj,figH)
		%	thisObj.visualizePhaseCoding(figH);
		%end
		function runPlotRaster(thisObj,simObj,figH)
			thisObj.plotRaster(simObj,figH);
		end
		
		function runPlotRasterSingleDelayed(thisObj,simObj,figH)
			thisObj.plotRasterSingleDelayed(simObj,figH);
		end
		
		function runPlotRasterDoubleDelayed(thisObj,simObj,figH)
			thisObj.plotRasterDoubleDelayed(simObj,figH);
		end

		function runRankTransformAnalysis(thisObj,simObj,figH)
			if(ThetaPopInput.amplitudeDefault>0)
				thisObj.plotSpikeRankVsPosRank(simObj,figH);
			end 	
		end
		
		function runPhaseCodeAnalysis(thisObj,simObj,figPrecess,figCompress)
			if(ThetaPopInput.amplitudeDefault>0)
				thisObj.plotPhaseVsPositionInField(simObj,figPrecess,figCompress);
			end
		end
		
		function runSpikeTimeDistributionAnalysis(thisObj,simObj,figH)
			if(ThetaPopInput.amplitudeDefault>0)
				thisObj.plotSpikePhaseDistrPerCycle(simObj,figH);
			else
				thisObj.plotAllSpikePhaseDistr(simObj,figH)
			end
		end

		%function visualizePhaseCoding(thisObj,simObj,figH)
		%	thisObj.plotRaster(figH)
			%thisObj.plotPhaseVsPositionInField();
		%	thisObj.plotSpikeRankVsPosRank();	
			%thisObj.plotLocalSpikePhaseSlopeVsLocalSpeed();
			%range of possible phase slopes decreased by synaptic strength but increased by intrinsics? 	
			%plot repeated trials for same cell - theta phase consistency given jitter
		%end
	end

	methods(Access = private)
		%{
		function analyzePhase
		end
		function sequenceQualityMeasures=getSequenceQualityMeasures(thisObj)
		end
		%}

		function plotRaster(thisObj,simObj,figH)
			figure(figH)
			%spike times per cell
			%if(SimPhaseCodingEvaluation.useDelayedSpikeTimes==1)
			%	spikeTimes=simObj.cellsObj.delayedSpikeTimes;
			%else
				%spikeTimes=simObj.cellsObj.spikeTimes;
				spikeTimes=thisObj.spikingDataInterface.spikeTimes;
			%end
			spikeCellCoords=simObj.cellsObj.spikeCellCoords;
			numCellsPerPlace=simObj.configuration.simParams.numCellsPerPlace;
	
			for i=1:length(spikeTimes)
				currSpikePlaceIdx=spikeCellCoords(i,2);
				currSpikeCellIdx=spikeCellCoords(i,1);
				cellRasterRow=(currSpikePlaceIdx-1)*numCellsPerPlace+currSpikeCellIdx;
				plot([spikeTimes(i) spikeTimes(i)],[cellRasterRow-1 cellRasterRow],'-','Color',thisObj.placeColors(currSpikePlaceIdx,:),'LineWidth',3)
				hold on 
			end		

			%ASSUMES POPULATION WIDE SYNCHRONOUS THETA
			simObj.thetaPopInputObj.addTroughLines(figH)

			%{
			thetaTroughTimes=simObj.thetaPopInputObj.getTroughTimes(1,1);
			
			currYlim=ylim;
			for i=1:length(thetaTroughTimes)
				plot([thetaTroughTimes(i) thetaTroughTimes(i)], currYlim,'Color','b','LineWidth',6)			
			end
			%}
			title(removeUnderscores(simObj.simParamsIDStr))
			%maxFigManual2d(3,1,14)
			xlabel('Time (msec)')	
			ylabel('Cell No.')	
		end

		function plotRasterDoubleDelayed(thisObj,simObj,figH)
			figure(figH)
                        %spike times per cell
                        spikeTimes=simObj.cellsObj.doubleDelayedSpikeTimes;
                        
			spikeCellCoords=simObj.cellsObj.spikeCellCoords;
                        numCellsPerPlace=simObj.configuration.simParams.numCellsPerPlace;

                        for i=1:length(spikeTimes)
                                currSpikePlaceIdx=spikeCellCoords(i,2);
                                currSpikeCellIdx=spikeCellCoords(i,1);
                                cellRasterRow=(currSpikePlaceIdx-1)*numCellsPerPlace+currSpikeCellIdx;
                                plot([spikeTimes(i) spikeTimes(i)],[cellRasterRow-1 cellRasterRow],'-','Color',thisObj.placeColors(currSpikePlaceIdx,:),'LineWidth',3)
                                hold on
                        end

                        %ASSUMES POPULATION WIDE SYNCHRONOUS THETA
                        simObj.thetaPopInputObj.addTroughLines(figH)

                        %{
                        thetaTroughTimes=simObj.thetaPopInputObj.getTroughTimes(1,1);

                        currYlim=ylim;
                        for i=1:length(thetaTroughTimes)
                                plot([thetaTroughTimes(i) thetaTroughTimes(i)], currYlim,'Color','b','LineWidth',6)
                        end
                        %}
                        %title(removeUnderscores(simObj.simParamsIDStr))
			 %maxFigManual2d(3,1,14)
                        xlabel('Time (msec)')
                        ylabel('Cell No.')

		end
		function plotRasterSingleDelayed(thisObj,simObj,figH)
			figure(figH)
                        %spike times per cell
                        spikeTimes=simObj.cellsObj.delayedSpikeTimes;
                        
			spikeCellCoords=simObj.cellsObj.spikeCellCoords;
                        numCellsPerPlace=simObj.configuration.simParams.numCellsPerPlace;

                        for i=1:length(spikeTimes)
                                currSpikePlaceIdx=spikeCellCoords(i,2);
                                currSpikeCellIdx=spikeCellCoords(i,1);
                                cellRasterRow=(currSpikePlaceIdx-1)*numCellsPerPlace+currSpikeCellIdx;
                                plot([spikeTimes(i) spikeTimes(i)],[cellRasterRow-1 cellRasterRow],'-','Color',thisObj.placeColors(currSpikePlaceIdx,:),'LineWidth',3)
                                hold on
                        end

                        %ASSUMES POPULATION WIDE SYNCHRONOUS THETA
                        simObj.thetaPopInputObj.addTroughLines(figH)

                        %{
                        thetaTroughTimes=simObj.thetaPopInputObj.getTroughTimes(1,1);

                        currYlim=ylim;
                        for i=1:length(thetaTroughTimes)
                                plot([thetaTroughTimes(i) thetaTroughTimes(i)], currYlim,'Color','b','LineWidth',6)
                        end
                        %}
                        %title(removeUnderscores(simObj.simParamsIDStr))
                       title('Spikes times seen by CA1 soma')
			 %maxFigManual2d(3,1,14)
                        xlabel('Time (msec)')
			 ylabel('Cell No.')
		end
	
		function plotPhaseVsPositionInField(thisObj,simObj,figPrecess,figCompress)
			%useAllSpikes=1;
			useAllSpikes=0;

			cellsObj=simObj.cellsObj;
			%loop across cells
			count=0;
			axHs=[];
			%cellCmap=jet(simObj.configuration.getNumCells());
			cellCmap=jet(cellsObj.numCellsPerPlace);
			placeCmap=copper(cellsObj.numPlaces);
			speedCmap=jet(round(max(simObj.externalEnvObj.rodentRunningSpeed))+1);

			for j=1:cellsObj.numPlaces
				for i=1:cellsObj.numCellsPerPlace
					count=count+1;
					%axH=subplot(cellsObj.numCellsPerPlace,cellsObj.numPlaces,count)
					
					if(useAllSpikes)
						currCellSpikePhases=thisObj.spikingDataInterface.allSpikePhasesPerCell.(sprintf('c%dp%d',i,j));
						currCellSpikeTimeIdxes=round((thisObj.spikingDataInterface.allSpikeTimesPerCell.(sprintf('c%dp%d',i,j)))/simObj.externalEnvObj.idxToTimeFact)+1;
					else
						currCellSpikePhases=thisObj.spikingDataInterface.firstSpikePhasesPerCell.(sprintf('c%dp%d',i,j));
						currCellSpikeTimeIdxes=round((thisObj.spikingDataInterface.firstSpikeTimesPerCell.(sprintf('c%dp%d',i,j)))/simObj.externalEnvObj.idxToTimeFact)+1;
					end


					currCellSpikePositions=simObj.externalEnvObj.rodentPositionVsTime(currCellSpikeTimeIdxes);
					thisCellInputCenterPos=simObj.externalEnvObj.placeInputStartPositions(j)+simObj.externalEnvObj.placeInputWidths(j)/2;
			
					figure(figCompress)

					currCellSpikeInputRelativePositions=currCellSpikePositions-thisCellInputCenterPos;
					%plot(currCellSpikeInputRelativePositions,currCellSpikePhases,'o','MarkerSize',5,'Color',placeCmap(j,:),'MarkerFaceColor',placeCmap(j,:));
					%linearEstPt=13;
					
					[~,linearEstPt]=min(currCellSpikePhases);
					%linearEstPt=length(currCellSpikePhases);
					%for s=1:length(currCellSpikePhases)
					%for s=1:linearEstPt
						%currSpeed=round(simObj.externalEnvObj.rodentRunningSpeed(currCellSpikeTimeIdxes(s)));
						%plot(currCellSpikeInputRelativePositions,currCellSpikePhases,'o','MarkerSize',5,'Color',speedCmap(currSpeed,:),'MarkerFaceColor',speedCmap(currSpeed,:));
						plot(currCellSpikeInputRelativePositions(1:linearEstPt),currCellSpikePhases(1:linearEstPt),'o','MarkerSize',7,'Color',placeCmap(j,:),'MarkerFaceColor',placeCmap(j,:));
						hold on
						plot(currCellSpikeInputRelativePositions(1:linearEstPt),currCellSpikePhases(1:linearEstPt),'-','LineWidth',2,'Color',placeCmap(j,:))
						%psH(s).Color(4)=(1-s/length(currCellSpikePhases));
					%end
					%plot(xlim,[currCellSpikePhases(1) currCellSpikePhases(end-5)],'r--') 
					%plot([currCellSpikeInputRelativePositions(1) currCellSpikeInputRelativePositions(linearEstPt)],[currCellSpikePhases(1) currCellSpikePhases(linearEstPt)],'r--') 
					ylim([140 360])
					distLimHalf=ExternalEnvironment.PLACE_INPUT_WIDTH/2;
					xlim([-distLimHalf distLimHalf*1.5])
				
					xlabel('Distance from place input center (cm)')
					if(useAllSpikes)
						ylabel('spike theta phase (degrees)')
					else
						ylabel('Phase of first spike in cycle (degrees)')
					end
					hold on
					%percent traveled within input field (not observable extracellularly)
					%{
					currCellPlaceInputStartPosition=simObj.externalEnvObj.placeInputStartPositions(j);
					currCellPlaceInputWidth=simObj.externalEnvObj.placeInputWidths(j)
					percPlaceInputTraveled=100*(currCellSpikePositions-currCellPlaceInputStartPosition)/currCellPlaceInputWidth;
					%plot(percPlaceInputTraveled,currCellSpikePhases,'o','MarkerSize',8,'Color',cellCmap(count,:),'MarkerFaceColor',cellCmap(count,:))
					plot(percPlaceInputTraveled,currCellSpikePhases,'o','MarkerSize',8,'Color',placeCmap(count,:),'MarkerFaceColor',placeCmap(count,:))
					%}
					figure(figPrecess)

					%percent traveled within spike field (EC observable)
					if(~isempty(currCellSpikePositions))
						currCellPlaceSpikeFieldWidth=currCellSpikePositions(end)-currCellSpikePositions(1);
						percPlaceFieldTraveled=100*(currCellSpikePositions-currCellSpikePositions(1))/currCellPlaceSpikeFieldWidth;
						%plot(percPlaceFieldTraveled,currCellSpikePhases,'o','MarkerSize',8,'Color',cellCmap(i,:),'MarkerFaceColor',cellCmap(i,:))
						plot(percPlaceFieldTraveled,currCellSpikePhases,'o','MarkerSize',8,'Color',placeCmap(j,:),'MarkerFaceColor',placeCmap(j,:))
						hold on			
					else
						currCellPlaceSpikeFieldWidth=NaN;
						percPlaceFieldTraveled=NaN;
					end
					ylim([140 360])
					xlim([0 100])
					xlabel('Percent of field traveled')
					if(useAllSpikes)
                                                ylabel('spike theta phase')
                                        else
						ylabel('Phase of first spike in cycle (degrees)')
                                                %ylabel('First spike theta phase')
                                        end					
					%plot(percPlaceFieldTraveled,currCellSpikePhases,'o','MarkerSize',8,'Color',cellCmap(count,:),'MarkerFaceColor',cellCmap(count,:))
					%plot(percPlaceInputTraveled,currCellSpikePhases,'o','MarkerSize',8,'Color',cellCmap(count,:))
					%axHs=[axHs axH];
				end
			end
	
			%maxFigManual2d(3,1,18)
			%linkaxes(axHs,'xy')
			figure(figCompress)
			%xlim([0 100])
			%ylim([0 360])
			%ylim([0 260])
			cb=colorbar()
			%set(cb,'Ylim',[1 count])
			%cmap =cellCmap; %get current colormap
			cmap =placeCmap; %get current colormap
			%cmap=cmap([1 count],:); % set your range here
			colormap(gca,cmap); % apply new colormap
			placeIdxes=1:(cellsObj.numPlaces);
			cb=colorbar('XTickLabel',cellstr(int2str(placeIdxes(:))),'XTick',placeIdxes/cellsObj.numPlaces-0.05);
			ylabel(cb,'Cell input place rank')
			%xlabel('Percent of field traversed')	
			%ylabel('Spike theta phase')
			title(removeUnderscores(simObj.simParamsIDStr))	

			figure(figCompress)
			%cmap=speedCmap;
			%colormap(gca,cmap)
			%cbDist=colorbar('Ticks',[0 0.25 0.5 0.75 1],'TickLabels',{'0',sprintf('%d',(size(speedCmap,1)-1)/4),sprintf('%d',(size(speedCmap,1)-1)/2),sprintf('%d',3*(size(speedCmap,1)-1)/4),sprintf('%d',(size(speedCmap,1)-1))});
			
			%ylabel(cbDist,'Speed (cm/s)')
				
			%yticks(cbDist,[0 0.5 1])
			%yticklabels(cbDist,{'0',sprintf('%d',(size(speedCmap,1)-1)/2),sprintf('%d',(size(speedCmap,1)-1))})
			%cmap =placeCmap; %get current colormap
                        %cmap=cmap([1 count],:); % set your range here
                        %colormap(cmap); % apply new colormap
                        %cb=colorbar();
			%cbDist.Limits=[1 size(speedCmap,1)]
		end

		function plotSpikeRankVsPosRank(thisObj,simObj,figH)
                	numPlaces=simObj.cellsObj.numPlaces;  
                	numCellsPerPlace=simObj.cellsObj.numCellsPerPlace;
  
		      	figure(figH)
                        cellsObj=simObj.cellsObj;
                        %loop across cells
                        count=0;
                        axHs=[];
                        %for i=1:cellsObj.numCellsPerPlace
                        %        for j=1:cellsObj.numPlaces
					numCycles=length(simObj.thetaPopInputObj.getTroughTimes(1,1));
					numCellsTotal=simObj.configuration.getNumCells();

					cellSequencePerCycle=NaN(numCycles,numCellsTotal);
					thetaCmap=jet(numCycles);
					rankMapCount=zeros(numCellsTotal,numCellsTotal);

					totalMapCountPerCycle=NaN(numCycles,1);

					for c=1:numCycles
						count=count+1;
						%axH=subplot(5,5,count)
						cellSeqFirstSpikes=thisObj.spikingDataInterface.cellSequencePerCycleFirstSpikes.(sprintf('cycle%d',c));				
						
						if(~isempty(cellSeqFirstSpikes))
							linearCellIndicesInCycle=[];
							for r=1:size(cellSeqFirstSpikes,1)
								linIdx=sub2ind([numCellsPerPlace numPlaces],cellSeqFirstSpikes(r,1),cellSeqFirstSpikes(r,2));
								linearCellIndicesInCycle=[linearCellIndicesInCycle linIdx];
							end
							%theta cycle could only know relative ordering of participants
							linearCellIndicesInCycle=linearCellIndicesInCycle-min(linearCellIndicesInCycle)+1;
							
							wellOrderedSequence=sort(linearCellIndicesInCycle);
							
	
							%cellSequencePerCycle(c,wellOrderedSequence)=linearCellIndicesInCycle;
							cellSequencePerCycle(c,wellOrderedSequence)=linearCellIndicesInCycle;
					
							for i=1:length(wellOrderedSequence)
								rankMapCount(wellOrderedSequence(i),linearCellIndicesInCycle(i))=rankMapCount(wellOrderedSequence(i),linearCellIndicesInCycle(i))+1;
								%rankMapCount(wellOrderedSequence(i),linearCellIndicesInCycle(i))=rankMapCount(wellOrderedSequence(i),linearCellIndicesInCycle(i))+1/length(wellOrderedSequence);
							end
						end

						%totalMapCountPerCycle(c)=length(wellOrderedSequence);
					end 
					%each place comparison might be divided by the total number of cycles the two cell populations
					%are co-active
                    			thisObj.tempEncodingDistr=rankMapCount;
					totalNumMappings=sum(rankMapCount(:));
					omarPcolor(1:numCellsTotal,1:numCellsTotal,rankMapCount/totalNumMappings,figH)
					%omarPcolor(1:numCellsTotal,1:numCellsTotal,rankMapCount,figH)
					shading flat
					xlabel('Place rank')
					ylabel('Theta sequence rank')
					cb=colorbar
					%ylabel(cb,'Theta cycle no.')
					%ylabel(cb,'Proportion of mappings within cycle')
					ylabel(cb,'Probability')
                    if(prctile(rankMapCount(:)/totalNumMappings,99)>0)
                        caxis([0 prctile(rankMapCount(:)/totalNumMappings,99)])
                    end
                        		title(removeUnderscores(simObj.simParamsIDStr))
					grid on
					xticks(1:cellsObj.numCellsPerPlace:numCellsTotal)
					yticks(1:cellsObj.numCellsPerPlace:numCellsTotal)
					daspect([1 1 1])
			 	        ax=gca;
					 ax.GridAlpha=1;
					set(ax,'layer','top')
					ax.GridColor='w';
					ax.LineWidth=3;

					xticklabels(string([1:cellsObj.numPlaces]))
					yticklabels(string([1:cellsObj.numPlaces]))
					 %axHs=[axHs axH];
                          %      end
                       % end
                end
		
		function plotAllSpikePhaseDistr(thisObj,simObj,figH)

			figure(figH)
                        %spike times per cell
                        spikeTimes=simObj.cellsObj.spikeTimes;
                        spikeCellCoords=simObj.cellsObj.spikeCellCoords;
                        numCellsPerPlace=simObj.configuration.simParams.numCellsPerPlace;

			numPlaces=simObj.cellsObj.numPlaces;

			%spikeTimesByPlace={};
			
                                 for p=1:numPlaces
					spikeTimesByPlace{p}=NaN;
				 end
                        for i=1:length(spikeTimes)
                                currSpikePlaceIdx=spikeCellCoords(i,2);
                                currSpikeCellIdx=spikeCellCoords(i,1);
                                cellRasterRow=(currSpikePlaceIdx-1)*numCellsPerPlace+currSpikeCellIdx;
                                spikeTimesByPlace{currSpikePlaceIdx}=[spikeTimesByPlace{currSpikePlaceIdx}; spikeTimes(i)];
	
				%plot([spikeTimes(i) spikeTimes(i)],[cellRasterRow-1 cellRasterRow],'-','Color',thisObj.placeColors(currSpikePlaceIdx,:),'LineWidth',1)
                                %hold on
                        end

			placeCmap=copper(numPlaces);

			binSize=50; %msec
			edges=0:binSize:simObj.configuration.simParams.simTime;
				for p=1:numPlaces
					[counts,edges]=histcounts(spikeTimesByPlace{p},edges);
					plot(edgesToBins(edges),counts,'Color',placeCmap(p,:),'LineWidth',2)
					hold on
				end
			

		end

		function plotSpikePhaseDistrPerCycle(thisObj,simObj,figH)
			figure(figH)
                        cellsObj=simObj.cellsObj;
                        %loop across cells
                        count=0;
                        axHs=[];
                        cellCmap=jet(simObj.configuration.getNumCells());
			numCycles=length(simObj.thetaPopInputObj.getTroughTimes(1,1));
			numPlaces=simObj.cellsObj.numPlaces;
		
			numBins=20;	
			binEdges=linspace(0,360,numBins+1);

			spikePhaseDistrPerCycle=NaN(numPlaces,(length(binEdges)-1)*numCycles);
			phaseAxis=[];

			placeCmap=copper(numPlaces);

			for c=1:numCycles
				for j=1:cellsObj.numPlaces
					spikePhasesThesePlaceCellsThisCycle=[];
					for i=1:cellsObj.numCellsPerPlace
						currCellSpikePhases=thisObj.spikingDataInterface.allSpikePhasesPerCellPerCycle.(sprintf('c%dp%dcy%d',i,j,c));	
						spikePhasesThesePlaceCellsThisCycle=[spikePhasesThesePlaceCellsThisCycle; currCellSpikePhases(:) ];
					end
					[phaseCounts,phaseEdges]=histcounts(spikePhasesThesePlaceCellsThisCycle,binEdges);		
					startIdx=(c-1)*length(phaseCounts)+1;
					endIdx=(c)*length(phaseCounts);
					
					spikePhaseDistrPerCycle(j,startIdx:endIdx)=phaseCounts;
				end
					%phaseAxis=[phaseAxis edgesToBins(phaseEdges)]; 
			end

			troughTimes=simObj.thetaPopInputObj.getTroughTimes(1,1);
			firstCycleStartTime=troughTimes(1);
			lastCycleStartTime=troughTimes(end);
			binToTimeFact=(lastCycleStartTime-firstCycleStartTime)/((numCycles-1)*numBins);
			%endTime=
			for j=1:cellsObj.numPlaces
				plot((1:size(spikePhaseDistrPerCycle,2))*binToTimeFact+firstCycleStartTime,spikePhaseDistrPerCycle(j,:),'-','Color',placeCmap(j,:),'LineWidth',2)
				hold on
			end
			xlim([0 simObj.configuration.simParams.simTime])
			ylim([0 max(spikePhaseDistrPerCycle(:))])
			xlabel('Time (msec)')
			ylabel('Count')
			%omarPcolor(1:size(spikePhaseDistrPerCycle,2),1:numPlaces,spikePhaseDistrPerCycle,figH)
			%colorbar
			%shading flat
		end
	end
end
