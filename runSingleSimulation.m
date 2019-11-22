function [done] = runSingleSimulation(arglist)
%function [done] = runSingleSimulation(val1,val2,paramName1,paramName2,objName1,objName2,scanDescr)
	saveResults=1;
	plotV=0;

	directory_names
	disp('running simulation for....')
	paramName1=arglist{4}
	paramName2=arglist{5}
	paramName3=arglist{6}
	val1=arglist{1}
	val2=arglist{2}
	val3=arglist{3}
	objName1=arglist{7};
	objName2=arglist{8};
	objName3=arglist{9};

	scanDescr=arglist{10};
	runDir=arglist{11};
	originalDir=arglist{12};
	rngSeed=arglist{13};

	batchName=arglist{14};
	simIDnum=arglist{15};

	rng(rngSeed)
	cd(runDir)		
	%disp(sprintf('running simulation for %s = %s, %s = %s.......',))
	%clear classes
	addMatlabCodeBasePaths	
	%startup
	done=0;

	%newSimConfig=SimConfiguration('default');
	newSimConfig=SimConfiguration(batchName,rngSeed);
	%newSimConfig.printConfig()

	overrideParamValues=[val1,val2,val3];

	overrideParamNames={paramName1,paramName2,paramName3};

	searchModifyInfo.overrideParamValues=overrideParamValues;
	searchModifyInfo.overrideParamNames=overrideParamNames;
	
	searchModifyInfo.modifiedObjName1=objName1;
	searchModifyInfo.modifiedObjName2=objName2;
	searchModifyInfo.modifiedObjName3=objName3;

	searchModifyInfo.batchCategory=scanDescr;
	
	newSim=Simulation(newSimConfig,searchModifyInfo);


	newSim.run()

	if(plotV)	
		newSim.dispV_traces()
	end

	if(saveResults)	
		[fH,fpH,fsH,fstmH]=newSim.visualizeSpikeTimings()
		%maxFigManual2d(1.5,1.1,16)
		%saveSimFig(fH,'rasters',simIDnum,newSim)
		[fCurrDiff]=newSim.externalInputObj.displayInputDiffVsPos(newSim.externalEnvObj);

		saveSimFig(fH,'rasters',simIDnum,newSim,1)
		%saveSimFig(fpH,'phasePosition',simIDnum,newSim)
		saveSimFig(fstmH,'thetaSeqTemplateMatchingPerCycle',simIDnum,newSim)
		saveSimFig(fsH,'spaceCompression',simIDnum,newSim)
		saveSimFig(fCurrDiff,'inputDiffVsPos',simIDnum,newSim)
		
	end

	if(saveResults)	
		newSim.save()
	end
	cd(originalDir)
	done=1;
