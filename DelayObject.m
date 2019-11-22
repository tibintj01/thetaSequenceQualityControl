classdef DelayObject < handle & matlab.mixin.Copyable %create object by reference
	properties(Constant)
		TONIC_RESOLUTION=1e-4;
		%TONIC_RESOLUTION=1e-6;
		IMIN=18;%based on phase selection of single units to range of bias currents
		%IMIN=20;%based on phase selection of single units to range of bias currents
		IMAX=25.5; %based on phase selection of single units to range of bias currents
		%IMAX=28; %based on phase selection of single units to range of bias currents
		BASELINE_DELAY=60;%get out of current cycle
		%BASELINE_DELAY=0;%get out of current cycle

		%NORM_FACTOR=17
		%NORM_FACTOR=17*1.7
		%NORM_FACTOR=17
		NORM_FACTOR=17
		CONV_FACTOR=17
		%CONV_FACTOR=100
		%NORM_FACTOR=50
		%CONV_FACTOR=17
		%CONV_FACTOR=50
	end

	properties
		tonicToDelayMap
		itonics
		defaultPhaseSlope
		tonicToExpectedNextThetaPhase
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %public methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods
	
		function thisObj=DelayObject()
			thisObj.setTonicToDelayMap();
		end

		function displayContent(thisObj,figH)
			if(~exist('figH'))
				figH=figure
			end
			dispRes=15;

			plot(thisObj.itonics(1:dispRes:end),thisObj.tonicToDelayMap(1:dispRes:end),'LineWidth',5);
			%ylim([DelayObject.BASELINE_DELAY Inf])
			ylim([-Inf Inf])
			xlabel('Input current (nA)')
			ylabel('Delay (msec)')
			title('Delay to CA1-PSP coding of local CA3 excitation')
			maxFig
			setFigFontTo(28)
			saveas(gcf,'CA3_CodingTonicInputAsDelay.tif')

			figure	
			plot(thisObj.itonics(1:dispRes:end),thisObj.tonicToExpectedNextThetaPhase(1:dispRes:end),'LineWidth',5);
			%ylim([DelayObject.BASELINE_DELAY Inf])
			ylim([-Inf Inf])
			xlabel('Input current (nA)')
			ylabel('Target time into next theta cycle')
			title('Delay coding for local CA3 excitation produces phase precession curve')
			maxFig
			setFigFontTo(28)
			saveas(gcf,'CA3_DelayProducingPhasePrecession.tif')
		end
	end


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %private methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods(Access=protected)
		function setTonicToDelayMap(thisObj)

			istep=DelayObject.TONIC_RESOLUTION;
			imax=DelayObject.IMAX;			
			imin=DelayObject.IMIN;

			itonics=imin:istep:imax;
			thisObj.itonics=itonics;
			
			tonicToDelayMap=NaN(size(itonics));

			
			for j=1:length(itonics);
				tonicToDelayMap(j)=thisObj.tonicToDelay(itonics(j));
				%tonicToDelayMap(j)=normFactor*log(imax-itonics(j));
				tonicToExpectedNextThetaPhase(j)=tonicToDelayMap(j)-(thisObj.defaultPhaseSlope*(itonics(j)-imin));
				itonics(j)
			end

			thisObj.tonicToDelayMap=tonicToDelayMap;	
			thisObj.tonicToExpectedNextThetaPhase=tonicToExpectedNextThetaPhase;	
		end

		function delay=tonicToDelay(thisObj,itonic) 
			%nA to msec
			%represents phenomenon of phase precession in model; logarithmic wrt (Imax -I)	
			imax=DelayObject.IMAX;
			imin=DelayObject.IMIN;

			%normFactor=13; %max is full theta cycle
			%convFactor=15;
			normFactor=DelayObject.NORM_FACTOR; %max is full theta cycle
			convFactor=DelayObject.CONV_FACTOR;

			%delay=normFactor*log(DelayObject.IMAX-itonic)+baselineDelay;
			%logarithmic function of distance to end	
			%delay=30*log((DelayObject.IMAX-itonic)-DelayObject.IMIN)+75;	
			defaultPhaseSlope=DelayObject.BASELINE_DELAY/(imax-imin);
			thisObj.defaultPhaseSlope=defaultPhaseSlope;

			%delay=normFactor*log(convFactor*(DelayObject.IMAX-itonic))+DelayObject.BASELINE_DELAY+(defaultPhaseSlope*(itonic-imin));
			%delay=-normFactor*log(convFactor*(itonic-DelayObject.IMIN))+DelayObject.BASELINE_DELAY+(defaultPhaseSlope*(itonic-imin));
			%delay=-normFactor*log(convFactor*(itonic-DelayObject.IMIN))+(defaultPhaseSlope*(itonic-imin));
			%delay=-normFactor*log(convFactor*(itonic-DelayObject.IMIN))+(defaultPhaseSlope*(itonic-imin));
			delay=normFactor*log(convFactor*(DelayObject.IMAX-itonic))+DelayObject.BASELINE_DELAY+(defaultPhaseSlope*(itonic-imin));
			%delay=-normFactor*log(convFactor*(itonic-DelayObject.IMIN));
			%delay=-normFactor*log(convFactor*(itonic-DelayObject.IMIN));

		end
	end	
end
