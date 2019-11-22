classdef ExternalEnvironment < handle & matlab.mixin.Copyable
	%
	properties(Constant)
		CONSTANT_RUN_SPEED=45.0
		%CONSTANT_RUN_SPEED=40
		USE_BOUNDARY_START=0;
		END_BUFFER=500;
		%END_BUFFER=240;
		%PLACE_INPUT_WIDTH=50
		%PLACE_INPUT_WIDTH=80
		%PLACE_INPUT_WIDTH=160
		PLACE_INPUT_WIDTH=120
		%TIME_OVERLAP_FACT=1.5
		%TIME_OVERLAP_FACT=0.25
		TIME_OVERLAP_FACT=0.25
		%EXPECTED_SPEED=25
		%EXPECTED_SPEED=30
		%EXPECTED_SPEED=30
		%EXPECTED_SPEED=60
		%EXPECTED_SPEED=40
		%EXPECTED_SPEED=5
		%EXPECTED_SPEED=5
		%EXPECTED_SPEED=2.5
		EXPECTED_SPEED=2
		%EXPECTED_SPEED=1
		%EXPECTED_SPEED=5
		%PLACE_INPUT_WIDTH=40
		%PLACE_INPUT_WIDTH=20
		%PLACE_INPUT_WIDTH=10
		%PLACE_INPUT_WIDTH=5
		%PLACE_INPUT_WIDTH=15

		%DELTA_X_INTERNAL=30

		%T_END_FIRST=1000 %internal parameters s.t. expecting ~30cm width at 30cm/s
		%T_END_FIRST=1500 %internal parameters s.t. expecting ~30cm width at 30cm/s
		%T_END_FIRST=2000
		T_END_FIRST=3000
		%X_ZERO=10
	end
	
	properties
		rodentRunningSpeed
		timeAxis
		numPlaces

		placeInputStartPositions
		placeInputWidths

		offsets
		
		estPosHalf
		tEnds

		rngSeed

		initialFieldTimeWidth
		maxPlaceEndTime

		defaultAmpTimeSlope

		%placeInputWidth=20 %cm 
		%placeInputWidth=30 %cm 
		%placeInputWidth=40 %cm 
		placeInputWidth %cm 
		timeScaleSpeedMultFactor %cm 
		%placeInputWidth=50 %cm 
		%placeInputWidth=100 %cm 
		%placeInputWidth=50 %cm 
		%placeInputWidth=20 %cm 
		%"Using a 1-Hz threshold as the minimum rate within a place field, field sizes in a cylinder of 76 cm radius ranged from a minimum of 4% of the surface area to a maxi- mum of 62%, with a median size of 18%"

		rodentPositionVsTime
		totalDistanceTraveled
		idxToDistFact
		idxToTimeFact
	end

	methods
		function thisObj=ExternalEnvironment(extEnvSettings)
			if(nargin==1)
				thisObj.placeInputWidth=ExternalEnvironment.PLACE_INPUT_WIDTH;
				%thisObj.timeScaleSpeedMultFactor=ExternalEnvironment.EXPECTED_SPEED/ExternalEnvironment.CONSTANT_RUN_SPEED;
				%thisObj.timeScaleSpeedMultFactor=0.8*ExternalEnvironment.EXPECTED_SPEED/ExternalEnvironment.CONSTANT_RUN_SPEED;
				%thisObj.timeScaleSpeedMultFactor=0.5*ExternalEnvironment.EXPECTED_SPEED/ExternalEnvironment.CONSTANT_RUN_SPEED;
				%thisObj.timeScaleSpeedMultFactor=ExternalEnvironment.EXPECTED_SPEED/ExternalEnvironment.CONSTANT_RUN_SPEED;
				thisObj.timeScaleSpeedMultFactor=ExternalEnvironment.CONSTANT_RUN_SPEED/ExternalEnvironment.EXPECTED_SPEED;

				thisObj.estPosHalf=(CurrentInjectors.ORIGINAL_CURR_AMP - CurrentInjectors.EXTRA_BASELINE)/2;

				if(isstr(extEnvSettings) && strcmp(extEnvSettings,'default'))
					thisObj.setDefaultProperties();
				
				elseif(isstruct(extEnvSettings))
					thisObj.timeAxis=extEnvSettings.timeAxis;
					thisObj.rodentRunningSpeed=extEnvSettings.rodentRunningSpeed;
					thisObj.numPlaces=extEnvSettings.numPlaces;
					thisObj.placeInputStartPositions=NaN(thisObj.numPlaces,1);	
					thisObj.placeInputWidths=NaN(thisObj.numPlaces,1);	
					thisObj.setPositionVsTime();
					
					maxAmp=(CurrentInjectors.ORIGINAL_CURR_AMP - CurrentInjectors.EXTRA_BASELINE);
					%overlapFact=0.2;
					%overlapFact=0.4;
					%overlapFact=20;
					%overlapFact=40;
					overlapFact=80;
					%overlapFact=100;
					%overlapFact=1;
					%overlapFact=3;
					posEstZero=(maxAmp)/thisObj.numPlaces*overlapFact;
					%deltaPosEst=(maxAmp)/thisObj.numPlaces;
					%deltaPosEst=(maxAmp)/thisObj.numPlaces*0.5;
					deltaPosEst=(maxAmp)/thisObj.numPlaces*overlapFact;
					%deltaPosEst=(maxAmp)/thisObj.numPlaces;

					%thisObj.offsets=-(ExternalEnvironment.X_ZERO+(1:thisObj.numPlaces)*ExternalEnvironment.DELTA_X_INTERNAL);
					%thisObj.offsets=-(posEstZero+(0:(thisObj.numPlaces-1))*deltaPosEst);
					%thisObj.offsets=-(posEstZero+(0:(thisObj.numPlaces-1))*deltaPosEst)*thisObj.timeScaleSpeedMultFactor;
					%thisObj.offsets=-(posEstZero+(0:(thisObj.numPlaces-1))*deltaPosEst)*thisObj.timeScaleSpeedMultFactor;
					thisObj.offsets=-(posEstZero+(0:(thisObj.numPlaces-1))*deltaPosEst)*thisObj.timeScaleSpeedMultFactor;
					%thisObj.tEnds=(1:thisObj.numPlaces)*1000;

					thisObj.defaultAmpTimeSlope=((maxAmp-thisObj.offsets(1))/thisObj.T_END_FIRST)*thisObj.timeScaleSpeedMultFactor;
					%thisObj.defaultAmpTimeSlope=((maxAmp-thisObj.offsets(1))/thisObj.T_END_FIRST)/thisObj.timeScaleSpeedMultFactor;
					%thisObj.defaultAmpTimeSlope=((maxAmp*thisObj.timeScaleSpeedMultFactor-thisObj.offsets(1))/thisObj.T_END_FIRST);
					%thisObj.defaultAmpTimeSlope=((maxAmp/thisObj.timeScaleSpeedMultFactor-thisObj.offsets(1))/thisObj.T_END_FIRST);
					%thisObj.defaultAmpTimeSlope=((maxAmp)/thisObj.T_END_FIRST)/thisObj.timeScaleSpeedMultFactor;
					%thisObj.defaultAmpTimeSlope=((maxAmp)/thisObj.T_END_FIRST)/thisObj.timeScaleSpeedMultFactor;
					initialStartTime=-thisObj.offsets(1)/thisObj.defaultAmpTimeSlope;				
	
					%thisObj.initialFieldTimeWidth=(thisObj.T_END_FIRST-initialStartTime)*thisObj.timeScaleSpeedMultFactor;;
					thisObj.initialFieldTimeWidth=(thisObj.T_END_FIRST-initialStartTime);
					%STOP
					%thisObj.defaultAmpTimeSlope=5*deltaPosEst/1000;
					%for j=1:thisObj.numPlaces
					%	thisObj.defaultAmpTimeSlope=(maxAmp-thisObj.offsets(j))/thisObj.tEnds(j)
					%end

					[~,maxEndTime]=thisObj.getPlaceInputStartStopTimes(thisObj.numPlaces);
					thisObj.maxPlaceEndTime=maxEndTime+ExternalEnvironment.END_BUFFER;
				end
			end
		end
		
		function [placeInputStartTime,placeInputEndTime]=getPlaceInputStartStopTimes(thisObj,placeIdx)
			%placeInputCenterPos=((placeIdx-1)/thisObj.numPlaces)*(thisObj.rodentPositionVsTime(end))+thisObj.placeInputWidth/2;
			
			%placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/4)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/5)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/3)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/3.5)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(15)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(30)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(23)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/2)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/6)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/2)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/8)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/2)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/12)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/20)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/25)+thisObj.placeInputWidth/2;		
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%ASSUMING POSITION INFO KNOWN IN INPUT
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%{
			idxToSpeedEstPos=1/ExternalEnvironment.CONSTANT_RUN_SPEED*500;
			placeInputCenterPos=placeIdx*(idxToSpeedEstPos)+thisObj.placeInputWidth/2*thisObj.timeScaleSpeedMultFactor;		
			placeInputStartPos=placeInputCenterPos-thisObj.placeInputWidth/2*thisObj.timeScaleSpeedMultFactor;
			placeInputEndPos=placeInputCenterPos+thisObj.placeInputWidth/2*thisObj.timeScaleSpeedMultFactor;
			thisObj.placeInputStartPositions(placeIdx)=placeInputStartPos;
			thisObj.placeInputWidths(placeIdx)=placeInputEndPos-placeInputStartPos;
			%find when the rodent is at requested position - how this is done in the brain is left open
			[~,placeInputStartIdx]=min(abs(thisObj.rodentPositionVsTime-placeInputStartPos));
			[~,placeInputEndIdx]=min(abs(thisObj.rodentPositionVsTime-placeInputEndPos));
			%placeInputStartTime=thisObj.timeAxis(placeInputStartIdx);			
			if(placeInputEndIdx==length(thisObj.timeAxis))
				%assume constant speed to end outside of simulation
				placeInputEndTime=thisObj.timeAxis(end)+(placeInputEndPos/thisObj.idxToDistFact-length(thisObj.timeAxis))*thisObj.idxToDistFact*thisObj.rodentRunningSpeed(end);
				thisObj.maxPlaceEndTime=placeInputEndTime;	
			else
				placeInputEndTime=thisObj.timeAxis(placeInputEndIdx);			
			end
			%}
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%ASSUMING SPEED BASED ESTIMATION FOR PLACE INPUT (NO LANDMARK UPDATING); d=r*t; speed integration is like scaling space for current speed; factor multplying slope and offset
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%{
			%placeInputHalfTime=1000*((ExternalEnvironment.PLACE_INPUT_WIDTH/2)/ExternalEnvironment.CONSTANT_RUN_SPEED)*thisObj.timeScaleSpeedMultFactor;
			placeInputHalfTime=1000*((ExternalEnvironment.PLACE_INPUT_WIDTH/2)/ExternalEnvironment.CONSTANT_RUN_SPEED)*thisObj.timeScaleSpeedMultFactor;
			%placeInputCenterTime=((placeIdx-1)*placeInputHalfTime*ExternalEnvironment.TIME_OVERLAP_FACT+placeInputHalfTime)*thisObj.timeScaleSpeedMultFactor;
			%placeInputCenterTime=((placeIdx+3)*placeInputHalfTime*ExternalEnvironment.TIME_OVERLAP_FACT+placeInputHalfTime)*thisObj.timeScaleSpeedMultFactor;
			placeInputCenterTime=(thisObj.timeScaleSpeedMultFactor*(placeIdx+3)*placeInputHalfTime*ExternalEnvironment.TIME_OVERLAP_FACT+placeInputHalfTime);
			
			placeInputStartTime=(placeInputCenterTime-placeInputHalfTime);
		
			%remove offset
			%firstPlaceOffset=((1+3)*placeInputHalfTime*ExternalEnvironment.TIME_OVERLAP_FACT+placeInputHalfTime)*thisObj.timeScaleSpeedMultFactor-placeInputHalfTime;
			firstPlaceOffset=(thisObj.timeScaleSpeedMultFactor*(1+3)*placeInputHalfTime*ExternalEnvironment.TIME_OVERLAP_FACT+placeInputHalfTime)-placeInputHalfTime;
			placeInputStartTime=placeInputStartTime-firstPlaceOffset;
	
			%placeInputStartTime=;
			placeInputEndTime=placeInputCenterTime+placeInputHalfTime;
			if(placeInputEndTime>thisObj.timeAxis(end))
				thisObj.maxPlaceEndTime=placeInputEndTime;
			end
			%if(placeInputEndIdx==length(thisObj.rodentPositionVsTime))
			%	placeInputStartTime=0;
			%	placeInputEndTime=0;
			%end

			if(ExternalEnvironment.USE_BOUNDARY_START)
				placeInputStartTime=0;
				evenlyDistributedEndTimes=linspace(1000,3000,7);
				placeInputEndTime=evenlyDistributedEndTimes(placeIdx);
			end	
			%}

			
			%placeInputStartTime=-thisObj.offsets(placeIdx)/ExternalEnvironment.EXPECTED_SPEED;
			placeInputStartTime=-thisObj.offsets(placeIdx)/thisObj.defaultAmpTimeSlope;
			
			%placeInputHalfTime=(thisObj.estPosHalf-thisObj.offsets(placeIdx)*thisObj.timeScaleSpeedMultFactor)/(ExternalEnvironment.EXPECTED_SPEED*thisObj.timeScaleSpeedMultFactor);
			%placeInputHalfTime=(thisObj.estPosHalf-thisObj.offsets(placeIdx)*thisObj.timeScaleSpeedMultFactor)/(thisObj.defaultAmpTimeSlope*thisObj.timeScaleSpeedMultFactor);
			%placeInputEndTime=placeInputStartTime+2*placeInputHalfTime;

			placeInputEndTime=placeInputStartTime+thisObj.initialFieldTimeWidth;

			if(placeInputEndTime>thisObj.timeAxis(end))
                                thisObj.maxPlaceEndTime=placeInputEndTime;
                        end
		end

		function displayContent(thisObj)
			figure
			subplot(2,1,1)
			plot(thisObj.timeAxis,thisObj.rodentPositionVsTime,'k-')
			xlabel('Time (sec)')	
			ylabel('Position (cm)')	
			
			subplot(2,1,2)	
			plot(thisObj.timeAxis,thisObj.rodentRunningSpeed,'k-')
			xlabel('Time (sec)')	
			ylabel('Speed (cm/s)')	
		end
	end

	methods(Access=private)
		function setPositionVsTime(thisObj)
			thisObj.rodentPositionVsTime=cumsum(thisObj.rodentRunningSpeed);

			%assumes time and position start at 0 sec (converts from msec)
			thisObj.totalDistanceTraveled=mean(thisObj.rodentRunningSpeed)*thisObj.timeAxis(end)/1000; 
			thisObj.idxToDistFact=thisObj.totalDistanceTraveled/length(thisObj.rodentPositionVsTime);
			thisObj.idxToTimeFact=thisObj.timeAxis(end)/length(thisObj.rodentPositionVsTime);
			%fix units
			thisObj.rodentPositionVsTime=thisObj.rodentPositionVsTime*(thisObj.totalDistanceTraveled/thisObj.rodentPositionVsTime(end));
		end

		function setDefaultProperties(thisObj)
			%to be implemented	
			%thisObj.
		end
	end
end
