classdef SpikingDataInterface < handle & matlab.mixin.Copyable
	%rather than sequence of spike times, sequence of times when rate reaches fixed threshold?
	%could be readout as polychronous group - readout neuron expects certain axonal delays that can be modified
	%perhaps by myelination
	%neuron in readout layer for each particular sequence? also across place assembly?
	properties(Constant)
		%MIN_FIRST_PHASE=120;	
		%MIN_FIRST_PHASE=100;	
		MIN_FIRST_PHASE=150;	
	end

	properties
		spikeThresh=-30;
		

		delayStageNum


		allSpikePhasesPerCell
		firstSpikePhasesPerCell
		firstSpikeTimesPerCell
		allSpikeCyclesPerCell
		allSpikeTimesPerCell
	
		allSpikePhasesPerCellPerCycle
		allSpikeTimesPerCellPerCycle

		firstSpikePhasePerCellPerCycle

		cellSequencePerCycleAllSpikes
		cellSequencePerCycleFirstSpikes

		numCycles
		numCellsPerPlace
		numPlaces

		entryPhasePerCell
		placeFieldWidthPerCell
	end

	methods
		function thisObj=SpikingDataInterface(simObj,delayStageNum)
			thisObj.delayStageNum=delayStageNum;
			
			thisObj.populateCellInfoStructs(simObj);
			thisObj.setFirstSpikePhasesPerCell(simObj);
		end	
	end

	methods(Access=public)
		function populateCellInfoStructs(thisObj,simObj)
			numCellsPerPlace=simObj.configuration.simParams.numCellsPerPlace;
			numPlaces=simObj.configuration.simParams.numPlaces;
			
			thisObj.numCellsPerPlace=numCellsPerPlace;
			thisObj.numPlaces=numPlaces;

			for cellIdx=1:numCellsPerPlace
				for placeIdx=1:numPlaces
					cellInfo=thisObj.getCellInfo(simObj,cellIdx,placeIdx);
					
					allSpikePhasesPerCell.(cellInfo.cellCoordStr)=cellInfo.allSpikePhases;
					allSpikeCyclesPerCell.(cellInfo.cellCoordStr)=cellInfo.allSpikeCycles;
					allSpikeTimesPerCell.(cellInfo.cellCoordStr)=cellInfo.allSpikeTimes;
			
					entryPhasePerCell(cellIdx,placeIdx)=cellInfo.entryPhase;
					placeFieldWidthPerCell(cellIdx,placeIdx)=cellInfo.placeFieldWidth;
				end
			end
			


			thisObj.allSpikePhasesPerCell=allSpikePhasesPerCell;
			thisObj.allSpikeCyclesPerCell=allSpikeCyclesPerCell;
			thisObj.allSpikeTimesPerCell=allSpikeTimesPerCell;
			
			thisObj.setSpikePhasesPerCyclePerCell(simObj);
			thisObj.setCellSequencePerCycle();

			thisObj.entryPhasePerCell=entryPhasePerCell;
			thisObj.placeFieldWidthPerCell=placeFieldWidthPerCell;
		end
		
		function setSpikePhasesPerCyclePerCell(thisObj,simObj)
			allSpikePhasesPerCellPerCycle=struct();

			numCellsPerPlace=simObj.cellsObj.numCellsPerPlace;
			numPlaces=simObj.cellsObj.numPlaces;
			thisObj.numCycles=NaN(numCellsPerPlace,numPlaces);

			firstSpikePhasePerCellPerCycle=NaN(numCellsPerPlace,numPlaces,length(simObj.thetaPopInputObj.getTroughTimes(1,1)));

			for cellIdx=1:numCellsPerPlace
				for placeIdx=1:numPlaces
					thisObj.numCycles(cellIdx,placeIdx)=length(simObj.thetaPopInputObj.getTroughTimes(cellIdx,placeIdx));
					for cycleIdx=1:(thisObj.numCycles)
						currCellSpikeCycles=thisObj.allSpikeCyclesPerCell.(sprintf('c%dp%d',cellIdx,placeIdx));
						currCellSpikePhases=thisObj.allSpikePhasesPerCell.(sprintf('c%dp%d',cellIdx,placeIdx));
						currCellSpikeTimes=thisObj.allSpikeTimesPerCell.(sprintf('c%dp%d',cellIdx,placeIdx));
					
						currCycleCellSpikePhases=currCellSpikePhases(currCellSpikeCycles==cycleIdx);
						currCycleCellSpikeTimes=currCellSpikeTimes(currCellSpikeCycles==cycleIdx);

						allSpikePhasesPerCellPerCycle.(sprintf('c%dp%dcy%d',cellIdx,placeIdx,cycleIdx))=currCycleCellSpikePhases;
						allSpikeTimesPerCellPerCycle.(sprintf('c%dp%dcy%d',cellIdx,placeIdx,cycleIdx))=currCycleCellSpikeTimes;
						
						validFirstSpikePhaseIdxes=find(currCycleCellSpikePhases>SpikingDataInterface.MIN_FIRST_PHASE);
						if(isempty(validFirstSpikePhaseIdxes))
                                                        continue
                                                end

						firstSpikePhasePerCellPerCycle(cellIdx,placeIdx,cycleIdx)=currCycleCellSpikePhases(validFirstSpikePhaseIdxes(1));
					
					end
				end
			end
			thisObj.allSpikePhasesPerCellPerCycle=allSpikePhasesPerCellPerCycle;
			thisObj.allSpikeTimesPerCellPerCycle=allSpikeTimesPerCellPerCycle;
			thisObj.firstSpikePhasePerCellPerCycle=firstSpikePhasePerCellPerCycle;
		end

		function setFirstSpikePhasesPerCell(thisObj,simObj)
			for cellIdx=1:thisObj.numCellsPerPlace
                                for placeIdx=1:thisObj.numPlaces
					thisObj.numCycles(cellIdx,placeIdx)=length(simObj.thetaPopInputObj.getTroughTimes(cellIdx,placeIdx));
                                        phaseCollector=[];
                                        timeCollector=[];
					for cycleIdx=1:(thisObj.numCycles)
						currCycleCellSpikePhases=thisObj.allSpikePhasesPerCellPerCycle.(sprintf('c%dp%dcy%d',cellIdx,placeIdx,cycleIdx));
						currCycleCellSpikeTimes=thisObj.allSpikeTimesPerCellPerCycle.(sprintf('c%dp%dcy%d',cellIdx,placeIdx,cycleIdx));
						validFirstSpikePhaseIdxes=find(currCycleCellSpikePhases>SpikingDataInterface.MIN_FIRST_PHASE);

						if(isempty(validFirstSpikePhaseIdxes))
							continue
						end	
						if(length(currCycleCellSpikePhases)>0)
							%phaseCollector=[phaseCollector currCycleCellSpikePhases(1)];
							%timeCollector=[timeCollector currCycleCellSpikeTimes(1)];
							phaseCollector=[phaseCollector currCycleCellSpikePhases(validFirstSpikePhaseIdxes(1))];
							timeCollector=[timeCollector currCycleCellSpikeTimes(validFirstSpikePhaseIdxes(1))];
						end
					end
					firstSpikePhasesPerCell.(sprintf('c%dp%d',cellIdx,placeIdx))=phaseCollector;
					firstSpikeTimesPerCell.(sprintf('c%dp%d',cellIdx,placeIdx))=timeCollector;
				end
			end
			thisObj.firstSpikePhasesPerCell=firstSpikePhasesPerCell;
			thisObj.firstSpikeTimesPerCell=firstSpikeTimesPerCell;
		end

		function [cellInfo]=getCellInfo(thisObj,simObj,cellIdx,placeIdx)
			%vm,thetaPeriod,rampStartTime,rampPeakTime,g_Inh_Phase,timeAxis,ALL_PEAKS)
			cellsObj=copy(simObj.cellsObj);
			vm=squeeze(cellsObj.v(cellIdx,placeIdx,:));
			thetaPeriod=(1/simObj.thetaPopInputObj.frequency);
			thetaPhaseSeries=squeeze(simObj.thetaPopInputObj.getPhaseOverTime(cellIdx,placeIdx));
			troughTimes=simObj.thetaPopInputObj.getTroughTimes(cellIdx,placeIdx);
			timeAxis=simObj.configuration.simParams.timeAxis;

			rampStartTime=simObj.externalInputObj.currInjectorMatrix(cellIdx,placeIdx).pulseStartTime;		
			rampEndTime=simObj.externalInputObj.currInjectorMatrix(cellIdx,placeIdx).pulseEndTime;		
	

			spikeThresh=thisObj.spikeThresh;

			[subTpeaks,subTpeakIdxes]=findpeaks(vm);

			subTpeakPhases=thetaPhaseSeries(subTpeakIdxes);

			subTpeakTimes=timeAxis(subTpeakIdxes);

			subTpeakISI=[Inf; diff(subTpeakTimes)];

			%remove outlier bunched peaks - threshold ISI half period of imposed theta rhythm
			%subTpeakTimes=subTpeakTimes(subTpeakISI>median(subTpeakISI)/2);
			%subTpeakIdxes=subTpeakIdxes(subTpeakISI>median(subTpeakISI)/2);
			%subTpeakPhases=subTpeakPhases(subTpeakISI>median(subTpeakISI)/2);

			if(~exist('ALL_PEAKS'))
				onlyFirstPeak=0;
			else
				onlyFirstPeak=~ALL_PEAKS;
			end


			if(onlyFirstPeak)
				subTpeakTimes=subTpeakTimes(subTpeakISI>thetaPeriod/2);
				subTpeakIdxes=subTpeakIdxes(subTpeakISI>thetaPeriod/2);
				subTpeakPhases=subTpeakPhases(subTpeakISI>thetaPeriod/2);
			end

			delayStageNum=thisObj.delayStageNum;

			currCellSpikeIDs=[];
			for c=1:length(cellsObj.delayedSpikeTimes)
				if(cellsObj.spikeCellCoords(c,1)==cellIdx && cellsObj.spikeCellCoords(c,2)==placeIdx)
					currCellSpikeIDs=[currCellSpikeIDs;c];
				end
			end

			if(delayStageNum==0)
				allSpikeTimes=subTpeakTimes(subTpeaks>spikeThresh);
				allSpikePhases=subTpeakPhases(subTpeaks>spikeThresh);
			elseif(delayStageNum==1)
				allSpikeTimes=cellsObj.delayedSpikeTimes(currCellSpikeIDs);
				allSpikeIdxes=round(allSpikeTimes/cellsObj.dt);
				allSpikeIdxes=allSpikeIdxes(allSpikeIdxes<=length(thetaPhaseSeries));
				allSpikePhases=thetaPhaseSeries(allSpikeIdxes);
			elseif(delayStageNum==2)
				allSpikeTimes=cellsObj.doubleDelayedSpikeTimes(currCellSpikeIDs);
				allSpikeIdxes=round(allSpikeTimes/cellsObj.dt);
				allSpikeIdxes=allSpikeIdxes(allSpikeIdxes<=length(thetaPhaseSeries));
				allSpikePhases=thetaPhaseSeries(allSpikeIdxes);
			end

			allSpikeCycles=NaN(size(allSpikeTimes));
			if(length(troughTimes)>0)
				for i=1:length(allSpikeTimes)
					searchArray=allSpikeTimes(i)-troughTimes;
					searchArray(searchArray<0)=NaN;
					
					[~,precedingTroughIdx]=min(searchArray);
					allSpikeCycles(i)=precedingTroughIdx; %1=first theta cycle (trough to trough)
				end
			end			
			
			maxLength=min([length(allSpikePhases),length(allSpikeTimes),length(allSpikeCycles)]);
			allSpikePhases=allSpikePhases(1:maxLength);
			allSpikeTimes=allSpikeTimes(1:maxLength);
			allSpikeCycles=allSpikeCycles(1:maxLength);

			allSpikes_IsDuringPlaceInput=zeros(size(allSpikeTimes));
			allSpikes_IsDuringPlaceInput(allSpikeTimes>rampStartTime & allSpikeTimes<rampEndTime)=1;

			%hack - make this based on smoothed firing rate?
			if(sum(allSpikes_IsDuringPlaceInput)>0)	
				placeInputSpikeTimes=allSpikeTimes(logical(allSpikes_IsDuringPlaceInput));
				placeInputSpikePhases=allSpikePhases(logical(allSpikes_IsDuringPlaceInput));
				entryPhase=placeInputSpikePhases(1);
				placeFieldWidth=placeInputSpikeTimes(end)-placeInputSpikeTimes(1);
			else
				entryPhase=NaN;
				placeFieldWidth=NaN;
				placeInputSpikeTimes=NaN;
				placeInputSpikePhases=NaN;
			end

			%{
			placeFieldPhases=subTpeakPhases(subTpeakTimes>rampStartTime & subTpeakTimes<rampPeakTime);
			placeFieldSpikePhases=placeFieldPhases(placeFieldPkHeights>spikeThresh);
			%X=[ones(length(placeFieldTimes),1) placeFieldTimes(:)-placeFieldTimes(1)];
			X=[ones(length(placeFieldPkTimes),1) placeFieldPkTimes(:)-placeFieldPkTimes(1)];
			linFit=(X.'*X)\(X.'*placeFieldPhases(:))
			phasePrecessSlope=linFit(2);
			%entryPhase=linFit(1);
			%entryPhase=placeFieldPhases(1);
			%}



			cellInfo.entryPhase=entryPhase;
			cellInfo.allSpikes_IsDuringPlaceInput=allSpikes_IsDuringPlaceInput;
			cellInfo.subTpeakTimes=subTpeakTimes;
			cellInfo.subTpeakPhases=subTpeakPhases;

			cellInfo.placeInputStartTime=rampStartTime;
			%cellInfo.placeInputPeakTime=rampPeakTime;
			cellInfo.placeInputEndTime=rampEndTime;
			
			cellInfo.allSpikePhases=allSpikePhases;
			cellInfo.allSpikeTimes=allSpikeTimes;
			cellInfo.allSpikeCycles=allSpikeCycles;

			cellInfo.placeFieldWidth=placeFieldWidth;
			cellInfo.cellCoordStr=sprintf('c%dp%d',cellIdx,placeIdx)
		
			
		end
	end


	methods(Access=private)
		function setCellSequencePerCycle(thisObj)
		%function setSequenceRankPerCyclePerCell(thisObj)
			thisObj.cellSequencePerCycleAllSpikes=struct();
			thisObj.cellSequencePerCycleFirstSpikes=struct();
			
			for cycleIdx=1:thisObj.numCycles(1,1)
				currCycleAllSpikePhaseLineup=[];
				currCycleAllSpikeIDs=[];
				
				currCycleFirstSpikePhaseLineup=[];
				currCycleFirstSpikeIDs=[];

				for cellIdx=1:thisObj.numCellsPerPlace
					for placeIdx=1:thisObj.numPlaces
						currCycleSpikePhasesThisCell=thisObj.allSpikePhasesPerCellPerCycle.(sprintf('c%dp%dcy%d',cellIdx,placeIdx,cycleIdx));

						currCycleAllSpikePhaseLineup=[currCycleAllSpikePhaseLineup; currCycleSpikePhasesThisCell];
						for s=1:length(currCycleSpikePhasesThisCell)
							currCycleAllSpikeIDs=[currCycleAllSpikeIDs; [cellIdx, placeIdx]];
						end

						if(length(currCycleSpikePhasesThisCell)>0)
							f=1;
							firstValidSpikePhaseThisCell=currCycleSpikePhasesThisCell(f);
							while(f<length(currCycleSpikePhasesThisCell) && firstValidSpikePhaseThisCell<SpikingDataInterface.MIN_FIRST_PHASE)
								f=f+1;
								firstValidSpikePhaseThisCell=currCycleSpikePhasesThisCell(f);
							end
							%currCycleFirstSpikePhaseLineup=[currCycleFirstSpikePhaseLineup; currCycleSpikePhasesThisCell(1)];
							currCycleFirstSpikePhaseLineup=[currCycleFirstSpikePhaseLineup; firstValidSpikePhaseThisCell];
							currCycleFirstSpikeIDs=[currCycleFirstSpikeIDs; [cellIdx, placeIdx]];
						end
					end
		                end
				[~,sortIDsAll]=sort(currCycleAllSpikePhaseLineup);
				[~,sortIDsFirst]=sort(currCycleFirstSpikePhaseLineup);

				thisObj.cellSequencePerCycleAllSpikes.(sprintf('cycle%d',cycleIdx))=currCycleAllSpikeIDs(sortIDsAll,:);
				thisObj.cellSequencePerCycleFirstSpikes.(sprintf('cycle%d',cycleIdx))=currCycleFirstSpikeIDs(sortIDsFirst,:);
			end
		end
	end
end
