function [] = heatMapIt(heatMapInput)
		%unpack input struct
		heatMatrix=heatMapInput.heatMatrix;
		modelResponseVarName=heatMapInput.modelResponseVarName;
		climVals=heatMapInput.climVals;
		diRanks=heatMapInput.diRanks;
		speedValues=heatMapInput.speedValues;
		titleStr=heatMapInput.titleStr;

		%plot heat map
		omarPcolor(diRanks,speedValues,heatMatrix)
                title(titleStr)
                xlabel('Directionality Index Rank')
                ylabel('Running speed (cm/s)')
                cb=colorbar
                ylabel(cb,modelResponseVarName)
                caxis(climVals)
