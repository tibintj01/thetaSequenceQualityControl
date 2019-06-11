

hilbertGinh=hilbert(-(g_Inh-mean(g_Inh))); 
%hilbertGinh=hilbert(g_Inh);
g_Inh_Phase=angle(hilbertGinh);
g_Inh_Phase = ((g_Inh_Phase/pi) + 1)/2 * 360;

%error may arise from old findpeaks.m version in ANALYSIS_CODE - change name to fix
[subTpeaks,subTpeakIdxes]=findpeaks(v(:,1))


subTpeakPhases=g_Inh_Phase(subTpeakIdxes);

subTpeakTimes=timeAxis(subTpeakIdxes);

subTpeakISI=[Inf; diff(subTpeakTimes)];

%remove outlier bunched peaks - threshold ISI half period of imposed theta rhythm
%subTpeakTimes=subTpeakTimes(subTpeakISI>median(subTpeakISI)/2);
%subTpeakIdxes=subTpeakIdxes(subTpeakISI>median(subTpeakISI)/2);
%subTpeakPhases=subTpeakPhases(subTpeakISI>median(subTpeakISI)/2);

subTpeakTimes=subTpeakTimes(subTpeakISI>thetaPeriod/4);
subTpeakIdxes=subTpeakIdxes(subTpeakISI>thetaPeriod/4);
subTpeakPhases=subTpeakPhases(subTpeakISI>thetaPeriod/4);

placeFieldTimes=subTpeakTimes(subTpeakTimes>rampStartTime & subTpeakTimes<rampPeakTime);
placeFieldPhases=subTpeakPhases(subTpeakTimes>rampStartTime & subTpeakTimes<rampPeakTime);

X=[ones(length(placeFieldTimes),1) placeFieldTimes(:)-placeFieldTimes(1)];
linFit=(X.'*X)\(X.'*placeFieldPhases(:))

phasePrecessSlope=linFit(2);
entryPhase=linFit(1);
