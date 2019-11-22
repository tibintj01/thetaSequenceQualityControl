classdef CurrentInjectors < handle & matlab.mixin.Copyable
	properties(Constant)
		%BASELINE=4;
		BASELINE=18;
		%EXTRA_BASELINE=1.5
		%EXTRA_BASELINE=2
		%EXTRA_BASELINE=5
		%EXTRA_BASELINE=3
		EXTRA_BASELINE=2.1
		%BASELINE=20;
		%SIG_FRAC=0.05;
		SIG_FRAC=0;
		DI_SORTED_PERM_RANK=1

		ORIGINAL_CURR_AMP=7.5
	end

	properties
		%currAmp=6;
		%currAmp=8;
		%currAmp=7;
		%currAmp=10;
		%currAmp=8;
		%currAmp=1;
		%%%%%%%%%%%%%%%%%%%%%%%
		%current span (18-25.5)
		%%%%%%%%%%%%%%%%%%%%%%%
		currAmp=7.5;
		%currAmp=15;
		pulseShapeStr='ramp';
		%pulseShapeStr='flat';

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
			thisObj.currAmp=CurrentInjectors.ORIGINAL_CURR_AMP;
			thisObj.setInjectorMatrix(extEnvObj);
			thisObj.displayInputDiffVsPos(extEnvObj);
			%STOP
		end


		function displayContent(thisObj)
			figure
			count=1;
			placeColormap=copper(thisObj.nc);
			for r=1:thisObj.nr
				for c=1:thisObj.nc
					%cellBaseline=normrnd(CurrentInjectors.BASELINE,cellBaselineSig);
					subplot(thisObj.nr,thisObj.nc,count)
					plot(thisObj.timeAxis,thisObj.currInjectorMatrix(r,c).getTimeTrace(),'Color',placeColormap(c,:))
					count=count+1;
				
					xlim([thisObj.timeAxis(1) thisObj.timeAxis(end)])
					%ylim([0 thisObj.currAmp]+CurrentInjectors.BASELINE)
					apparentBaseline=CurrentInjectors.BASELINE+ CurrentInjectors.EXTRA_BASELINE;
					ylim([0 thisObj.currAmp]+apparentBaseline)
					xlabel('Time (sec)')
					ylabel('I_s (nA)')
				end
			end
			maxFigManual2d(2,1,14)
		end
		
		function [fH]=displayInputDiffVsPos(thisObj,extEnvObj)
			fH=figure
			firstCellInput=thisObj.currInjectorMatrix(1,1).getTimeTrace();
			secondCellInput=thisObj.currInjectorMatrix(1,2).getTimeTrace();

			cellInputDiff=firstCellInput-secondCellInput;
			overallBaseline=min([firstCellInput(:); secondCellInput(:)])
			cellInputRatio=(firstCellInput-overallBaseline)./(secondCellInput-overallBaseline);
			positions=extEnvObj.rodentPositionVsTime;	

			subplot(1,2,1)
			yyaxis left
			plot(positions,cellInputDiff,'k','LineWidth',5)
			title('Place input 2nd difference across cells')
			xlabel('Position (cm)')
			ylabel('Input difference (nA)')
			ylim([0 thisObj.currAmp])
			xlim([0 300])
			
			yyaxis right
			plot(positions,cellInputRatio,'b','LineWidth',5)
			title('Place input difference ratio across cells')
			xlabel('Position (cm)')
			ylabel('Input difference ratio')
			ylim([0 2])
			xlim([0 300])
			
			subplot(1,2,2)
			yyaxis left
			plot(thisObj.timeAxis,cellInputDiff,'k','LineWidth',5)
			title('Place input difference across cells')
			xlabel('Time (msec)')
			ylabel('Input difference (nA)')
			ylim([0 thisObj.currAmp])
			xlim([0 Simulation.CONSTANT_TIME_MAX])
			
			yyaxis right
			plot(thisObj.timeAxis,cellInputRatio,'b','LineWidth',5)
			title('Place input ratio across cells')
			xlabel('Time (msec)')
			ylabel('Input ratio')
			ylim([0 2])
			xlim([0 Simulation.CONSTANT_TIME_MAX])
		end
		
		function displayContentSubplot(thisObj,figH)
			figure(figH)
			placeColormap=copper(thisObj.nc);
			for r=1:thisObj.nr
				for c=1:thisObj.nc
					plot(thisObj.timeAxis,thisObj.currInjectorMatrix(r,c).getTimeTrace(),'Color',placeColormap(c,:),'LineWidth',2)
					hold on	
				end
			end
			xlim([thisObj.timeAxis(1) thisObj.timeAxis(end)])
			%ylim([0 thisObj.currAmp] + CurrentInjectors.BASELINE)
			apparentBaseline=CurrentInjectors.BASELINE+ CurrentInjectors.EXTRA_BASELINE;
			ylim([0 thisObj.currAmp]+apparentBaseline)
			xlabel('Time (sec)')
			ylabel('I_s (nA)')
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
			cellBaselineSig=CurrentInjectors.SIG_FRAC*CurrentInjectors.BASELINE;
			nr=thisObj.nr;
			nc=thisObj.nc;
			timeAxis=thisObj.timeAxis;
			
			thisObj.currAmp=thisObj.currAmp-CurrentInjectors.EXTRA_BASELINE;

			currAmp=thisObj.currAmp;;
			pulseShapeStr=thisObj.pulseShapeStr;
			
			currInjectorMatrix(nr,nc)=CurrentInjector();
			
			data=load(sprintf('DI_SORTED_%d_PERMUTATIONS.mat',nc));
			sortedPerms=data.sortedPerms;
			currentPlaceSequence=sortedPerms(CurrentInjectors.DI_SORTED_PERM_RANK,:);
			currentPlaceSequenceDI=data.DIs(CurrentInjectors.DI_SORTED_PERM_RANK);
			for cellNum=1:nr
				injParams.timeAxis=timeAxis;
				injParams.pulseShapeStr=pulseShapeStr;
				for place=1:nc
					%injParams.pulseStartTime=max(0,((place-3)/nc)*(timeAxis(end)));
					%injParams.pulseEndTime=((place)/nc)*(timeAxis(end));
					if(strcmp(pulseShapeStr,'ramp'))
						%if(CurrentInjectors.RUN_BACKWARDS==1)
						%	[placeInputStartTime,placeInputEndTime]=extEnvObj.getPlaceInputStartStopTimes(nc-place+1);
						%else
						%	[placeInputStartTime,placeInputEndTime]=extEnvObj.getPlaceInputStartStopTimes(place);
						%end
						%[placeInputStartTime,placeInputEndTime]=extEnvObj.getPlaceInputStartStopTimes(currentPlaceSequence(place));
						[placeInputStartTime,placeInputEndTime]=extEnvObj.getPlaceInputStartStopTimes(place);

						
						injParams.pulseStartTime=placeInputStartTime;
						injParams.pulseEndTime=placeInputEndTime;
						
						injParams.sensoryChannelNum=cellNum;
	
						injParams.amplitude=currAmp;
						%injParams.baseline=0;
						injParams.baseline=normrnd(CurrentInjectors.BASELINE,cellBaselineSig)+CurrentInjectors.EXTRA_BASELINE;
						%CurrentInjectors.BASELINE;
						injParams.rngSeed=extEnvObj.rngSeed;					
						%currInjectorMatrix(cellNum,place)=CurrentInjector(injParams);
						currInjectorMatrix(cellNum,currentPlaceSequence(place))=CurrentInjector(injParams);
					elseif(strcmp(pulseShapeStr,'flat'))
						placeInputStartTime=timeAxis(1);
						placeInputEndTime=timeAxis(end);
						injParams.pulseStartTime=placeInputStartTime;
                                                injParams.pulseEndTime=placeInputEndTime;
						
						injParams.amplitude=0;
                                                injParams.baseline=currAmp;
			
						injParams.rngSeed=extEnvObj.rngSeed;
                                                currInjectorMatrix(cellNum,place)=CurrentInjector(injParams);
					end
				end
			end

			thisObj.currInjectorMatrix=copy(currInjectorMatrix);
		end
	end
end


