classdef SimPhaseCodingEvaluation < handle & matlab.mixin.Copyable
	%encapsulate data and actions of analysis to keep my interface and implementation details separate
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
			
				thisObj.spikingDataInterface=copy(SpikingDataInterface(thisObj.simObj));					
			end
		end
		
		%function run(thisObj,figH)
		%	thisObj.visualizePhaseCoding(figH);
		%end
		function runPlotRaster(thisObj,figH)
			thisObj.plotRaster(figH);
		end

		function runRankTransformAnalysis(thisObj,figH)
			thisObj.plotSpikeRankVsPosRank(figH); 	
		end
		
		function runPhaseCodeAnalysis(thisObj,figH)
			thisObj.plotPhaseVsPositionInField(figH);
		end
		
		function runSpikeTimeDistributionAnalysis(thisObj,figH)
			thisObj.plotSpikePhaseDistrPerCycle(figH);
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
			spikeTimes=thisObj.simObj.cellsObj.spikeTimes;
			spikeCellCoords=thisObj.simObj.cellsObj.spikeCellCoords;
			numCellsPerPlace=thisObj.simObj.configuration.simParams.numCellsPerPlace;
	
			for i=1:length(spikeTimes)
				currSpikePlaceIdx=spikeCellCoords(i,2);
				currSpikeCellIdx=spikeCellCoords(i,1);
				cellRasterRow=(currSpikePlaceIdx-1)*numCellsPerPlace+currSpikeCellIdx;
				plot([spikeTimes(i) spikeTimes(i)],[cellRasterRow-1 cellRasterRow],'-','Color',thisObj.placeColors(currSpikePlaceIdx,:),'LineWidth',4)
				hold on 
			end		

			%ASSUMES POPULATION WIDE SYNCHRONOUS THETA
			thetaTroughTimes=thisObj.simObj.thetaPopInputObj.getTroughTimes(1,1);
			
			currYlim=ylim;
			for i=1:length(thetaTroughTimes)
				plot([thetaTroughTimes(i) thetaTroughTimes(i)], currYlim,'Color','b','LineWidth',6)			
			end
			title(removeUnderscores(thisObj.simObj.simParamsIDStr))
			%maxFigManual2d(3,1,14)
			xlabel('Time (msec)')	
			ylabel('Cell No.')	
		end

		function plotPhaseVsPositionInField(thisObj,figH)
			figure(figH)
			cellsObj=thisObj.simObj.cellsObj;
			%loop across cells
			count=0;
			axHs=[];
			cellCmap=jet(thisObj.simObj.configuration.getNumCells());

			for j=1:cellsObj.numPlaces
				for i=1:cellsObj.numCellsPerPlace
					count=count+1;
					%axH=subplot(cellsObj.numCellsPerPlace,cellsObj.numPlaces,count)
					
					%currCellSpikePhases=thisObj.spikingDataInterface.allSpikePhasesPerCell.(sprintf('c%dp%d',i,j));
					%currCellSpikeTimeIdxes=round((thisObj.spikingDataInterface.allSpikeTimesPerCell.(sprintf('c%dp%d',i,j)))/thisObj.simObj.externalEnvObj.idxToTimeFact);
					currCellSpikePhases=thisObj.spikingDataInterface.firstSpikePhasesPerCell.(sprintf('c%dp%d',i,j));
					currCellSpikeTimeIdxes=round((thisObj.spikingDataInterface.firstSpikeTimesPerCell.(sprintf('c%dp%d',i,j)))/thisObj.simObj.externalEnvObj.idxToTimeFact);
					
					currCellSpikePositions=thisObj.simObj.externalEnvObj.rodentPositionVsTime(currCellSpikeTimeIdxes);

					currCellPlaceInputStartPosition=thisObj.simObj.externalEnvObj.placeInputStartPositions(j);
					currCellPlaceInputWidth=thisObj.simObj.externalEnvObj.placeInputWidths(j)
					percPlaceInputTraveled=100*(currCellSpikePositions-currCellPlaceInputStartPosition)/currCellPlaceInputWidth;
					plot(percPlaceInputTraveled,currCellSpikePhases,'o','MarkerSize',8,'Color',cellCmap(count,:),'MarkerFaceColor',cellCmap(count,:))
					%plot(percPlaceInputTraveled,currCellSpikePhases,'o','MarkerSize',8,'Color',cellCmap(count,:))
					hold on			
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
			colormap(cmap); % apply new colormap
			cb=colorbar();
			ylabel(cb,'Cell ordering')
			xlabel('Percent of field traversed')	
			ylabel('Spike theta phase')
			title(removeUnderscores(thisObj.simObj.simParamsIDStr))	
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
							wellOrderedSequence=sort(linearCellIndicesInCycle);
		
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
					caxis([0 prctile(rankMapCount(:)/totalNumMappings,90)])
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
