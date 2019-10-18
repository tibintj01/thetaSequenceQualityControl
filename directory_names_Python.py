import os

REDEPLOY=1
#REDEPLOY=1
OVERWRITE=0

#simName='timeConstantAndPhaseCodingWithNoise'

onLocalComputer=0
if '/Users/tibinjohn' in os.getcwd():
	onLocalComputer=1

if onLocalComputer == 1:
	DATA_DIR='/Users/tibinjohn/thetaSeq/results/%s/raw_data/' % simName
	PROCESSED_DATA_DIR='/Users/tibinjohn/thetaSeq/results/%s/processed_data' % simName
	FIGURE_DIR='/Users/tibinjohn/thetaSeq/results/%s/figures/' % simName
	BASE_RUN_DIR='/Users/tibinjohn/thetaSeq/tempRunDir/'
	NUM_CORES=4;
else:
	DATA_DIR='/scratch/ojahmed_fluxm/tibintj/results/%s/raw_data/' % simName
	PROCESSED_DATA_DIR='/scratch/ojahmed_fluxm/tibintj/results/%s/processed_data' % simName
	FIGURE_DIR='/scratch/ojahmed_fluxm/tibintj/results/%s/figures/' % simName
	BASE_RUN_DIR='/nfs/turbo/lsa-ojahmed-nosnap/temp_run_dir_tibin'
	#NUM_CORES=1
	NUM_CORES=19

if REDEPLOY==1 and OVERWRITE==1:
	os.system('rm %s*mat' % DATA_DIR)
