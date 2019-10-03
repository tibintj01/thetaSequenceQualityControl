function [done] = runSingleSimulation(arglist)
%function [done] = runSingleSimulation(val1,val2,paramName1,paramName2,objName1,objName2,scanDescr)
	saveResults=1;
	plotV=1;

	directory_names
	disp('running simulation for....')
	paramName1=arglist{3}
	paramName2=arglist{4}
	val1=arglist{1}
	val2=arglist{2}
	objName1=arglist{5};
	objName2=arglist{6};
	scanDescr=arglist{7};
	runDir=arglist{8};
	originalDir=arglist{9};
	rngSeed=arglist{10};


	rng(rngSeed)
	cd(runDir)		
	%disp(sprintf('running simulation for %s = %s, %s = %s.......',))
	%clear classes
	addMatlabCodeBasePaths	
	%startup
	done=0;

	%newSimConfig=SimConfiguration('default');
	newSimConfig=SimConfiguration('default',rngSeed);
	%newSimConfig.printConfig()



	overrideParamValues=[val1,val2];

	overrideParamNames={paramName1,paramName2};

	searchModifyInfo.overrideParamValues=overrideParamValues;
	searchModifyInfo.overrideParamNames=overrideParamNames;
	
	searchModifyInfo.modifiedObjName1=objName1;
	searchModifyInfo.modifiedObjName2=objName2;
	searchModifyInfo.batchCategory=scanDescr;
	
	newSim=Simulation(newSimConfig,searchModifyInfo);


	newSim.run()

	if(plotV)	
		newSim.dispV_traces()

		if(rngSeed<10)
			saveas(gcf,sprintf('%ssimV000%d.tif',FIGURE_DIR,rngSeed))
		elseif(rngSeed<100)
			saveas(gcf,sprintf('%ssimV00%d.tif',FIGURE_DIR,rngSeed))
		elseif(rngSeed<1000)
			saveas(gcf,sprintf('%ssimV0%d.tif',FIGURE_DIR,rngSeed))
		elseif(rngSeed<10000)
			saveas(gcf,sprintf('%ssimV%d.tif',FIGURE_DIR,rngSeed))
		end
	end

	if(saveResults)	
		newSim.save()
	else
		pause(3)
	end
	cd(originalDir)
	done=1;
