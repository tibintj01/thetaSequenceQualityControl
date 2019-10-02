function [exitStatus]=plotRastersPhaseLocking(bias_values,gLeak_values)

directory_names
addMatlabCodeBasePaths
close all

if(~exist('bias_values'))
    bias_values=linspace(2,7,120)
    %gLeak_values=logspace(log10(0.005),log10(0.2),1)
    gLeak_values=logspace(log10(0.05),log10(0.2),1)
    %bias_values=linspace(3,11,50)
    %gLeak_values=linspace(0.006,0.0125,20)
    %linspace(3,11,50)
	%linspace(0.006,0.0125,20)
    %bias_values=linspace(0,10,50);
    %gLeak_values=linspace(0.005,0.05,5);
end


dataDir=DATA_DIR 

if(iscell(bias_values))
	bias_values=cell2mat(bias_values);
end
if(iscell(gLeak_values))
	gLeak_values=cell2mat(gLeak_values);
end



filePaths=getRegexFilePaths(dataDir,'*mat');

%bias_values=newSimBatch.searchParamVectors.currAmp;
%gLeak_values=newSimBatch.searchParamVectors.gl;

%bias_values=
%gLeak_values=


for fileNum=1:length(filePaths)
    currFilePath=filePaths{fileNum};
    currData=load(currFilePath);
    currData=currData.thisObj;

    
	simTime=currData.configuration.simParams.simTime;    
    currInjBias=currData.currentModifyInfo.overrideParamValues(1);
    currGleak=currData.currentModifyInfo.overrideParamValues(2);
	  [~,biasIdx]=min(abs(bias_values-currInjBias));
    [~,gLeakIdx]=min(abs(gLeak_values-currGleak));
      
	currR=1/currGleak;
      currCm=1.0; %uF/cm^2
       tau_mem=currR*currCm;
   %if(currInjBias>5)
	%	fds
	%end
    
    fH=figure(gLeakIdx)
    figNameList{gLeakIdx}=sprintf('BiasVsSpikePhases_TauM_%.2fmsec',tau_mem);  
   
    currSpikeTimes=currData.cellsObj.spikeTimes;
    plot(currSpikeTimes,currInjBias*ones(size(currSpikeTimes)),'k.','MarkerSize',7)
    hold on
    
    currData.thetaPopInputObj.addTroughLines(fH)
    
    title(sprintf('Membrane time constant: %.2f msec',tau_mem))
    ylabel('Inj curr bias')
    xlabel('Time (msec)')
    

    ylim([bias_values(1) bias_values(end)])
    xlim([0 simTime])
    %fds
end

saveAllOpenFiguresWithIDs(FIGURE_DIR,figNameList)

exitStatus=1;
