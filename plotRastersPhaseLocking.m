close all
dataDir='/Users/tibinjohn/thetaSeq/results/single_cell_phase_preference/raw_data';

filePaths=getRegexFilePaths(dataDir,'*mat');

bias_values=newSimBatch.searchParamVectors.currAmp;
gLeak_values=newSimBatch.searchParamVectors.gl;

for fileNum=1:length(filePaths)
    currFilePath=filePaths{fileNum};
    currData=load(currFilePath);
    currData=currData.thisObj;
    
    currInjBias=currData.currentModifyInfo.overrideParamValues(1);
    currGleak=currData.currentModifyInfo.overrideParamValues(2);
     [~,biasIdx]=min(abs(bias_values-currInjBias));
    [~,gLeakIdx]=min(abs(gLeak_values-currGleak));
    
    figure(gLeakIdx)
   
    currSpikeTimes=currData.cellsObj.spikeTimes;
    plot(currSpikeTimes,currInjBias*ones(size(currSpikeTimes)),'k.','MarkerSize',7)
    hold on
    
      currR=1/currGleak;
      currCm=1.0; %uF/cm^2
      
       tau_mem=currR*currCm;
    title(sprintf('Membrane time constant: %.2f msec',tau_mem))
    ylabel('Inj curr bias')
    xlabel('Time (msec)')
    %fds
end




