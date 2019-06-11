%parameter settings of cortical neuron model from Fink et al Ach paper 2013
%set model parameters
%avgIDrive=0.08; %high Ach

%1.131 doesn't elicit repetitive spiking (doesn't spike after pulse)
%avgIDrive=1.135; %low Ach
%avgIDrive=8;
avgIDrive=3;
avgIDrive=0;
%avgIDrive=1.30; %low Ach
%avgIDrive=1.50; %low Ach
iDrive_sig=0.15;
iDrive_sig=0.0;
iDrive=normrnd(avgIDrive,iDrive_sig,numCells,1)

baseDrive=0;
%peakDrive=10;
%peakDrive=10;
peakDrive=1.3;
peakDrive=1.8;
peakDrive=2.8;
%peakDrive=3.1;
peakDrive=5;
peakDrive=6;
%peakDrive=8;
rampStartTime=500;
rampEndTime=1500;
rampEndTime=1800;
gSi=1;
gSi=0.2;
gSi=0.5;
gSi=0.15;
gSi=0.2;
gSi=0.5;

gSe=gSi/2;
%gSe=0;
%gSe=gSi/5;
%gSe=gSi/8;

%specific membrane resistance 30,000 ohm-cm^2 (Gm=0.033mS/cm^2)
% i.e. leak current
%gl=0.033;        %mS/cm^2
gl=0.033*8;        %mS/cm^2
gl=0.033*5;        %mS/cm^2
gl=0.033*6;        %mS/cm^2
%gl=0.033*10;        %mS/cm^2
%gl=0.033*6;        %mS/cm^2
%gl=0.033*3;        %mS/cm^2
%el=-70;         %mV "normally -70 mV but adjusted to keep resting membrane potential near -66 mV." (Leung, 2011)
%el=-50;         %mV
el=-60;         %mV "normally -70 mV but adjusted to keep resting membrane potential near -66 mV." (Leung, 2011)

esynI=-72; %fig 6 page, cl- reversal potential
esynE=0;

driveFreq=8/1000; %kHz

%attenuateFactor=8;
attenuateFactor=8;
Si=0.2/attenuateFactor;
Si=gSi/attenuateFactor;
%Si=0.1/attenuateFactor;
%Se=0.1/attenuateFactor;
%Se=0.1/attenuateFactor;
%Se=0.05/attenuateFactor;
%Se=0.2/attenuateFactor;
%Se=0.1/attenuateFactor;
Se=gSe/attenuateFactor;
baseGinh=Si;

baseGexc=Se;
phi=(60/180)*pi; %60 degree shift with inhib
%phi=(0/180)*pi; %60 degree shift with inhib
g_Inh=Si*sin(2*pi*driveFreq*timeAxis)+baseGinh;
g_Exc=Se*sin(2*pi*driveFreq*timeAxis+phi)+baseGexc;

thetaPeriod=1/driveFreq;

%rampEndTime=1000;
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

%figure
%plot(timeAxis,g_Inh,'g')
%hold on
%plot(timeAxis,g_Exc,'b')

%figure
%plot(timeAxis,injCurr)
%fds

%Leung, 2011 - "A model of intracellular theta phase precession dependent on intrinsic subthreshold membrane currents"
cm=1.0; %uF/cm^2

%fast Na;
%gna=24.0;       %mS/cm^2
gna=60.0;       %mS/cm^2
%gna=0;       %mS/cm^2
%gna=22.0;       %mS/cm^2
%ena=55;
ena=58;


%HERE
%naM_Vt=-30.0;
naM_Vt=-34; %normal spiking, corresponds to VNaD in Leung, 2011, pg 12285
naM_Vt=-35; %push thresh down a bit - 12/3/18
%naM_Vt=-32; %without spiking, corresponds to VNaD in Leung, 2011, pg 12285
%naM_Vt=-30; %without spiking, corresponds to VNaD in Leung, 2011, pg 12285
%naM_Vt=100; %without spiking, corresponds to VNaD in Leung, 2011, pg 12285
naM_Gain=4.5;

%naH_Vt=-53.0;
naH_Vt=-40;
%naH_Gain=7.0;
naH_Gain=3;

%naTauH_offset=0.37;
%naTauH_Vt=-40.5;
%naTauH_Gain=6;
%naTauH_Range=2.78;

%delayed rectifier
%gk=3.0;         %mS/cm^2
gk=15;         %mS/cm^2
%gk=25.0;         %mS/cm^2
%ek=-90;         %mV
ek=-85;         %mV
kdrN_Vt=-30.0;
%kdrN_Gain=-10;
kdrN_Gain=-13;

%kdrTauN_offset=0.37;
%kdrTauN_Vt=-27.0;
%kdrTauN_Gain=15;
%kdrTauN_Range=1.85;
 
%KS
%gks=0;   %mS/cm^s, high ACh
%gks=1.5;   %mS/cm^s, low ACh
%z_Vt=-39;
%z_Gain=-5;



      %%%%%%%%%%%%%%%%%%%%%%%%%
      %I_A parameters
      %%%%%%%%%%%%%%%%%%%%%%%%%
      %activation gate
      %distal
      %kaM_Vt=-34.4;
      %kaM_Gain=-21;
	fka=1 %from Table 1, Leung, 2011 (but see text on pg 12284)
      %proximal
      kaM_Vt=-21.3;
      kaM_Gain=-35;
      
      %inactivation gate
      kaH_Vt=-58;
      kaH_Gain=8.2;



      %%%%%%%%%%%%%%%%%%%%
      %I_h parameters
      %%%%%%%%%%%%%%%%%%%%
      gh=0.2; %0.2mS/cm^2
      eh=-30;
      fh=0.2;  %from Table 1, Leung, 2011 (but see text on pg 12284)
