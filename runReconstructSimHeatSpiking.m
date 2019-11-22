scanParamNames={'DI_SORTED_PERM_RANK','CONSTANT_RUN_SPEED','USE_LINEAR_DELAYS'}

%scanParam1Values=[1, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5040];
%scanParam2Values=linspace(15,45,16);
scanParam1Values=[1, 1000, 2000, 3000, 4000, 5000, 5040];
scanParam2Values=linspace(15,45,64);
%scanParam3Values=[0];
scanParam3Values=[0,1];

exitStatus=reconstructAnalysisOfSimBatchSpiking(scanParamNames{1},scanParamNames{2},scanParamNames{3},scanParam1Values,scanParam2Values,scanParam3Values);
