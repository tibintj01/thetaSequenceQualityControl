'''Description
Searches for SCAN_PARAM# literal strings in m-script code base and creates a new mscript
for each value in vectors to be able to run different versions of Simulation and store results

Also replaces PARAM_SCAN_DESCR literal strings with description of parameter scan being done
and the role of a particular m-script within that scan

Then runs simulation m-scripts
'''
import numpy as np
import pdb; 
import matlab.engine
eng=matlab.engine.start_matlab()		

scanParamNames=['currAmp','gL']

scanDescr='timeConstantAndPhaseCoding'

#basePath='/Users/tibinjohn/thetaSeq/thetaSequenceQualityControl/'
basePath='./'

protoClassName1='CurrentInjectorsProto'
protoClassName2='CellsProto'

modifiedClassName1='CurrentInjectors'
modifiedClassName2='Cells'

modifiedObjName1='externalInputObj'
modifiedObjName2='cellsObj'

protoFilePaths=[basePath+protoClassName1+'.m',basePath+protoClassName2+'.m']
filePaths=[basePath+modifiedClassName1+'.m',basePath+modifiedClassName2+'.m']

numParams=len(scanParamNames)

#scanParamValues=[(x,y) for x in [,] for y in [,]]
#scanParam1Values=np.linspace(0,40,20)
#scanParam1Values=np.linspace(20,30,50)
#scanParam1Values=np.linspace(3,11,50)
scanParam1Values=np.linspace(2,10,50)
scanParam2Values=np.logspace(np.log10(0.005),np.log10(0.2),50)
#scanParam2Values=np.linspace(0.005,0.1,20)
#scanParam2Values=np.linspace(0.006,0.0125,20)
#scanParam2Values=[0.005,0.1]

originalFileStrings=[]

for k,fileName in enumerate(protoFilePaths):	
	with open(fileName,'r+') as f:
		fileStr=f.read();
		originalFileStrings.append(fileStr)


for i,scanParam1Value in enumerate(scanParam1Values): 
	for j,scanParam2Value in enumerate(scanParam2Values): 
		#replace files with current parameters filled in
		for k,filePath in enumerate(filePaths):	
			currFileStr=originalFileStrings[k]

			placeHolderStr1='SCAN_PARAM1'
			placeHolderStr2='SCAN_PARAM2'

			newFileStr=currFileStr.replace(placeHolderStr1,str(scanParam1Value))
			newFileStr=newFileStr.replace(placeHolderStr2,str(scanParam2Value))
		
			if(newFileStr == currFileStr):
				raise ValueError('Scripts were not modified!')
			print('running simulation for....')
			print(scanParam1Value,scanParam2Value)

		        #clear old file
			with open(filePath,'r+') as f:
				f.truncate(0)
				f.write(newFileStr)

		#run this version of simulation in matlab
		exitStatus=eng.runSingleSimulation(float(scanParam1Value),float(scanParam2Value),scanParamNames[0],scanParamNames[1],modifiedObjName1,modifiedObjName2,scanDescr)

exitStatus=eng.plotRastersPhaseLocking([float(i) for i in scanParam1Values],[float(i) for i in scanParam2Values])		


