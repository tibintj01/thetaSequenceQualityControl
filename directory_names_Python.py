import os

simName='timeConstantAndPhaseCodingWithNoise'

onLocalComputer=0
if '/Users/tibinjohn' in os.getcwd(): 
        onLocalComputer=1

if onLocalComputer == 1:
        DATA_DIR='/Users/tibinjohn/thetaSeq/results/%s/raw_data/' % simName
        PROCESSED_DATA_DIR='/Users/tibinjohn/thetaSeq/results/%s/processed_data' % simName
        FIGURE_DIR='/Users/tibinjohn/thetaSeq/results/%s/figures/' % simName
        BASE_RUN_DIR='/Users/tibinjohn/thetaSeq/tempRunDir/'
else
        DATA_DIR='/scratch/ojahmed_fluxm/tibintj/results/%s/raw_data/' % simName
        PROCESSED_DATA_DIR='/scratch/ojahmed_fluxm/tibintj/results/%s/processed_data' % simName
        FIGURE_DIR='/scratch/ojahmed_fluxm/tibintj/results/%s/figures/' % simName
        BASE_RUN_DIR='/nfs/turbo/lsa-ojahmed-nosnap/temp_run_dir_tibin/'
end
