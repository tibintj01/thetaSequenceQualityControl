%DATA_DIR='/Users/tibinjohn/thetaSeq/results/timeConstantAndPhaseCoding/raw_data';
%DATA_DIR='../results/timeConstantAndPhaseCoding/raw_data';
%simName='timeConstantAndPhaseCodingWithNoise'
simName='testLayer2TimingDecoder'

if(onLocalComputer())
	DATA_DIR=sprintf('/Users/tibinjohn/thetaSeq/results/%s/raw_data/',simName);
	PROCESSED_DATA_DIR=sprintf('/Users/tibinjohn/thetaSeq/results/%s/processed_data',simName);
	FIGURE_DIR=sprintf('/Users/tibinjohn/thetaSeq/results/%s/figures/',simName);
	BASE_RUN_DIR=sprintf('/Users/tibinjohn/thetaSeq/tempRunDir');
else
	DATA_DIR=sprintf('/scratch/ojahmed_fluxm/tibintj/results/%s/raw_data/',simName);
	PROCESSED_DATA_DIR=sprintf('/scratch/ojahmed_fluxm/tibintj/results/%s/processed_data',simName);
	FIGURE_DIR=sprintf('/scratch/ojahmed_fluxm/tibintj/results/%s/figures/',simName);
	BASE_RUN_DIR=sprintf('/nfs/turbo/lsa-ojahmed-nosnap/temp_run_dir_tibin')
end

DATA_DIR
PROCESSED_DATA_DIR
FIGURE_DIR

