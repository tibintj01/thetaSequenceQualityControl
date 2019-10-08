classdef ExternalEnvironment < handle & matlab.mixin.Copyable
	%	
	properties
		rodentRunningSpeed
		timeAxis
		numPlaces

		placeInputStartPositions
		placeInputWidths

		rngSeed

		maxPlaceEndTime

		%placeInputWidth=20 %cm 
		placeInputWidth=30 %cm 
		%placeInputWidth=40 %cm 
		%placeInputWidth=50 %cm 
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
				if(isstr(extEnvSettings) && strcmp(extEnvSettings,'default'))
					thisObj.setDefaultProperties();
				
				elseif(isstruct(extEnvSettings))
					thisObj.timeAxis=extEnvSettings.timeAxis;
					thisObj.rodentRunningSpeed=extEnvSettings.rodentRunningSpeed;
					thisObj.numPlaces=extEnvSettings.numPlaces;
					thisObj.placeInputStartPositions=NaN(thisObj.numPlaces,1);	
					thisObj.placeInputWidths=NaN(thisObj.numPlaces,1);	
					thisObj.setPositionVsTime();
					
					[~,maxEndTime]=thisObj.getPlaceInputStartStopTimes(thisObj.numPlaces);
					thisObj.maxPlaceEndTime=maxEndTime;
				end
			end
		end
		
		function [placeInputStartTime,placeInputEndTime]=getPlaceInputStartStopTimes(thisObj,placeIdx)
			%placeInputCenterPos=((placeIdx-1)/thisObj.numPlaces)*(thisObj.rodentPositionVsTime(end))+thisObj.placeInputWidth/2;
			
			%placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/4)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/6)+thisObj.placeInputWidth/2;		
			%placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/2)+thisObj.placeInputWidth/2;		
			placeInputCenterPos=placeIdx*(thisObj.placeInputWidth/8)+thisObj.placeInputWidth/2;		

			placeInputStartPos=placeInputCenterPos-thisObj.placeInputWidth/2;
			placeInputEndPos=placeInputCenterPos+thisObj.placeInputWidth/2;
			
			thisObj.placeInputStartPositions(placeIdx)=placeInputStartPos;
			thisObj.placeInputWidths(placeIdx)=placeInputEndPos-placeInputStartPos;

			%find when the rodent is at requested position - how this is done in the brain is left open
			[~,placeInputStartIdx]=min(abs(thisObj.rodentPositionVsTime-placeInputStartPos));
			[~,placeInputEndIdx]=min(abs(thisObj.rodentPositionVsTime-placeInputEndPos));

			placeInputStartTime=thisObj.timeAxis(placeInputStartIdx);			
			if(placeInputEndIdx==length(thisObj.timeAxis))
				%assume constant speed to end outside of simulation
				placeInputEndTime=thisObj.timeAxis(end)+(placeInputEndPos/thisObj.idxToDistFact-length(thisObj.timeAxis))*thisObj.idxToDistFact*thisObj.rodentRunningSpeed(end);
				thisObj.maxPlaceEndTime=placeInputEndTime;	
			else
				placeInputEndTime=thisObj.timeAxis(placeInputEndIdx);			
			end
			%if(placeInputEndIdx==length(thisObj.rodentPositionVsTime))
			%	placeInputStartTime=0;
			%	placeInputEndTime=0;
			%end	
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
