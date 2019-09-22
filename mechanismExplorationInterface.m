
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Goal: 
%a) identify potential sources/encoding of phase/position update 
%b) characterize their inductive biases in the face of noise and realistic inputs
%---dynamic range of sequence slope to running speed vs heterogeneity etc.
%---spike timing jitter in fraction of cells? - different curves (fraction jitter vs sequence quality) for diff heterogeneity, etc.
% 
%c) decide which one is most adaptive and/or make predictions from each one to help distinguish
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear classes
close all
clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set up simulation parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

newSimConfig=SimConfiguration('default');
%newSimConfig.printConfig()

newSim=Simulation(newSimConfig);

newSimBatch=SimulationBatch(newSim);

%newSimBatch.simArray


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%run simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('***************running simulations*********************')
tic
%newSim.run()
newSimBatch.run()

newSimBatch.displayContent()
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%visualize results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('***************plotting results***********************')

tic
newSimBatch.displayResults()
toc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%analyze results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('***************analyzing results**********************')
tic
%newSimBatch.runAnalysis()
toc

%{
%codingEvalProps=setCodingEvalProps(newSim);
phaseCodingEvaluationObj=SimPhaseCodingEvaluation(simObj);

tic
phaseCodingEvaluationObj.visualizePhaseCoding();
toc
%}
disp('******************************************************')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save results for later access
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('***************saving results**********************')

tic
% displayRegex('Fig*tif')
%newSim.save()
%phaseCodingEvaluationObj.save()
toc
disp('******************************************************')


