'''Description
Searches for SCAN_PARAM# literal strings in m-script code base and creates a new mscript
for each value in vectors to be able to run different versions of Simulation and store results

Then runs simulation m-scripts
'''
import time

start=time.perf_counter()

import numpy as np
import pdb; 
from multiprocessing import Pool
#import scipy.io
#import subprocess
#import os


import matlab.engine


#import scanParamNameScript
exec(open("scanParamNameScript.py").read());
exec(open("directory_names_Python.py").read());

#scanParamNames=['currAmp','gL']
#scanDescr='timeConstantAndPhaseCoding'
#basePath='/Users/tibinjohn/thetaSeq/thetaSequenceQualityControl/'
#basePath='./'
#protoClassName1='CurrentInjectorsProto'
#protoClassName2='CellsProto'
#modifiedClassName1='CurrentInjectors'
#modifiedClassName2='Cells'
#modifiedObjName1='externalInputObj'
#modifiedObjName2='cellsObj'
#protoFilePaths=[basePath+protoClassName1+'.m',basePath+protoClassName2+'.m']
#filePaths=[basePath+modifiedClassName1+'.m',basePath+modifiedClassName2+'.m']


numParams=len(scanParamNames)

#scanParamValues=[(x,y) for x in [,] for y in [,]]
#scanParam1Values=np.linspace(0,40,20)
#scanParam1Values=np.linspace(20,30,50)
#scanParam1Values=np.linspace(3,11,50)
#scanParam1Values=np.linspace(2,10,50)
#scanParam1Values=np.linspace(2,10,10)
scanParam1Values=np.linspace(2,10,30)
#scanParam2Values=np.logspace(np.log10(0.005),np.log10(0.2),50)
#scanParam2Values=np.logspace(np.log10(0.005),np.log10(0.2),5)
#scanParam2Values=np.logspace(np.log10(0.005),np.log10(0.2),1)
scanParam2Values=np.logspace(np.log10(0.05),np.log10(0.2),1)
#scanParam2Values=np.linspace(0.005,0.1,20)
#scanParam2Values=np.linspace(0.006,0.0125,20)
#scanParam2Values=[0.005,0.1]

originalFileStrings=[]

for k,fileName in enumerate(protoFilePaths):	
	with open(fileName,'r+') as f:
		fileStr=f.read();
		originalFileStrings.append(fileStr)


#generate modifed files to loop through in parallel 
#with own subdirectories to maintain file naming
arglists=[]

for i,scanParam1Value in enumerate(scanParam1Values): 
	for j,scanParam2Value in enumerate(scanParam2Values): 
		#make new running directory in no snap shot path
		runDirPath='%s%s_%d_%d' % (BASE_RUN_DIR,scanDescr,i,j)
		os.system('mkdir -p %s' % runDirPath)
		os.system('cp *.m %s' % runDirPath)	
		os.chdir(runDirPath)
	
		#replace files with current parameters filled in
		for k,filePath in enumerate(filePaths):	
			currFileStr=originalFileStrings[k]

			placeHolderStr1='SCAN_PARAM1'
			placeHolderStr2='SCAN_PARAM2'

			newFileStr=currFileStr.replace(placeHolderStr1,str(scanParam1Value))
			newFileStr=newFileStr.replace(placeHolderStr2,str(scanParam2Value))
		
			if(newFileStr == currFileStr):
				raise ValueError('Scripts were not modified!')

		        #clear old file
			with open(filePath,'r+') as f:
				f.truncate(0)
				f.write(newFileStr)



		#scipy.io.savemat('./%s_%s_%.10f_%s_%.10f.mat' % (scanDescr, scanParamNames[0],float(scanParam1Value), scanParamNames[1],float(scanParam2Value)), mdict={'scanParam1Value': float(scanParam1Value), 'scanParam2Value': float(scanParam2Value), 'scanParamName1': scanParamNames[0], 'scanParamName2': scanParamNames[1], 'modifiedObjName1': modifiedObjName1, 'modifiedObjName2' : modifiedObjName2, 'scanDescr':scanDescr })
		#scipy.io.savemat('currSimParams.mat', mdict={'scanParam1Value': float(scanParam1Value), 'scanParam2Value': float(scanParam2Value), 'scanParamName1': scanParamNames[0], 'scanParamName2': scanParamNames[1], 'modifiedObjName1': modifiedObjName1, 'modifiedObjName2' : modifiedObjName2, 'scanDescr':scanDescr })
		#arglists.append([scanParam1Value,scanParam2Value,scanParamNames[0],scanParamNames[1], modifiedObjName1, modifiedObjName2, scanDescr])
		arglists.append([float(scanParam1Value),float(scanParam2Value),scanParamNames[0],scanParamNames[1],modifiedObjName1,modifiedObjName2,scanDescr])

		#run this version of simulation in matlab
		#exitStatus=eng.runSingleSimulation(float(scanParam1Value),float(scanParam2Value),scanParamNames[0],scanParamNames[1],modifiedObjName1,modifiedObjName2,scanDescr)
		#subprocess.call([". openMatlabWithCmd.sh", "testMatlabCall('currSimParams.mat')"])
		#os.system('''. openMatlabWithCmd.sh "testMatlabCall('currSimParams.mat')"''')
		#pdb.set_trace()

#par loop

def runMatlabScript(arglist):
	#pdb.set_trace()
	print('starting matlab....')
	#eng=matlab.engine.start_matlab(background=True)		
	eng=matlab.engine.start_matlab()		
	exitStatus=eng.runSingleSimulation(arglist)
	return

#print('running simulation for....')
#print(scanParam1Value,scanParam2Value)
#print(arglists)

p=Pool(NUM_CORES)
print(p.map(runMatlabScript,arglists))

#for a in arglists:
#	exitStatus=eng.runSingleSimulation(a)

finish=time.perf_counter()

print(f'Finished in {round(finish-start,2)} seconds')

print('removing run directory copies....')
for i,scanParam1Value in enumerate(scanParam1Values):
        for j,scanParam2Value in enumerate(scanParam2Values):
                #make new running directory in no snap shot path
                runDirPath='%s%s_%d_%d' % (BASE_RUN_DIR,scanDescr,i,j)
                os.system('rm -r %s' % runDirPath)

os.chdir(basePath)
#exitStatus=eng.runSingleSimulation(arglist)
###############################
#postParallelProcessing
###############################
eng=matlab.engine.start_matlab()
exitStatus=eng.plotRastersPhaseLocking([float(i) for i in scanParam1Values],[float(i) for i in scanParam2Values])		


