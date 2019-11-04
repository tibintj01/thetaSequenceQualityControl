'''Description
Searches for SCAN_PARAM# literal strings in m-script code base and creates a new mscript
for each value in vectors to be able to run different versions of Simulation and store results

Then runs simulation m-scripts
'''
import time

print('started')

start=time.perf_counter()

import numpy as np
import pdb; 
from multiprocessing import Pool
#import scipy.io
#import subprocess
#import os


import matlab.engine
	
#scanParam1Values=np.linspace(2.6,3.6,120)
#scanParam1Values=np.linspace(2.6,3.6,500)
#scanParam1Values=np.linspace(3,7.5,1)
#scanParam2Values=np.linspace(1,31,1)
#scanParam1Values=np.linspace(5,7.5,1)
#scanParam1Values=np.linspace(3,5,1)
#scanParam1Values=np.linspace(5,5,1)
#scanParam1Values=np.linspace(7.5,7.5,1) #amp
#scanParam2Values=np.linspace(10,31,1)
#scanParam2Values=np.linspace(20,20,1)
#scanParam2Values=np.linspace(30,30,1)

#scanParam1Values=[1, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5040]
scanParam1Values=[1]
#scanParam1Values=np.linspace(1,1,1)
#scanParam1Values=np.linspace(5040,5040,1)

#scanParam1Values=list(range(5,40,5))
#scanParam2Values=np.linspace(20,20,1)
#scanParam2Values=np.linspace(30,60,2)
scanParam2Values=np.linspace(40,40,1)
#scanParam2Values=np.linspace(15,45,400)
#scanParam2Values=[10,20,40,50]

scanParam3Values=[0,1]
#scanParam2Values=np.linspace(50,50,1)
#scanParam2Values=np.linspace(10,10,1)
#scanParam2Values=np.linspace(30,30,1)
#scanParam2Values=np.logspace(np.log10(0.005),np.log10(0.03),30)
#scanParam1Values=np.linspace(15,25,1)
#scanParam2Values=np.logspace(np.log10(0.005),np.log10(0.03),3)
#scanParam2Values=np.logspace(np.log10(0.01),np.log10(0.2),1)

#REDEPLOY=1;
#REDEPLOY=0;
#import scanParamNameScript
exec(open("scanParamNameScript.py").read());
exec(open("directory_names_Python.py").read());

if REDEPLOY==1:
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
	#scanParam1Values=np.linspace(2,10,30)
	#scanParam1Values=np.linspace(2,10,32)
	#scanParam1Values=np.linspace(1.5,2.5,32)
	#scanParam1Values=np.linspace(1,2,32)
	#scanParam1Values=np.linspace(1,1.7,32)
	#scanParam1Values=np.linspace(1.7,2.5,32)
	#scanParam1Values=np.linspace(2.5,3.5,32)
	#scanParam2Values=np.linspace(0.005,0.1,20)
	#scanParam2Values=np.linspace(0.006,0.0125,20)
	#scanParam2Values=[0.005,0.1]

	CODE_BASE_DIR=os.getcwd()

	originalFileStrings=[]

	for k,fileName in enumerate(protoFilePaths):	
		with open(fileName,'r+') as f:
			fileStr=f.read();
			originalFileStrings.append(fileStr)
	
	os.system('cp CellsTwoLayerProto.m Cells.m')
	os.system('cp ExternalEnvironmentProto.m ExternalEnvironment.m')
	os.system('cp FeedForwardConnectivityProto.m FeedForwardConnectivity.m')

	#generate modifed files to loop through in parallel 
	#with own subdirectories to maintain file naming
	arglists=[]

	for i,scanParam1Value in enumerate(scanParam1Values): 
		for j,scanParam2Value in enumerate(scanParam2Values): 
			for k,scanParam3Value in enumerate(scanParam3Values): 
				#make new running directory in no snap shot path
				runDirPath='%s%s_%d_%d_%d' % (BASE_RUN_DIR,scanDescr,i,j,k)
				os.system('mkdir -p %s' % runDirPath)
				#os.chdir(runDirPath)
				#rngSeed=(i+1)*(j+1)*(k+1)
				#rngSeed=int(str(i+1)+str(j+1)+str(k+1))
				rngSeed=int(str(i+1)+str(j+1))
				simIDnum=int(str(i+1)+str(j+1)+str(k+1))
			
				#replace files with current parameters filled in
				for l,filePath in enumerate(filePaths):	
					currFileStr=originalFileStrings[l]

					placeHolderStr1='SCAN_PARAM1'
					placeHolderStr2='SCAN_PARAM2'
					placeHolderStr3='SCAN_PARAM3'

					newFileStr=currFileStr.replace(placeHolderStr1,str(scanParam1Value))
					newFileStr=newFileStr.replace(placeHolderStr2,str(scanParam2Value))
					newFileStr=newFileStr.replace(placeHolderStr3,str(scanParam3Value))
				
					if(newFileStr == currFileStr):
						raise ValueError('Scripts were not modified!')

					#clear old
					with open(filePath,'r+') as f:
						f.truncate(0)
						f.write(newFileStr)
				#copy to this parameter settings' run directory
				os.system('cp *.m %s' % runDirPath)	
				os.system('cp *.mat %s' % runDirPath)	
				#pdb.set_trace()

			#scipy.io.savemat('./%s_%s_%.10f_%s_%.10f.mat' % (scanDescr, scanParamNames[0],float(scanParam1Value), scanParamNames[1],float(scanParam2Value)), mdict={'scanParam1Value': float(scanParam1Value), 'scanParam2Value': float(scanParam2Value), 'scanParamName1': scanParamNames[0], 'scanParamName2': scanParamNames[1], 'modifiedObjName1': modifiedObjName1, 'modifiedObjName2' : modifiedObjName2, 'scanDescr':scanDescr })
			#scipy.io.savemat('currSimParams.mat', mdict={'scanParam1Value': float(scanParam1Value), 'scanParam2Value': float(scanParam2Value), 'scanParamName1': scanParamNames[0], 'scanParamName2': scanParamNames[1], 'modifiedObjName1': modifiedObjName1, 'modifiedObjName2' : modifiedObjName2, 'scanDescr':scanDescr })
			#arglists.append([scanParam1Value,scanParam2Value,scanParamNames[0],scanParamNames[1], modifiedObjName1, modifiedObjName2, scanDescr])
			#arglists.append([float(scanParam1Value),float(scanParam2Value),scanParamNames[0],scanParamNames[1],modifiedObjName1,modifiedObjName2,scanDescr, runDirPath,CODE_BASE_DIR,int(rngSeed)])
				#arglists.append([float(scanParam1Value),float(scanParam2Value),float(scanParam3Value),scanParamNames[0],scanParamNames[1],scanParamNames[2],modifiedObjName1,modifiedObjName2,modifiedObjName3,scanDescr, runDirPath,CODE_BASE_DIR,int(rngSeed),simName])
				arglists.append([float(scanParam1Value),float(scanParam2Value),float(scanParam3Value),scanParamNames[0],scanParamNames[1],scanParamNames[2],modifiedObjName1,modifiedObjName2,modifiedObjName3,scanDescr, runDirPath,CODE_BASE_DIR,int(rngSeed),simName,simIDnum])

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


	p=Pool(NUM_CORES)
	print(p.map(runMatlabScript,arglists))

	#for a in arglists:
	#	exitStatus=eng.runSingleSimulation(a)

	finish=time.perf_counter()


	print(f'Finished in {round(finish-start,2)} seconds')

	print('removing run directory copies....')
	for i,scanParam1Value in enumerate(scanParam1Values):
		for j,scanParam2Value in enumerate(scanParam2Values):
			for k,scanParam3Value in enumerate(scanParam3Values):
				#make new running directory in no snap shot path
				runDirPath='%s%s_%d_%d_%d' % (BASE_RUN_DIR,scanDescr,i,j,k)
				os.system('rm -r %s' % runDirPath)

	os.chdir(basePath)

###############################
#postParallelProcessing
###############################

#construct heatmaps of model responses when varying speed vs order (stability and flexibility)


eng=matlab.engine.start_matlab()

exitStatus=eng.runAnalysisOfSimBatch(scanParamNames[0],scanParamNames[1],scanParamNames[2],[float(i) for i in scanParam1Values],[float(i) for i in scanParam2Values],[float(i) for i in scanParam3Values])

#exitStatus=eng.plotRastersPhaseLocking([float(i) for i in scanParam1Values],[float(i) for i in scanParam2Values])		
'''
if 'Users/tibinjohn' in os.getcwd():
	os.system("open %s*tif" % FIGURE_DIR)
else:
	os.system(". disp.sh %s*tif&" % FIGURE_DIR)
'''
