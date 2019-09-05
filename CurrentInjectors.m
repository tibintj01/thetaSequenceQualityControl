classdef CurrentInjectors < handle & matlab.mixin.Copyable

	properties
		%currAmp=6;
		%currAmp=8;
		currAmp=7;
		%currAmp=10;
		%currAmp=15;
		pulseShapeStr='ramp';
		

		currInjectorMatrix
		nr
		nc


		timeAxis
	end

	methods
		function thisObj=CurrentInjectors(simSpecificInfo,extEnvObj)
			thisObj.nr=simSpecificInfo.numCellsPerPlace;
			thisObj.nc=simSpecificInfo.numPlaces;
			thisObj.timeAxis=simSpecificInfo.timeAxis;
			
			thisObj.setInjectorMatrix(extEnvObj);
		end


		function displayContent(thisObj)
			figure
			count=1;
			placeColormap=copper(thisObj.nc);
			for r=1:thisObj.nr
				for c=1:thisObj.nc
					subplot(thisObj.nr,thisObj.nc,count)
					plot(thisObj.timeAxis,thisObj.currInjectorMatrix(r,c).getTimeTrace(),'Color',placeColormap(c,:))
					count=count+1;
				
					xlim([thisObj.timeAxis(1) thisObj.timeAxis(end)])
					ylim([0 thisObj.currAmp])
					xlabel('Time (sec)')
					ylabel('Current (pA)')
				end
			end
			maxFigManual2d(2,1,14)
		end
		
		function displayContentSubplot(thisObj,figH)
			figure(figH)
			placeColormap=copper(thisObj.nc);
			for r=1:thisObj.nr
				for c=1:thisObj.nc
					plot(thisObj.timeAxis,thisObj.currInjectorMatrix(r,c).getTimeTrace(),'Color',placeColormap(c,:),'LineWidth',5)
					hold on	
				end
			end
					xlim([thisObj.timeAxis(1) thisObj.timeAxis(end)])
					ylim([0 thisObj.currAmp])
					xlabel('Time (sec)')
					ylabel('Current (pA)')
		end

		function floatMatrix=getFloatMatrix(thisObj)
			floatMatrix=NaN(thisObj.nr,thisObj.nc,length(thisObj.timeAxis));
			for r=1:thisObj.nr
                                for c=1:thisObj.nc
                                        floatMatrix(r,c,:)=thisObj.currInjectorMatrix(r,c).getTimeTrace();
                                end 
                        end 	
		end
	end

	methods(Access=private)
		function setInjectorMatrix(thisObj,extEnvObj)
			nr=thisObj.nr;
			nc=thisObj.nc;
			timeAxis=thisObj.timeAxis;
			currAmp=thisObj.currAmp;;
			pulseShapeStr=thisObj.pulseShapeStr;
			
			currInjectorMatrix(nr,nc)=CurrentInjector();
			
			for cellNum=1:nr
				injParams.timeAxis=timeAxis;
				injParams.pulseShapeStr=pulseShapeStr;;
				for place=1:nc
					%injParams.pulseStartTime=max(0,((place-3)/nc)*(timeAxis(end)));
					%injParams.pulseEndTime=((place)/nc)*(timeAxis(end));
					[placeInputStartTime,placeInputEndTime]=extEnvObj.getPlaceInputStartStopTimes(place);
					injParams.pulseStartTime=placeInputStartTime;
					injParams.pulseEndTime=placeInputEndTime;
					
		
					injParams.amplitude=currAmp;
					injParams.baseline=0;
				
					currInjectorMatrix(cellNum,place)=CurrentInjector(injParams);
				end
			end

			thisObj.currInjectorMatrix=currInjectorMatrix;
		end
	end
end
