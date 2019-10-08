figRaster=figure;

%subplot(thisObj.numSimsPerVar,thisObj.numSimsPerVar,count)
axRaster1=subplot(10,10,[1 50]);
phaseCodingEvaluationObj.runPlotRaster(figRaster);
xticklabels({})
xlabel('')

title(removeUnderscores(thisObj.simArray(i,j).simParamsIDStr))
%maxFigManual2d(10,3,18)


if(ThetaPopInput.amplitudeDefault>0)
	figure(figRankTransform)
	subplot(thisObj.numSimsPerVar,thisObj.numSimsPerVar,count)
	phaseCodingEvaluationObj.runRankTransformAnalysis(figRankTransform);

	figure(figPhasePosCoding)
	%subplot(thisObj.numSimsPerVar,thisObj.numSimsPerVar,count)
	phaseCodingEvaluationObj.runPhaseCodeAnalysis(figPhasePosCoding,figSpaceCompress);
end

%figPhaseDistr=figure;
figure(figRaster)
%subplot(thisObj.numSimsPerVar,thisObj.numSimsPerVar,count)
%phaseCodingEvaluationObj.runSpikeTimeDistributionAnalysis(figPhaseDistr);
axRaster2=subplot(10,10,[51 60]);
phaseCodingEvaluationObj.runSpikeTimeDistributionAnalysis(figRaster);
%title(removeUnderscores(thisObj.simArray(i,j).simParamsIDStr))
thisObj.simArray(i,j).thetaPopInputObj.addTroughLines(figRaster);
ylabel('spike count')
xticklabels({})
xlabel('')

axRaster3=subplot(10,10,[61 70]);
thetaSample=squeeze(thisObj.simArray(i,j).thetaPopInputObj.conductanceTimeSeries(1,1,:));
xticklabels({})
xlabel('')
ylabel('Theta inh_g')
simTimeAxis=thisObj.simArray(i,j).configuration.simParams.timeAxis;
decFactor=1;
plot(simTimeAxis(1:decFactor:end),thetaSample(1:decFactor:end),'Color','b','LineWidth',3)
xticklabels({})
xlabel('')

%axRaster4=subplot(10,10,[71 80]);
axRaster4=subplot(10,10,[71 100]);
thisObj.simArray(i,j).externalInputObj.displayContentSubplot(figRaster);
%xticklabels({})
%xlabel('')

%axRaster5=subplot(10,10,[81 100]);

%ylabel('Output unit V_m')
xlabel('Time (msec)')

xlim([0 simTimeAxis(end)])
%linkaxes([axRaster1 axRaster2 axRaster3 axRaster4 axRaster5],'x')
linkaxes([axRaster1 axRaster2 axRaster3 axRaster4],'x')
%axes(axRaster3)
xlim([0 simTimeAxis(end)])
linkaxes([axRaster1 axRaster2 axRaster3 axRaster4],'x')
