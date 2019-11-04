classdef ThetaPopInput < ExternallyControlledConductances
	properties(Constant)
		%L2_MULT_FACTOR=1.25;
		%L2_MULT_FACTOR=0.5;
		%L2_MULT_FACTOR=0.5;
		L2_MULT_FACTOR=0.3;
		%L2_THETA_PHASE_OFFSET=90;		%degrees
		L2_THETA_PHASE_OFFSET=0;		%degrees

		%frequencyDefault=8/1000;		%kHz
		frequencyDefault=7/1000;		%kHz
		%frequencyDefault=80/1000;		%kHz
		phaseOffsetDefault=0;			%radians
		%baselineDefault=0.1;
		%baselineDefault=0.15;
		%amplitudeDefault=0.1;
		%baselineDefault=0.03;
		%amplitudeDefault=0.02;
		%baselineDefault=0.015;
		%amplitudeDefault=0.01;
		%baselineDefault=0.01;
		%amplitudeDefault=0.005;
		baselineDefault=0.075;
		amplitudeDefault=0.05;
		%amplitudeDefault=0.05;
		%amplitudeDefault=0.015;
		%amplitudeDefault=0.0125;
		%amplitudeDefault=0.01;
	

   		%amplitudeDefault=0;

		INCLUDE_GAMMA=0;

		asymTroughPosDefault=0.75;

		
		%gammaMeanAmp=0.08;
		%gammaMeanAmp=0.15;
		%gammaMeanAmp=0.12;
		%gammaMeanAmp=0.15;
		%gammaMeanAmp=0.25;
		
		gammaMeanAmp=0.1;
		gammaAmpSD_acrossSpace=0.02;
		gammaAmpPhaseEnvelopeSD=30; %degrees
		
		%gammaMeanAmp=0;
		%gammaAmpSD_acrossSpace=0;
		%gammaAmpPhaseEnvelopeSD=0; %degrees
		%gammaAmpSD_acrossSpace=0.05;
		%gammaAmpPhaseEnvelopeSD=0.01;
		%gammaAmpPhaseEnvelopeSD=50; %degrees
		%gammaAmpPhaseEnvelopeSD=20; %degrees

		%gammaMeanPhase=150;
		%gammaMeanPhase=80;
		%gammaMeanPhase=270;
		gammaMeanPhase=240;
		gammaPhaseSD=20;

		gammaMeanFreq=50/1000;
		%gammaFreqSD_space=30/1000;
		gammaFreqSD_space=20/1000;
		%gammaMeanFreq=30/1000;
		%gammaFreqSD_space=10/1000;
	
		esynDefault=-72;
	end

	properties
		frequency				 %kHz
		phaseOffset				 %radians
		baseline
		amplitude

		asymTroughPos

		nestedOscillationObj
		troughTimes
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
				if(ThetaPopInput.INCLUDE_GAMMA)
					thisObj.addGammaAll();
				end
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
				
			for r=1:nr
				for c=1:nc
					thisObj.setTroughTimes(r,c);

				end
			end
		end

		function addTroughLines(thisObj,figH)
			if(ThetaPopInput.amplitudeDefault>0)
				figure(figH)
				hold on
				currYlim=ylim;
				thetaTroughTimes=getTroughTimes(thisObj,1,1);
				for i=1:length(thetaTroughTimes)
					%plot([thetaTroughTimes(i) thetaTroughTimes(i)], currYlim,'Color','b','LineWidth',6)
					%plot([thetaTroughTimes(i) thetaTroughTimes(i)], currYlim,'m--','LineWidth',6)
					plot([thetaTroughTimes(i) thetaTroughTimes(i)], currYlim,'b--','LineWidth',3)
				end
			end
		end

		function addGammaAll(thisObj)
			nr=size(thisObj.amplitudeMatrix,1);
                        nc=size(thisObj.amplitudeMatrix,2);
                        for r=1:nr
                                for c=1:nc
					thisObj.addGamma(r,c);
				end
			end
		end

	
		function addGamma(thisObj,r,c)
			troughTimes=getTroughTimes(thisObj,r,c);

			for cycI=1:length(troughTimes)
				currTroughTime=troughTimes(cycI);
				[~,currTroughTimeIdx]=min(abs(thisObj.timeAxis-currTroughTime));
				if(cycI+1<=length(troughTimes))
					nextTroughTime=troughTimes(cycI+1);
				else
					continue
				end
				[~,nextTroughTimeIdx]=min(abs(thisObj.timeAxis-nextTroughTime));
 	
				currCellGammaCenterAmp=normrnd(ThetaPopInput.gammaMeanAmp,ThetaPopInput.gammaAmpSD_acrossSpace,1,1);
				currCycleGammaFreq=normrnd(ThetaPopInput.gammaMeanFreq,ThetaPopInput.gammaFreqSD_space,1,1);
				currCycleGammaCenterPhase=normrnd(ThetaPopInput.gammaMeanPhase,ThetaPopInput.gammaPhaseSD,1,1);

				currCycleTimeIdxes=(currTroughTimeIdx:nextTroughTimeIdx)';
				currCycleTimeValues=thisObj.timeAxis(currCycleTimeIdxes);

				
				%currCycleGammaAmpEnvelop=normpdf(currCycleTimeIdxes,currCellGammaCenterAmp,ThetaPopInput.gammaAmpPhaseEnvelopeSD);
				%currCycleGammaAmpEnvelop=getGaussianCurve(currCycleTimeValues,currCellGammaCenterAmp,ThetaPopInput.gammaAmpPhaseEnvelopeSD);
				currCycleGammaAmpEnvelop=getGaussianCurve(currCycleTimeValues,currCycleTimeValues(1)+currCycleGammaCenterPhase*range(currCycleTimeValues)/360,ThetaPopInput.gammaAmpPhaseEnvelopeSD*range(currCycleTimeValues)/360);
 				currCycleGammaAmpEnvelop=currCycleGammaAmpEnvelop/max(currCycleGammaAmpEnvelop(:)); %normalize so max is 1

				currCellGamma=currCellGammaCenterAmp*currCycleGammaAmpEnvelop(:).*sin(2*pi*currCycleGammaFreq*currCycleTimeValues+currCycleGammaCenterPhase);
				
				cycleWithGamma=thisObj.conductanceTimeSeries(r,c,currCycleTimeIdxes(:))+reshape(currCellGamma,size(thisObj.conductanceTimeSeries(r,c,currCycleTimeIdxes(:))));
				cycleWithGamma(cycleWithGamma<0)=0; %no negative conductances - fully blocked channel
				thisObj.conductanceTimeSeries(r,c,currCycleTimeIdxes(:))=cycleWithGamma;
				%if(cycI==2)
				%	figure; plot(currCycleTimeValues,squeeze(cycleWithGamma));displayCurrentFigure('gammaTest.tif')
				%	figure; plot(thisObj.timeAxis,squeeze(thisObj.conductanceTimeSeries(r,c,:)));displayCurrentFigure
				%end
			end
		end

		function thisTroughTimes=getTroughTimes(thisObj,r,c)
			thisTroughTimes=thisObj.troughTimes{r,c};
		end

		function setTroughTimes(thisObj,r,c)
			[~,troughIdxes]=findpeaks(squeeze(-thisObj.conductanceTimeSeries(r,c,:)));
			troughTimes=thisObj.timeAxis(troughIdxes);
			thisObj.troughTimes{r,c}=troughTimes;
		end

		function [phaseOverTime]=getPhaseOverTime(thisObj,r,c) 
			timeSeries=thisObj.conductanceTimeSeries(r,c,:);
			phaseSeries=hilbert(-(timeSeries-mean(timeSeries)));
			timeSeries_Phase=angle(phaseSeries);
		 	%phaseOverTime =((timeSeries_Phase/pi) + 1)/2 * 360;
		 	phaseOverTime =mod(((timeSeries_Phase/pi) + 2)/2 * 360,360);
		 	%phaseOverTime =(timeSeries_Phase/(2*pi)) * 360;
		end

		function setParameterDefaults(thisObj)
			thisObj.frequency=ThetaPopInput.frequencyDefault;
			thisObj.phaseOffset=ThetaPopInput.phaseOffsetDefault;
			thisObj.baseline=ThetaPopInput.baselineDefault;
			thisObj.amplitude=ThetaPopInput.amplitudeDefault;
		end
	end

end
