classdef CurrentInjector < handle & matlab.mixin.Copyable
	
	properties
		timeAxis
		pulseStartTime
		pulseEndTime

		noiseAmplitude=0;
		
		noiseTrace	
		speedTrace
	
		positionAxis
		positionStart
		positionEnd

		amplitude
		baseline

		pulseShapeStr

		%asymPeakTimeFrac=0.75
		asymPeakTimeFrac=0.95
		%asymPeakTimeFrac=1
		%injCurrentTrace
	end

	methods
		function thisInjector=CurrentInjector(injParams)

			if(nargin==1)
				thisInjector.timeAxis=injParams.timeAxis;
				thisInjector.pulseStartTime=injParams.pulseStartTime;
				thisInjector.pulseEndTime=injParams.pulseEndTime;
			
				thisInjector.pulseShapeStr=injParams.pulseShapeStr;
				
				thisInjector.amplitude=injParams.amplitude;
				thisInjector.baseline=injParams.baseline;
				thisInjector.setNoiseTrace();
				%fds
			end
		end
		
		function injCurrentTrace=getTimeTrace(thisInjector)
			if(strcmp(thisInjector.pulseShapeStr,'ramp') || strcmp(thisInjector.pulseShapeStr,'flat'))
				injCurrentTrace=buildRamp(thisInjector);
			else
				error('*********current shape not yet implemented***************')
			end
		end

		function setNoiseTrace(thisObj)
			len = thisObj.timeAxis(end);                    % Length (sec)
			f   = 100;                                      % Frequency (Hz)
			Fs  = 1/(thisObj.timeAxis(2)-thisObj.timeAxis(1));
					                               % Sampling Frequency (Hz)
			t   = linspace(0, len, Fs*len);                 % Time Vector
	
			noiseBaseline = thisObj.noiseAmplitude*sin(2*pi*f*t);                         % Signal (10 kHz sine)
			thisObj.noiseTrace = noiseBaseline + thisObj.noiseAmplitude*randn(size(noiseBaseline));
			thisObj.noiseTrace=thisObj.noiseTrace(:);
		end
	end

	methods(Access=private)
		%implement for constant starting position rather than time when speed varies
		function injCurrentTrace=buildRamp(thisInjector)

			timeAxis=thisInjector.timeAxis;
			pulseStartTime=thisInjector.pulseStartTime;
			pulseEndTime=thisInjector.pulseEndTime;
			asymPeakTimeFrac=thisInjector.asymPeakTimeFrac;

			injCurrentTrace=zeros(size(timeAxis));
			injCurrentTrace=injCurrentTrace+thisInjector.baseline;

			peakTime=pulseStartTime+(pulseEndTime-pulseStartTime)*asymPeakTimeFrac;
			
			[~,startIdx]=min(abs(timeAxis-pulseStartTime));
			[~,peakIdx]=min(abs(timeAxis-peakTime));
			[~,endIdx]=min(abs(timeAxis-pulseEndTime));     

			pulse=zeros(size(timeAxis));
			pulse(startIdx:peakIdx)=linspace(0,thisInjector.amplitude,(peakIdx-startIdx+1))';
			if(endIdx==length(timeAxis))
				slope=(thisInjector.amplitude)/(peakTime-pulseEndTime);
				if(abs(peakTime-pulseEndTime)<0.01) %case when ends on peak... slope hard to get
					slope=0;
				end
				endVal=thisInjector.amplitude+slope*(timeAxis(end)-peakTime);
				pulse(peakIdx:endIdx)=linspace(thisInjector.amplitude,endVal,(endIdx-peakIdx+1))';
			else
				pulse(peakIdx:endIdx)=linspace(thisInjector.amplitude,0,(endIdx-peakIdx+1))';
			end

			injCurrentTrace=injCurrentTrace+pulse;

			injCurrentTrace=injCurrentTrace+thisInjector.noiseTrace;
		end
	end
end
