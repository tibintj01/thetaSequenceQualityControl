classdef ThetaPopInput < ExternallyControlledConductances
	properties(Constant)
		frequencyDefault=8/1000;		%kHz
		phaseOffsetDefault=0;			%radians
		baselineDefault=0.1;
		amplitudeDefault=0.1;

		asymTroughPosDefault=0.75;

		
		gammaMeanAmp
		gammaAmpSD_space
		gammaAmpSD_phase

		gammaMeanPhase
		gammaPhaseSD

		gammaMeanFreq
		gammaFreqSD_space
	
		esynDefault=-72;
	end

	properties
		frequency				 %kHz
		phaseOffset				 %radians
		baseline
		amplitude

		asymTroughPos

		nestedOscillationObj
		%use methods to get these with index indicated 
		%troughTimes
		%phaseOverTime
	end

	methods
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Constructor
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function thisObj=ThetaPopInput(simSpecificInfo)
			%if(nargin==1) %for some reason nargin refers to object, can't use in subclass?
				extInParams.numPlaces=simSpecificInfo.numPlaces;
				extInParams.numCellsPerPlace=simSpecificInfo.numCellsPerPlace;
				extInParams.timeAxis=simSpecificInfo.timeAxis;
				
				extInParams.baselineMatrix=ThetaPopInput.baselineDefault*ones(simSpecificInfo.numCellsPerPlace,simSpecificInfo.numPlaces);
				extInParams.amplitudeMatrix=ThetaPopInput.amplitudeDefault*ones(simSpecificInfo.numCellsPerPlace,simSpecificInfo.numPlaces);
				
				extInParams.typeStr='theta';
				extInParams.esyn=ThetaPopInput.esynDefault;
				thisObj=thisObj@ExternallyControlledConductances(extInParams);
				thisObj.setParameterDefaults();
				thisObj.setConductanceTimeSeries();
			%end
		end
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%implement populating time series matrix for theta input
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function setConductanceTimeSeries(thisObj)
			nr=size(thisObj.amplitudeMatrix,1);
			nc=size(thisObj.amplitudeMatrix,2);
			mtx=NaN(nr,nc,length(thisObj.timeAxis));
			for r=1:nr
				for c=1:nc
					mtx(r,c,:)=thisObj.amplitudeMatrix(r,c)*sin(2*pi*thisObj.frequency*thisObj.timeAxis+thisObj.phaseOffset)+thisObj.baselineMatrix(r,c);
				end
			end
			
			thisObj.conductanceTimeSeries=mtx;
		end

		function troughTimes=getTroughTimes(thisObj,r,c)
			[~,troughIdxes]=findpeaks(squeeze(thisObj.conductanceTimeSeries(r,c,:)));
			troughTimes=thisObj.timeAxis(troughIdxes);
		end

		function [phaseOverTime]=getPhaseOverTime(thisObj,r,c) 
			timeSeries=thisObj.conductanceTimeSeries(r,c,:);
			phaseSeries=hilbert(-(timeSeries-mean(timeSeries)));
			timeSeries_Phase=angle(phaseSeries);
		 	phaseOverTime =((timeSeries_Phase/pi) + 1)/2 * 360;
		end

		function setParameterDefaults(thisObj)
			thisObj.frequency=ThetaPopInput.frequencyDefault;
			thisObj.phaseOffset=ThetaPopInput.phaseOffsetDefault;
			thisObj.baseline=ThetaPopInput.baselineDefault;
			thisObj.amplitude=ThetaPopInput.amplitudeDefault;
		end
	end

end
