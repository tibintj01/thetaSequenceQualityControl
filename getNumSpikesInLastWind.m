function [numRecentSpikes]=getNumSpikesInLastWind(spikeTimes,spikeCellCoords,windLength)

	currSpikeTime=spikeTimes(end);
	currSpikeID=length(spikeTimes);
	currSpikeCellRow=spikeCellCoords(end,1);
	currSpikeCellPlace=spikeCellCoords(end,2);

	numRecentSpikes=0;

	allRecentSpikeIDs=find(spikeTimes>(currSpikeTime-windLength));

	for i=1:length(allRecentSpikeIDs)
		currID=allRecentSpikeIDs(i);

		if(spikeCellCoords(currID,1)==currSpikeCellRow && spikeCellCoords(currID,2)==currSpikeCellPlace && currID ~= currSpikeID)
			numRecentSpikes=numRecentSpikes+1;
		end
	end

		
