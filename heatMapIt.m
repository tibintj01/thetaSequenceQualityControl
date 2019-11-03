function [] = heatMapIt(heatMapInput)
		%unpack input struct
		heatMatrix=heatMapInput.heatMatrix;
		modelResponseVarName=heatMapInput.modelResponseVarName;
		climVals=heatMapInput.climVals;
		diRanks=heatMapInput.diRanks;
		speedValues=heatMapInput.speedValues;
		titleStr=heatMapInput.titleStr;

		%plot heat map
		%omarPcolor(diRanks,speedValues,heatMatrix)
		omarPcolor(diRanks,speedValues,heatMatrix')
                title(removeUnderscores(titleStr))
                xlabel('Directionality Index Rank')
                ylabel('Running speed (cm/s)')
                cb=colorbar
		colormap(jet)
                ylabel(cb,modelResponseVarName)
                caxis(climVals)

		axis square

		maxFigManual2d(0.8,0.75,16)
		saveas(gcf,[titleStr '_SpikeCountFlexAndStableHeatMap.tif'])
