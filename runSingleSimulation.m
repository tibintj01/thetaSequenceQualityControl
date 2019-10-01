function [done] = runSingleSimulation(val1,val2,paramName1,paramName2,objName1,objName2,scanDescr)
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

	done=1;
