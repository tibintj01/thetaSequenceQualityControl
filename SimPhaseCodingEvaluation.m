classdef SimPhaseCodingEvaluation < handle & matlab.mixin.Copyable
	%encapsulate data and actions of analysis to keep my interface and implementation details separate
	properties(Constant)
		%useDelayedSpikeTimes=1;
		useDelayedSpikeTimes=0;
	end

	properties
		simObj
		spikingDataInterface

		%multiple data points per cell objects 
		%allSpikePhasesDataHolder
		%allPeakPhasesDataHolder
		%single data point per cell objects
		%entryPhaseDataHolder
		%placeFieldWidthDataHolder
        
        	tempEncodingDistr

		placeColors
		axisPosition
	end

	methods
		function thisObj=SimPhaseCodingEvaluation(simObj)
			%thisObj.figureNum=codingEvalParams.figureNum;
		       	if(nargin==1)	
				thisObj.simObj=simObj;
			
				cmap=copper(simObj.configuration.simParams.numPlaces);
				thisObj.placeColors=cmap;
		
				if(ThetaPopInput.amplitudeDefault>0)	
					thisObj.spikingDataInterface=copy(SpikingDataInterface(thisObj.simObj));					
				end
			end
		end
		
		%function run(thisObj,figH)
		%	thisObj.visualizePhaseCoding(figH);
		%end
		function runPlotRaster(thisObj,figH)
			thisObj.plotRaster(figH);
		end
		
		function runPlotRasterSingleDelayed(thisObj,figH)
			thisObj.plotRasterSingleDelayed(figH);
		end
		
		function runPlotRasterDoubleDelayed(thisObj,figH)
			thisObj.plotRasterDoubleDelayed(figH);
		end

		function runRankTransformAnalysis(thisObj,figH)
			if(ThetaPopInput.amplitudeDefault>0)
				thisObj.plotSpikeRankVsPosRank(figH);
			end 	
		end
		
		function runPhaseCodeAnalysis(thisObj,figPrecess,figCompress)
			if(ThetaPopInput.amplitudeDefault>0)
				thisObj.plotPhaseVsPositionInField(figPrecess,figCompress);
			end
		end
		
		function runSpikeTimeDistributionAnalysis(thisObj,figH)
			if(ThetaPopInput.amplitudeDefault>0)
				thisObj.plotSpikePhaseDistrPerCycle(figH);
			else
				thisObj.plotAllSpikePhaseDistr(figH)
			end
		end

		%function visualizePhaseCoding(thisObj,figH)
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

		function plotRaster(thisObj,figH)
			figure(figH)
			%spike times per cell
			if(SimPhaseCodingEvaluation.useDelayedSpikeTimes==1)
				spikeTimes=thisObj.simObj.cellsObj.delayedSpikeTimes;
			else
				spikeTimes=thisObj.simObj.cellsObj.spikeTimes;
			end
			spikeCellCoords=thisObj.simObj.cellsObj.spikeCellCoords;
			numCellsPerPlace=thisObj.simObj.configuration.simParams.numCellsPerPlace;
	
			for i=1:length(spikeTimes)
				currSpikePlaceIdx=spikeCellCoords(i,2);
				currSpikeCellIdx=spikeCellCoords(i,1);
				cellRasterRow=(currSpikePlaceIdx-1)*numCellsPerPlace+currSpikeCellIdx;
				plot([spikeTimes(i) spikeTimes(i)],[cellRasterRow-1 cellRasterRow],'-','Color',thisObj.placeColors(currSpikePlaceIdx,:),'LineWidth',3)
				hold on 
			end		

			%ASSUMES POPULATION WIDE SYNCHRONOUS THETA
			thisObj.simObj.thetaPopInputObj.addTroughLines(figH)

			%{
			thetaTroughTimes=thisObj.simObj.thetaPopInputObj.getTroughTimes(1,1);
			
			currYlim=ylim;
			for i=1:length(thetaTroughTimes)
				plot([thetaTroughTimes(i) thetaTroughTimes(i)], currYlim,'Color','b','LineWidth',6)			
			end
			%}
			title(removeUnderscores(thisObj.simObj.simParamsIDStr))
			%maxFigManual2d(3,1,14)
			xlabel('Time (msec)')	
			ylabel('Cell No.')	
		end

		function plotRasterDoubleDelayed(thisObj,figH)
			figure(figH)
                        %spike times per cell
                        spikeTimes=thisObj.simObj.cellsObj.doubleDelayedSpikeTimes;
                        
			spikeCellCoords=thisObj.simObj.cellsObj.spikeCellCoords;
                        numCellsPerPlace=thisObj.simObj.configuration.simParams.numCellsPerPlace;

                        for i=1:length(spikeTimes)
                                currSpikePlaceIdx=spikeCellCoords(i,2);
                                currSpikeCellIdx=spikeCellCoords(i,1);
                                cellRasterRow=(currSpikePlaceIdx-1)*numCellsPerPlace+currSpikeCellIdx;
                                plot([spikeTimes(i) spikeTimes(i)],[cellRasterRow-1 cellRasterRow],'-','Color',thisObj.placeColors(currSpikePlaceIdx,:),'LineWidth',3)
                                hold on
                        end

                        %ASSUMES POPULATION WIDE SYNCHRONOUS THETA
                        thisObj.simObj.thetaPopInputObj.addTroughLines(figH)

                        %{
                        thetaTroughTimes=thisObj.simObj.thetaPopInputObj.getTroughTimes(1,1);

                        currYlim=ylim;
                        for i=1:length(thetaTroughTimes)
                                plot([thetaTroughTimes(i) thetaTroughTimes(i)], currYlim,'Color','b','LineWidth',6)
                        end
                        %}
                        %title(removeUnderscores(thisObj.simObj.simParamsIDStr))
                       title('Spikes times seen by CA1 soma')
			 %maxFigManual2d(3,1,14)
                        xlabel('Time (msec)')
                        ylabel('Cell No.')

		end
		function plotRasterSingleDelayed(thisObj,figH)
			figure(figH)
                        %spike times per cell
                        spikeTimes=thisObj.simObj.cellsObj.delayedSpikeTimes;
                        
			spikeCellCoords=thisObj.simObj.cellsObj.spikeCellCoords;
                        numCellsPerPlace=thisObj.simObj.configuration.simParams.numCellsPerPlace;

                        for i=1:length(spikeTimes)
                                currSpikePlaceIdx=spikeCellCoords(i,2);
                                currSpikeCellIdx=spikeCellCoords(i,1);
                                cellRasterRow=(currSpikePlaceIdx-1)*numCellsPerPlace+currSpikeCellIdx;
                                plot([spikeTimes(i) spikeTimes(i)],[cellRasterRow-1 cellRasterRow],'-','Color',thisObj.placeColors(currSpikePlaceIdx,:),'LineWidth',3)
                                hold on
                        end

                        %ASSUMES POPULATION WIDE SYNCHRONOUS THETA
                        thisObj.simObj.thetaPopInputObj.addTroughLines(figH)

                        %{
                        thetaTroughTimes=thisObj.simObj.thetaPopInputObj.getTroughTimes(1,1);

                        currYlim=ylim;
                        for i=1:length(thetaTroughTimes)
                                plot([thetaTroughTimes(i) thetaTroughTimes(i)], currYlim,'Color','b','LineWidth',6)
                        end
                        %}
                        %title(removeUnderscores(thisObj.simObj.simParamsIDStr))
                       title('Spikes times seen by CA1 soma')
			 %maxFigManual2d(3,1,14)
                        xlabel('Time (msec)')
			 ylabel('Cell No.')
		end
	
		function plotPhaseVsPositionInField(thisObj,figPrecess,figCompress)
			useAllSpikes=1;

			cellsObj=thisObj.simObj.cellsObj;
			%loop across cells
			count=0;
			axHs=[];
			%cellCmap=jet(thisObj.simObj.configuration.getNumCells());
			cellCmap=jet(cellsObj.numCellsPerPlace);
			placeCmap=copper(cellsObj.numPlaces);
			speedCmap=jet(round(max(thisObj.simObj.externalEnvObj.rodentRunningSpeed))+1);

			for j=1:cellsObj.numPlaces
				for i=1:cellsObj.numCellsPerPlace
					count=count+1;
					%axH=subplot(cellsObj.numCellsPerPlace,cellsObj.numPlaces,count)
					
					if(useAllSpikes)
						currCellSpikePhases=thisObj.spikingDataInterface.allSpikePhasesPerCell.(sprintf('c%dp%d',i,j));
						currCellSpikeTimeIdxes=round((thisObj.spikingDataInterface.allSpikeTimesPerCell.(sprintf('c%dp%d',i,j)))/thisObj.simObj.externalEnvObj.idxToTimeFact)+1;
					else
						currCellSpikePhases=thisObj.spikingDataInterface.firstSpikePhasesPerCell.(sprintf('c%dp%d',i,j));
						currCellSpikeTimeIdxes=round((thisObj.spikingDataInterface.firstSpikeTimesPerCell.(sprintf('c%dp%d',i,j)))/thisObj.simObj.externalEnvObj.idxToTimeFact)+1;
					end


					currCellSpikePositions=thisObj.simObj.externalEnvObj.rodentPositionVsTime(currCellSpikeTimeIdxes);
					thisCellInputCenterPos=thisObj.simObj.externalEnvObj.placeInputStartPositions(j)+thisObj.simObj.externalEnvObj.placeInputWidths(j)/2;
			
					figure(figCompress)

					currCellSpikeInputRelativePositions=currCellSpikePositions-thisCellInputCenterPos;
					%plot(currCellSpikeInputRelativePositions,currCellSpikePhases,'o','MarkerSize',5,'Color',placeCmap(j,:),'MarkerFaceColor',placeCmap(j,:));
					for s=1:length(currCellSpikePhases)
						currSpeed=round(thisObj.simObj.externalEnvObj.rodentRunningSpeed(currCellSpikeTimeIdxes(s)));
						plot(currCellSpikeInputRelativePositions,currCellSpikePhases,'o','MarkerSize',5,'Color',speedCmap(currSpeed,:),'MarkerFaceColor',speedCmap(currSpeed,:));
					end
					xlabel('Distance from place input center (cm)')
					if(useAllSpikes)
						ylabel('spike theta phase')
					else
						ylabel('First spike theta phase')
					end
					hold on
					%percent traveled within input field (not observable extracellularly)
					%{
					currCellPlaceInputStartPosition=thisObj.simObj.externalEnvObj.placeInputStartPositions(j);
					currCellPlaceInputWidth=thisObj.simObj.externalEnvObj.placeInputWidths(j)
					percPlaceInputTraveled=100*(currCellSpikePositions-currCellPlaceInputStartPosition)/currCellPlaceInputWidth;
					plot(percPlaceInputTraveled,currCellSpikePhases,'o','MarkerSize',8,'Color',cellCmap(count,:),'MarkerFaceColor',cellCmap(count,:))
					%}
					figure(figPrecess)

					%percent traveled within spike field (EC observable)
					if(~isempty(currCellSpikePositions))
						currCellPlaceSpikeFieldWidth=currCellSpikePositions(end)-currCellSpikePositions(1);
						percPlaceFieldTraveled=100*(currCellSpikePositions-currCellSpikePositions(1))/currCellPlaceSpikeFieldWidth;
						plot(percPlaceFieldTraveled,currCellSpikePhases,'o','MarkerSize',8,'Color',cellCmap(i,:),'MarkerFaceColor',cellCmap(i,:))
						hold on			
					else
						currCellPlaceSpikeFieldWidth=NaN;
						percPlaceFieldTraveled=NaN;
					end
					%plot(percPlaceFieldTraveled,currCellSpikePhases,'o','MarkerSize',8,'Color',cellCmap(count,:),'MarkerFaceColor',cellCmap(count,:))
					%plot(percPlaceInputTraveled,currCellSpikePhases,'o','MarkerSize',8,'Color',cellCmap(count,:))
					%axHs=[axHs axH];
				end
			end
	
			%maxFigManual2d(3,1,18)
			%linkaxes(axHs,'xy')
			xlim([0 100])
			%ylim([0 360])
			ylim([0 260])
			cb=colorbar()
			%set(cb,'Ylim',[1 count])
			cmap =cellCmap; %get current colormap
			%cmap=cmap([1 count],:); % set your range here
			colormap(gca,cmap); % apply new colormap
			cb=colorbar();
			ylabel(cb,'Cell excitability rank')
			xlabel('Percent of field traversed')	
			ylabel('Spike theta phase')
			title(removeUnderscores(thisObj.simObj.simParamsIDStr))	

			figure(figCompress)
			cmap=speedCmap;
			colormap(gca,cmap)

			cbDist=colorbar('Ticks',[0 0.25 0.5 0.75 1],'TickLabels',{'0',sprintf('%d',(size(speedCmap,1)-1)/4),sprintf('%d',(size(speedCmap,1)-1)/2),sprintf('%d',3*(size(speedCmap,1)-1)/4),sprintf('%d',(size(speedCmap,1)-1))});
			
			ylabel(cbDist,'Speed (cm/s)')
				
			%yticks(cbDist,[0 0.5 1])
			%yticklabels(cbDist,{'0',sprintf('%d',(size(speedCmap,1)-1)/2),sprintf('%d',(size(speedCmap,1)-1))})
			%cmap =placeCmap; %get current colormap
                        %cmap=cmap([1 count],:); % set your range here
                        %colormap(cmap); % apply new colormap
                        %cb=colorbar();
			%cbDist.Limits=[1 size(speedCmap,1)]
		end

		function plotSpikeRankVsPosRank(thisObj,figH)
                	numPlaces=thisObj.simObj.cellsObj.numPlaces;  
                	numCellsPerPlace=thisObj.simObj.cellsObj.numCellsPerPlace;
  
		      	figure(figH)
                        cellsObj=thisObj.simObj.cellsObj;
                        %loop across cells
                        count=0;
                        axHs=[];
                        %for i=1:cellsObj.numCellsPerPlace
                        %        for j=1:cellsObj.numPlaces
					numCycles=length(thisObj.simObj.thetaPopInputObj.getTroughTimes(1,1));
					numCellsTotal=thisObj.simObj.configuration.getNumCells();

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
                        		title(removeUnderscores(thisObj.simObj.simParamsIDStr))
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
		
		function plotAllSpikePhaseDistr(thisObj,figH)

			figure(figH)
                        %spike times per cell
                        spikeTimes=thisObj.simObj.cellsObj.spikeTimes;
                        spikeCellCoords=thisObj.simObj.cellsObj.spikeCellCoords;
                        numCellsPerPlace=thisObj.simObj.configuration.simParams.numCellsPerPlace;

			numPlaces=thisObj.simObj.cellsObj.numPlaces;

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
			edges=0:binSize:thisObj.simObj.configuration.simParams.simTime;
				for p=1:numPlaces
					[counts,edges]=histcounts(spikeTimesByPlace{p},edges);
					plot(edgesToBins(edges),counts,'Color',placeCmap(p,:),'LineWidth',2)
					hold on
				end
			

		end

		function plotSpikePhaseDistrPerCycle(thisObj,figH)
			figure(figH)
                        cellsObj=thisObj.simObj.cellsObj;
                        %loop across cells
                        count=0;
                        axHs=[];
                        cellCmap=jet(thisObj.simObj.configuration.getNumCells());
			numCycles=length(thisObj.simObj.thetaPopInputObj.getTroughTimes(1,1));
			numPlaces=thisObj.simObj.cellsObj.numPlaces;
		
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

			troughTimes=thisObj.simObj.thetaPopInputObj.getTroughTimes(1,1);
			firstCycleStartTime=troughTimes(1);
			lastCycleStartTime=troughTimes(end);
			binToTimeFact=(lastCycleStartTime-firstCycleStartTime)/((numCycles-1)*numBins);
			%endTime=
			for j=1:cellsObj.numPlaces
				plot((1:size(spikePhaseDistrPerCycle,2))*binToTimeFact+firstCycleStartTime,spikePhaseDistrPerCycle(j,:),'-','Color',placeCmap(j,:),'LineWidth',2)
				hold on
			end
			xlim([0 thisObj.simObj.configuration.simParams.simTime])
			ylim([0 max(spikePhaseDistrPerCycle(:))])
			xlabel('Time (msec)')
			ylabel('Count')
			%omarPcolor(1:size(spikePhaseDistrPerCycle,2),1:numPlaces,spikePhaseDistrPerCycle,figH)
			%colorbar
			%shading flat
		end
	end
end
