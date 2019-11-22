function [] = saveSimFig(fH,descrStr,rngSeed,simObj,extraWidth)

	if(~exist('extraWidth'))
		extraWidth=0;
	end

	directory_names	

	figure(fH)	
	title(removeUnderscores(simObj.simParamsIDStr))
	if(extraWidth)
		maxFigManual2d(1.5,1.2,16)
	else
		maxFigManual2d(4,1.2,24)
	end

	if(rngSeed<10)
		saveas(fH,sprintf('%ssim_%s_000%d.tif',FIGURE_DIR,descrStr,rngSeed))
	elseif(rngSeed<100)
		saveas(fH,sprintf('%ssim_%s_00%d.tif',FIGURE_DIR,descrStr,rngSeed))
	elseif(rngSeed<1000)
		saveas(fH,sprintf('%ssim_%s_0%d.tif',FIGURE_DIR,descrStr,rngSeed))
	elseif(rngSeed<10000)
		saveas(fH,sprintf('%ssim_%s_%d.tif',FIGURE_DIR,descrStr,rngSeed))
	end
	close(fH)
