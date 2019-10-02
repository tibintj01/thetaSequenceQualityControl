function [done] = runSingleSimulation(arglist)
%function [done] = runSingleSimulation(val1,val2,paramName1,paramName2,objName1,objName2,scanDescr)
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

	newSimConfig=SimConfiguration('default');
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
	newSim.save()

	cd(originalDir)
	done=1;
