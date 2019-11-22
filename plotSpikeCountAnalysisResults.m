function [exitStatus] = plotAnalysisResults(processedDataPath)
	processedData=load(processedDataPath);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%peak response heat map
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	diRanks=processedData.param1Vals	
	
	speedValues=processedData.param2Vals;

	%approximateRestValue=-55;

	%to convert spike count to spike rate....
	timeWindowsPerSpeed=[666.66600 588.23400 526.31600 476.19200 434.78200 400.00000 370.37000 344.82800 322.58000 ...
    303.03000 285.71400 270.27000 256.41000 243.90200 232.55800 222.22200];

	heatMapInput.diRanks=diRanks;
	heatMapInput.speedValues=speedValues;
	
	titleStrs={'Logarithmic_spike_time_synchrony_decoding','Cycle_based_spike_rate_decoding'};
	%for i=1:1
	for i=1:2
		if(i==1)
			currHeatMatrix=processedData.modelSpikeCountHeatMaps(:,:,1)./timeWindowsPerSpeed;

			modelResponseVarName='Spike Rate (Hz)';
			climVals=[0 0.05];
			plotCurrHeatMap
		end
		if(i==2)
			currHeatMatrix=processedData.modelUndSpikeCountHeatMaps(:,:,1)./timeWindowsPerSpeed;
			modelResponseVarName='Spike Rate (Hz)';
			climVals=[0 0.05];
			plotCurrHeatMap
		end
	end
	

	spikeTimeDecoderResponse=processedData.modelSpikeCountHeatMaps(:,:,1)./timeWindowsPerSpeed;
	spikeRateDecoderResponse=processedData.modelUndSpikeCountHeatMaps(:,:,1)./timeWindowsPerSpeed;

	spikeTimeDecoderResponse_DIvarZd=zscore(spikeTimeDecoderResponse')';
	spikeRateDecoderResponse_DIvarZd=zscore(spikeRateDecoderResponse')';
	
	spikeTimeDecoderResponse_SpeedVarZd=zscore(spikeTimeDecoderResponse);
	spikeRateDecoderResponse_SpeedVarZd=zscore(spikeRateDecoderResponse);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%plot emphasizing stability
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%for col=1:size(spikeTimeDecoderResponse,2)
	%	timeDecoderCurrCol=spikeTimeDecoderResponse(:,col);
	%	rateDecoderCurrCol=spikeRateDecoderResponse(:,col);
	%end		
	meanResponsePerSpeed_TimeDecoder=nanmean(spikeTimeDecoderResponse,1);
	meanResponsePerSpeed_RateDecoder=nanmean(spikeRateDecoderResponse,1);
	%meanResponsePerSpeed_TimeDecoder=nanmean(spikeTimeDecoderResponse_DIvarZd,1);
	%meanResponsePerSpeed_RateDecoder=nanmean(spikeRateDecoderResponse_DIvarZd,1);
	
	%semResponsePerSpeed_TimeDecoder=getSEMacrossRows(spikeTimeDecoderResponse_DIvarZd);
	%semResponsePerSpeed_RateDecoder=getSEMacrossRows(spikeRateDecoderResponse_DIvarZd);
	semResponsePerSpeed_TimeDecoder=getSEMacrossRows(spikeTimeDecoderResponse);
	semResponsePerSpeed_RateDecoder=getSEMacrossRows(spikeRateDecoderResponse);

	xValues=speedValues;
	figure
	e3=shadedErrorBar(xValues,meanResponsePerSpeed_TimeDecoder,semResponsePerSpeed_TimeDecoder,'lineProps',{'b-','linewidth',5})
	hold on
	e4=shadedErrorBar(xValues,meanResponsePerSpeed_RateDecoder,semResponsePerSpeed_RateDecoder,'lineProps',{'k-','linewidth',5})
	title({'Theta Time Decoder vs Theta Rate Decoder:', 'Response Stability during Speed Changes'})

	xlabel('Running speed (cm/s)')
	ylabel('Spike rate (Hz)')
	%legend('Theta Time Decoder','Theta Rate Decoder')
	legend([e3.mainLine e4.mainLine],{'Theta Time Decoder','Theta Rate Decoder'})
	maxFigManual2d(0.75,0.85,16)	

	saveas(gcf,'stabilityGraph.tif')
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%plot emphasizing flexibility
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%for row=1:size(spikeTimeDecoderResponse,1)
	%	timeDecoderCurrRow=spikeTimeDecoderResponse(row,:);
	%	rateDecoderCurrRow=spikeRateDecoderResponse(row,:);
	%end		
	meanResponsePerDI_TimeDecoder=nanmean(spikeTimeDecoderResponse,2);
	meanResponsePerDI_RateDecoder=nanmean(spikeRateDecoderResponse,2);
	%meanResponsePerDI_TimeDecoder=nanmean(spikeTimeDecoderResponse_SpeedVarZd,2);
	%eanResponsePerDI_RateDecoder=nanmean(spikeRateDecoderResponse_SpeedVarZd,2);

	%semResponsePerDI_TimeDecoder=getSEMacrossRows(spikeTimeDecoderResponse_SpeedVarZd');
	%semResponsePerDI_RateDecoder=getSEMacrossRows(spikeRateDecoderResponse_SpeedVarZd');
	semResponsePerDI_TimeDecoder=getSEMacrossRows(spikeTimeDecoderResponse');
	semResponsePerDI_RateDecoder=getSEMacrossRows(spikeRateDecoderResponse');


	xValues=diRanks;
	
	figure
	e1=shadedErrorBar(xValues,meanResponsePerDI_TimeDecoder,semResponsePerDI_TimeDecoder,'lineProps',{'b-','linewidth',5})
	hold on
	
	e2=shadedErrorBar(xValues,meanResponsePerDI_RateDecoder,semResponsePerDI_RateDecoder,'lineProps',{'k-','linewidth',5})
	title({'Theta Time Decoder vs Theta Rate Decoder:', 'Response Flexibility during Sequence Changes'})

	legend([e1.mainLine e2.mainLine],{'Theta Time Decoder','Theta Rate Decoder'})
	xlabel('Directionality index rank (1-5040)')
	ylabel('Spike rate (Hz)')
	maxFigManual2d(0.75,0.85,16)
	saveas(gcf,'flexibilityGraph.tif')

	exitStatus=1;
