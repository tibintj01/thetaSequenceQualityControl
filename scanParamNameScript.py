import os
scanParamNames=['currAmp','gL']

#scanDescr='timeConstantAndPhaseCodingWithNoiseWeakerTheta'
scanDescr='testLayer2TimingDecoder'
simName=scanDescr

#basePath='/Users/tibinjohn/thetaSeq/thetaSequenceQualityControl/'
#basePath='./'
basePath=os.getcwd()+'/'

protoClassName1='CurrentInjectorsProto'
protoClassName2='CellsTwoLayerProto'
#protoClassName2='CellsProto'

modifiedClassName1='CurrentInjectors'
modifiedClassName2='Cells'

modifiedObjName1='externalInputObj'
modifiedObjName2='cellsObj'

protoFilePaths=[basePath+protoClassName1+'.m',basePath+protoClassName2+'.m']
filePaths=[basePath+modifiedClassName1+'.m',basePath+modifiedClassName2+'.m']
