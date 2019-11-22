function [exitStatus] = plotAnalysisResults(processedDataPath)
	processedData=load(processedDataPath);
	directory_names

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%peak response heat map
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	diRanks=processedData.param1Vals	
	
	speedValues=processedData.param2Vals;

	%approximateRestValue=-55;

	%to convert spike count to spike rate....
	%timeWindowsPerSpeed=[666.66600 588.23400 526.31600 476.19200 434.78200 400.00000 370.37000 344.82800 322.58000 ...
    %303.03000 285.71400 270.27000 256.41000 243.90200 232.55800 222.22200];

    totalDist=1e4;
    timeWindowsPerSpeed=totalDist./speedValues
	heatMapInput.diRanks=diRanks;
	heatMapInput.speedValues=speedValues;
	
	
	titleStrs={'Logarithmic_spike_time_synchrony_decoding','Linear_spike_time_synchrony_decoding'};
	%for i=1:1
	for i=1:2
			currHeatMatrix=processedData.modelSpikeCountHeatMaps(:,:,i)./timeWindowsPerSpeed;

			modelResponseVarName='Spike Rate (Hz)';
			climVals=[0 0.035];
			plotCurrHeatMap

			maxFigManual2d(1,0.85,16)

		        saveas(gcf,fullfile(FIGURE_DIR,sprintf('HeatMap%s.tif',titleStrs{i})))	
	end
	

	spikeLogTimeDecoderResponse=processedData.modelSpikeCountHeatMaps(:,:,1)./timeWindowsPerSpeed;
	spikeLinearTimeDecoderResponse=processedData.modelSpikeCountHeatMaps(:,:,2)./timeWindowsPerSpeed;

	spikeLogTimeDecoderResponse_DIvarZd=zscore(spikeLogTimeDecoderResponse')';
	spikeLinearTimeDecoderResponse_DIvarZd=zscore(spikeLinearTimeDecoderResponse')';
	
	spikeLogTimeDecoderResponse_SpeedVarZd=zscore(spikeLogTimeDecoderResponse);
	spikeLinearTimeDecoderResponse_SpeedVarZd=zscore(spikeLinearTimeDecoderResponse);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%plots emphasizing stability
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%for col=1:size(spikeLogTimeDecoderResponse,2)
	%	timeDecoderCurrCol=spikeLogTimeDecoderResponse(:,col);
	%	rateDecoderCurrCol=spikeLinearTimeDecoderResponse(:,col);
	%end		
	meanResponsePerSpeed_LogTimeDecoder=nanmean(spikeLogTimeDecoderResponse,1);
	meanResponsePerSpeed_LinearTimeDecoder=nanmean(spikeLinearTimeDecoderResponse,1);
	%meanResponsePerSpeed_LogTimeDecoder=nanmean(spikeLogTimeDecoderResponse_DIvarZd,1);
	%meanResponsePerSpeed_LinearTimeDecoder=nanmean(spikeLinearTimeDecoderResponse_DIvarZd,1);
	
	%semResponsePerSpeed_LogTimeDecoder=getSEMacrossRows(spikeLogTimeDecoderResponse_DIvarZd);
	%semResponsePerSpeed_LinearTimeDecoder=getSEMacrossRows(spikeLinearTimeDecoderResponse_DIvarZd);
	semResponsePerSpeed_LogTimeDecoder=getSEMacrossRows(spikeLogTimeDecoderResponse);
	semResponsePerSpeed_LinearTimeDecoder=getSEMacrossRows(spikeLinearTimeDecoderResponse);

	xValues=speedValues;
	figure
	e3=shadedErrorBar(xValues,meanResponsePerSpeed_LogTimeDecoder,semResponsePerSpeed_LogTimeDecoder,'lineProps',{'b-','linewidth',5})
	hold on
	e4=shadedErrorBar(xValues,meanResponsePerSpeed_LinearTimeDecoder,semResponsePerSpeed_LinearTimeDecoder,'lineProps',{'k-','linewidth',5})
	title({'Theta Log Time Decoder vs Theta Linear Time Decoder:', 'Response Stability during Speed Changes'})

	xlabel('Running speed (cm/s)')
	ylabel('Spike rate (Hz)')
	%legend('Theta LogTime Decoder','Theta LinearTime Decoder')
	legend([e3.mainLine e4.mainLine],{'Theta Log Time Decoder','Theta Linear Time Decoder'})
	%maxFigManual2d(0.75,0.85,16)	
	maxFigManual2d(1,0.85,16)	

	saveas(gcf,fullfile(FIGURE_DIR,'stabilityGraph.tif'))
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%plot emphasizing stability via COV
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	maxDIidx=size(spikeLogTimeDecoderResponse,1)-1;
	%maxDIidx=11;
	covPerDI_LogTimeDecoder=getCOVacrossRows(spikeLogTimeDecoderResponse');
        covPerDI_LinearTimeDecoder=getCOVacrossRows(spikeLinearTimeDecoderResponse');

	figure	
	pH1=plot(diRanks(1:maxDIidx),covPerDI_LogTimeDecoder(1:maxDIidx),'b-','Linewidth',5')
	hold on
	pH2=plot(diRanks(1:maxDIidx),covPerDI_LinearTimeDecoder(1:maxDIidx),'k-','Linewidth',5')
	
	%xlabel('Running speed (cm/s)')
	xlabel('Directionality index rank (1-5040)')
        ylabel('Response variability with speed change (COV)')
        %legend('Theta LogTime Decoder','Theta LinearTime Decoder')
        legend([pH1 pH2],{'Theta Log Time Decoder','Theta Linear Time Decoder'},'Location','Best')
        maxFigManual2d(1,0.85,16)

        saveas(gcf,fullfile(FIGURE_DIR,'stabilityCOVGraph.tif'))


	%[pVal]=analyzeSummaryStatisticDiffByBootstrap(spikeLogTimeDecoderResponse(:,1),spikeLinearTimeDecoderResponse(:,1),'COV')
	for d=1:size(spikeLogTimeDecoderResponse,1)
		currTitleStr=sprintf('DI_Rank_%d, Linear_coding_COV_-_Log_coding_COV',diRanks(d));
		[pVal]=analyzeSummaryStatisticDiffByBootstrap(spikeLogTimeDecoderResponse(d,:),spikeLinearTimeDecoderResponse(d,:),'COV',currTitleStr)

		maxFigManual2d(1,0.85,16)	
		saveas(gcf,fullfile(FIGURE_DIR,sprintf('stabilityCOVGraphStats_DI%d.tif',diRanks(d))))
	end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%plot emphasizing flexibility
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%for row=1:size(spikeLogTimeDecoderResponse,1)
	%	timeDecoderCurrRow=spikeLogTimeDecoderResponse(row,:);
	%	rateDecoderCurrRow=spikeLinearTimeDecoderResponse(row,:);
	%end		
	meanResponsePerDI_LogTimeDecoder=nanmean(spikeLogTimeDecoderResponse,2);
	meanResponsePerDI_LinearTimeDecoder=nanmean(spikeLinearTimeDecoderResponse,2);
	%meanResponsePerDI_LogTimeDecoder=nanmean(spikeLogTimeDecoderResponse_SpeedVarZd,2);
	%eanResponsePerDI_LinearTimeDecoder=nanmean(spikeLinearTimeDecoderResponse_SpeedVarZd,2);

	%semResponsePerDI_LogTimeDecoder=getSEMacrossRows(spikeLogTimeDecoderResponse_SpeedVarZd');
	%semResponsePerDI_LinearTimeDecoder=getSEMacrossRows(spikeLinearTimeDecoderResponse_SpeedVarZd');
	semResponsePerDI_LogTimeDecoder=getSEMacrossRows(spikeLogTimeDecoderResponse');
	semResponsePerDI_LinearTimeDecoder=getSEMacrossRows(spikeLinearTimeDecoderResponse');


	xValues=diRanks;
	
	figure
	e1=shadedErrorBar(xValues,meanResponsePerDI_LogTimeDecoder,semResponsePerDI_LogTimeDecoder,'lineProps',{'b-','linewidth',5})
	hold on
	
	e2=shadedErrorBar(xValues,meanResponsePerDI_LinearTimeDecoder,semResponsePerDI_LinearTimeDecoder,'lineProps',{'k-','linewidth',5})
	title({'Theta Log Time Decoder vs Theta Linear Time Decoder:', 'Response Flexibility during Sequence Changes'})

	legend([e1.mainLine e2.mainLine],{'Theta Log Time Decoder','Theta Linear Time Decoder'})
	xlabel('Directionality index rank (1-5040)')
	ylabel('Spike rate (Hz)')
	maxFigManual2d(1,0.85,16)
	saveas(gcf,fullfile(FIGURE_DIR,'flexibilityGraph.tif'))

	exitStatus=1;
