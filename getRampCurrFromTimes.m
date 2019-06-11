function [injCurr,rampPeakTime]=getRampCurrFromTimes(timeAxis,rampStartTime,rampEndTime,baseDrive,peakDrive)

rampPeakTime=rampStartTime+0.75*(rampEndTime-rampStartTime);
numPtsBase=length(find(timeAxis<rampStartTime));
numPtsRampUp=length(find(timeAxis>rampStartTime & timeAxis<rampPeakTime));
numPtsRampDown=length(find(timeAxis>rampPeakTime & timeAxis<rampEndTime));
numPtsPost=length(timeAxis)-numPtsRampUp-numPtsRampDown-numPtsBase;

baseI=linspace(baseDrive,baseDrive,numPtsBase);
rampUp=linspace(baseDrive,peakDrive,numPtsRampUp);
rampDown=linspace(peakDrive,baseDrive,numPtsRampDown);
postI=linspace(baseDrive,baseDrive,numPtsPost);
injCurr=[baseI(:) ; rampUp(:); rampDown(:); postI(:)];
