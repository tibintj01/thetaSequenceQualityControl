import os
#scanParamNames=['currAmp','gL']
#Order should match name in file, e.g. SCAN_PARAM1 vs2
#scanParamNames=['currAmp','CONSTANT_RUN_SPEED']
scanParamNames=['DI_SORTED_PERM_RANK','CONSTANT_RUN_SPEED','USE_LINEAR_DELAYS']

#scanDescr='timeConstantAndPhaseCodingWithNoiseWeakerTheta'
#scanDescr='testControlledFlexibility'
#scanDescr='stabilityVsFlexibilityHeatMap'
scanDescr='backToIntegrator'
simName=scanDescr

#basePath='/Users/tibinjohn/thetaSeq/thetaSequenceQualityControl/'
#basePath='./'
basePath=os.getcwd()+'/'

protoClassName1='CurrentInjectorsProto'
protoClassName2='ExternalEnvironmentProto'
protoClassName3='FeedForwardConnectivityProto'
#protoClassName2='CellsTwoLayerProto'
#protoClassName2='CellsProto'

modifiedClassName1='CurrentInjectors'
modifiedClassName2='ExternalEnvironment'
modifiedClassName3='FeedForwardConnectivity'
#modifiedClassName2='Cells'

modifiedObjName1='externalInputObj'
modifiedObjName2='externalEnvObj'
modifiedObjName3='feedforwardConnObj'
#modifiedObjName2='cellsObj'

protoFilePaths=[basePath+protoClassName1+'.m',basePath+protoClassName2+'.m',basePath+protoClassName3+'.m']
filePaths=[basePath+modifiedClassName1+'.m',basePath+modifiedClassName2+'.m',basePath+modifiedClassName3+'.m']
