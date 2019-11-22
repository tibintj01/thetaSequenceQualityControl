classdef CurrentInjector < handle & matlab.mixin.Copyable
	properties(Constant)
		%NOISE_SIGMA=0.2; %nA
		%NOISE_SIGMA=2; %nA
		%NOISE_SIGMA=3.5/4; %nA
		%NOISE_SIGMA=3.5/5; %nA
		%NOISE_SIGMA=3.5/4; %nA
		%NOISE_SIGMA=3.5/10; %nA
		%NOISE_SIGMA=3.5/10/10; %nA
		%NOISE_SIGMA=3.5/10/3; %nA
		%NOISE_SIGMA=3.5/10/2; %nA
		%NOISE_SIGMA=3.5/10/1.5; %nA
		%NOISE_SIGMA=3.5/10/1.5; %nA
		NOISE_SIGMA=3.5/10/10; %nA
                NOISE_SAMPLING_DT=0.5; %msec
		
		%USE_EXP_RAMP=1;
		USE_EXP_RAMP=0;
		startExpX=-2.7
	end
	
	properties
		timeAxis
		pulseStartTime
		pulseEndTime

		noiseAmplitude=0.2;
		
		noiseTrace	
		speedTrace
	
		positionAxis
		positionStart
		positionEnd

		amplitude
		baseline

		rngSeed=1

		pulseShapeStr
		
		sensoryChannelNum

		%asymPeakTimeFrac=0.75
		%asymPeakTimeFrac=0.95
		asymPeakTimeFrac=1
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
				thisInjector.rngSeed=injParams.rngSeed;
				
				thisInjector.amplitude=injParams.amplitude;
				thisInjector.baseline=injParams.baseline;
				thisInjector.sensoryChannelNum=injParams.sensoryChannelNum;
				%thisInjector.setNoiseTrace();
				thisInjector.setGaussianNoiseTrace();
				
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

		function setGaussianNoiseTrace(thisObj)
                        len = thisObj.timeAxis(end);                    % Length (sec)
                        Fs  = 1/(CurrentInjector.NOISE_SAMPLING_DT);
                                                                       % Sampling Frequency (Hz)
                        startBinCenter=CurrentInjector.NOISE_SAMPLING_DT/2;
			endBinCenter=len-CurrentInjector.NOISE_SAMPLING_DT/2;
			
			%CAUSES INTERPOLATION PROBLEMS!!!
			%noiseTimeAxis   = linspace(startBinCenter, endBinCenter, round(Fs*len));                 % Time Vector
			
			noiseTimeAxis   = linspace(0,len, round(Fs*len)+1);                 % Time Vector

			%if(isempty(thisObj.rngSeed))
			%	thisObj.rngSeed=1;
			%end

			rng(thisObj.rngSeed*thisObj.sensoryChannelNum)

                        noiseTrace = CurrentInjector.NOISE_SIGMA*randn(size(noiseTimeAxis));
			interpNoiseTrace= interp1(noiseTimeAxis,noiseTrace,thisObj.timeAxis);
			%unique noise profile per sensory channel (cell in each place assembly)
                        thisObj.noiseTrace=interpNoiseTrace(:)
                end

		%currently not used - 9/30/19, TJ
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
			if(CurrentInjector.USE_EXP_RAMP)
				%startExpX=-2.5;
				%startExpX=-3;
				%startExpX=-5;
				pulse(startIdx:peakIdx)=thisInjector.amplitude*exp((linspace(0,peakIdx,(peakIdx-startIdx+1))-peakIdx)*(-CurrentInjector.startExpX/peakIdx))';
			else
				pulse(startIdx:peakIdx)=linspace(0,thisInjector.amplitude,(peakIdx-startIdx+1))';
			end
			if(endIdx==length(timeAxis))
				slope=(thisInjector.amplitude)/(peakTime-pulseEndTime);
				if(abs(peakTime-pulseEndTime)<0.01) %case when ends on peak... slope hard to get
					slope=0;
				end
				endVal=thisInjector.amplitude+slope*(timeAxis(end)-peakTime);
				%pulse(peakIdx:endIdx)=linspace(thisInjector.amplitude,endVal,(endIdx-peakIdx+1))';
			else
				endVal=0;
				%pulse(peakIdx:endIdx)=linspace(thisInjector.amplitude,0,(endIdx-peakIdx+1))';
			end
			if(CurrentInjector.USE_EXP_RAMP)
				pulse(peakIdx:endIdx)=thisInjector.amplitude*(1-exp((linspace(0,endIdx,(endIdx-peakIdx+1))-endIdx)*(-CurrentInjector.startExpX/endIdx)));
			else
				pulse(peakIdx:endIdx)=linspace(thisInjector.amplitude,endVal,(endIdx-peakIdx+1))';
			end
			injCurrentTrace=injCurrentTrace+pulse;

			injCurrentTrace=injCurrentTrace+thisInjector.noiseTrace;
		end
	end
end
