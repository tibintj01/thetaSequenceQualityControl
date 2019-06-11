%clear all;  clc;
function []=hippocampalPrecessingTwoCellNetworkParFor(gnap1,gks1,gnap2,gks2,gsyn12,gsyn21,gsyn12Idx,gsyn21Idx)
saveStrID=sprintf('DIFF_PLACE_FIELD_gnap1_%.6f_gks1_%.6f_gnap2_%.6f_gks2_%.6f_gsyn12_%.6f_gsyn21_%.6f',gnap1,gks1,gnap2,gks2,gsyn12,gsyn21)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%To do:
%-pare down this code to single compartment mode -DONE
%-add Leung's extra currents -DONE
%-add driving currents, with adjustable time course -DONE
%-show phase precession -DONE 
%
%-quantify phase precession by getting actual phase sequence -DONE
%-reproduce pertinent Leung figures
%-vary gNaP and gKS and get distribution of phase precession properties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotVm=0;
disp('NEW2')
%set simulation time, stepsize
%simTime=70000	%msec
%simTime=5000	%msec
%simTime=2000	%msec
simTime=2500	%msec
%simTime=2400	%msec
%simTime=200	%msec
%dt=0.01
dt=0.005
%dt=0.0001
numSteps=round(simTime/dt);
equilibrateTime=5000;
%set randomization seed to constant
rng(1)


timeAxis=(dt:dt:simTime).';

numCells=2;


%set single neuron properties
%setDefaultParamsCorticalNeuron;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%setDefaultParamsPlaceCell;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
%rampEndTime=1500;
%rampStartTime=500;
%rampEndTime=1800;
rampStartTime1=500;
rampEndTime1=1800;

placeFieldOffset=250;
rampStartTime2=rampStartTime1+placeFieldOffset;
rampEndTime2=rampEndTime1+placeFieldOffset;
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
esyn=0; %recurrent synapses

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
%[injCurr]=getRampCurrFromTimes(timeAxis,rampStartTime,rampEndTime);
[injCurr1,rampPeakTime1]=getRampCurrFromTimes(timeAxis,rampStartTime1,rampEndTime1,baseDrive,peakDrive);
[injCurr2,rampPeakTime2]=getRampCurrFromTimes(timeAxis,rampStartTime2,rampEndTime2,baseDrive,peakDrive);

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%setCorticalNetworkProperties;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initializeCorticalNetwork;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialize model
gsyn=zeros(numSteps,numCells);
v=zeros(numSteps,numCells);
n=zeros(numSteps,numCells);
m=zeros(numSteps,numCells);

h=zeros(numSteps,numCells);
mka=zeros(numSteps,numCells);
hka=zeros(numSteps,numCells);

kappaH=zeros(numSteps,numCells);
mnap=zeros(numSteps,numCells);
nks=zeros(numSteps,numCells);

pulse=zeros(numSteps,1);

%initial conditions
v(1,:)=normrnd(-60,3,numCells,1);
n(1,:)=normrnd(0.1,0.01,numCells,1);
m(1,:)=normrnd(0.1,0.01,numCells,1);

h(1,:)=normrnd(0.1,0.1,numCells,1);
mka(1,:)=normrnd(0.1,0.1,numCells,1);
hka(1,:)=normrnd(0.1,0.1,numCells,1);

kappaH(1,:)=normrnd(0.1,0.1,numCells,1);
mnap(1,:)=normrnd(0.1,0.1,numCells,1);
nks(1,:)=normrnd(0.1,0,numCells,1);
%h(1,:)=normrnd(0.5,0.1,numCells,1);
%z(1,:)=normrnd(0.5,0,numCells,1);

totalSynapticCurrent=zeros(numSteps,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

connectivityMatrix=[0 gsyn12; gsyn21 0];
tausyn=5; %AMPA tau syn, ~ 5ms

startCouplingTime=0;


tic

iDriveRecord=zeros(numSteps,1);
totalFeedFwdSynDrive=zeros(numSteps,1);

spikeCount=0;
spikeTimes=[];
spikeCellIdxes=[];
%loop through time in dt-size steps
for step=1:numSteps-1
	%loop through cells in current time step
	for cell=1:numCells
		vSpecific=v(step,cell);
		nSpecific=n(step,cell);
		mSpecific=m(step,cell);
		hSpecific=h(step,cell);
		mkaSpecific=mka(step,cell);
		hkaSpecific=hka(step,cell);
		kappaHSpecific=kappaH(step,cell);
		mnapSpecific=mnap(step,cell);
		nksSpecific=nks(step,cell);

	%check for spike in  time step
        if(step>1 && v(step,cell)>-30 && v(step-1,cell) <-30)
            	spikeTimes=[spikeTimes; step*dt];
		if(numCells>1)
			spikeCellIdxes=[spikeCellIdxes; cell];

			 %get synaptic conductance time course for all cells
			 %if this cell spikes, add a synaptic weight time course to all of
			 %its post-synaptic recipients' gsyn
			 synEndStep=step+1+round(400/dt);
			 %400 ms covers integrated timecourses without slowing down
			 if(synEndStep>numSteps)
			     synEndStep=numSteps;
			 end
			 synCurrentIdxes=(step+1):synEndStep;

			 count=0;
			 for interact=1:numCells
			     weight=connectivityMatrix(cell,interact);
			     if(step*dt>=startCouplingTime && weight>0)
				gsyn(synCurrentIdxes,interact)=gsyn(synCurrentIdxes,interact)...
				    +weight*exp(-dt*(synCurrentIdxes-(step+1))/tausyn).';
				count=count+1;
			     end
			 end
			 count;
		end
        end
      %%%%%%%%%%%%%%%
      %Il, leak current
      %%%%%%%%%%%%%%%%
      il=gl*(vSpecific-el);

      %minf=xinf(vSpecific,naM_Vt,naM_Gain);
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %I_Na gates voltage and time dependence
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %minf=1/(1+exp((vSpecific-naM_Vt)/naM_Gain));
      alpham=0.364*(vSpecific-naM_Vt)/(1-exp((-vSpecific+naM_Vt)/naM_Gain));
      betam=-0.248*(vSpecific-naM_Vt)/(1-exp((vSpecific-naM_Vt)/naM_Gain));
      taum=0.8/(alpham+betam);
      minf=alpham/(alpham+betam);
	
      alphah=0.08*(vSpecific-naH_Vt)/(1-exp((-vSpecific+naH_Vt)/naH_Gain));
      betah=-0.005*(vSpecific+10)/(1-exp((vSpecific+10)/5.0));
 
	%tauh=naTauH_offset+naTauH_Range/(1+exp((vSpecific-naTauH_Vt)/naTauH_Gain));
	tauh=1/(alphah+betah);
	hinf=1/(1+exp((vSpecific+58)/5)); %why not alpha/(alpha+beta) in Leung model??
	
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %I_Kdr gates voltage and time dependence
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %taun=kdrTauN_offset+kdrTauN_Range/(1+exp((vSpecific-kdrTauN_Vt)/kdrTauN_Gain));
     %ninf=1/(1+exp((vSpecific-kdrN_Vt)/kdrN_Gain)); 
      alphan=0.035*(vSpecific-kdrN_Vt)/(1-exp((vSpecific-kdrN_Vt)/kdrN_Gain));
      betan=0.035*(vSpecific-kdrN_Vt)/(exp((vSpecific-kdrN_Vt)/(-kdrN_Gain))-1);
     
      ninf=alphan/(alphan+betan);
      taun=1/(alphan+betan);  


      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %I_A gate voltage and time dependence
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      gka=24; %mS/cm^2
      alpha_mka=-0.01*(vSpecific-kaM_Vt)/(exp((vSpecific-kaM_Vt)/kaM_Gain)-1);
      beta_mka=0.01*(vSpecific-kaM_Vt)/(exp((vSpecific-kaM_Vt)/(-kaM_Gain))-1);
      tau_mka=0.2; %ms
      mkaInf=alpha_mka/(alpha_mka+beta_mka);
     
      alpha_hka=-0.01*(vSpecific-kaH_Vt)/(exp((vSpecific-kaH_Vt)/kaH_Gain)-1);
      beta_hka=0.01*(vSpecific-kaH_Vt)/(exp((vSpecific-kaH_Vt)/(-kaH_Gain))-1);

      %RELU-like time constant with voltage
      if(vSpecific<-20)
	   tau_hka=0.2; %ms
      else
	   tau_hka=(5+0.26*(vSpecific+20));
      end
      hkaInf=alpha_hka/(alpha_hka+beta_hka);
    
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %I_h gate voltage and time dependence
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      gh=0.2; %mS/cm^2
      alpha_kappaH=exp(0.08316*(vSpecific+75)); 
      beta_kappaH=exp(0.03326*(vSpecific+75)); 
      tau_kappaH=49.8*beta_kappaH/(1+alpha_kappaH);
      kappaH_inf=1/(1+exp((vSpecific+81)/8)); %notice low half activation -81

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %I_NaP gate voltage and time dependence 
      %(no inactivation since beyond timescale of interest)
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %gnap=0.8; %mS/cm^2 (Table 2)
	if(cell==1)
		gnap=gnap1;
	elseif(cell==2)
		gnap=gnap2;
	end 
	%gnap=1; %mS/cm^2 
      %mnap_Vt=-50;
      mnap_Vt=-50;
            %mnap_Vt=-52;
      %mnap_Vt=-47;
      mnap_Gain=-5;
      %mnap_Gain=-4;
      mnapInf=1/(1+exp((vSpecific-mnap_Vt)/mnap_Gain));
      tau_mnap=1; %ms

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %I_KS gate voltage and time dependence
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %gks=8;
	if(cell==1)
		gks=gks1;
	elseif(cell==2)
		gks=gks2;
	end 
	      

	nks_Vt=-35;
      %nks_Vt=-10;
      nks_Gain=-10;
      nksInf=1/(1+exp((vSpecific-nks_Vt)/nks_Gain));

      
       tau_nks=1/((exp((vSpecific-nks_Vt)/40)+exp(-(vSpecific-nks_Vt)/20) )/81);
  

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %currents from driving force and gating variables
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %ina=gna*minf^3*(hSpecific)*(vSpecific-ena);
      ina=gna*mSpecific^3*(hSpecific)*(vSpecific-ena);
      
      %delayed-rectifier potassium current
      ik=gk*nSpecific^4*(vSpecific-ek);

      ika=gka*fka*mkaSpecific^4*hkaSpecific*(vSpecific-ek);

      ih=gh*fh*kappaHSpecific*(vSpecific-eh);	

      %slow, low threshold potassium current
      iks=gks*nksSpecific*(vSpecific-ek);
      
      %persistent sodium current, thresh -50mV
      inap=gnap*mnapSpecific*(vSpecific-ena);

	%synaptic current
	if(numCells>1)
      		isyn=gsyn(step,cell)*(vSpecific-esyn);
        else
		isyn=0;
	end
    
	isynExt=g_Inh(step)*(vSpecific-esynI) + g_Exc(step)*(vSpecific-esynE);
        %%%%%%%%%%%%%%%%
       %isynExt=0;
       %%%%%%%%%%%%%%%%
      %drive current
      %itonic=g_tonic(cell)*(vSpecific-etonic);
        %if(abs(step*dt-targetTime)<=prcPerturbDuration/2)  
        %    itonic=iDrive(cell)+prcPerturbAmp;
        %else
            %itonic=iDrive(cell);
            %itonic=injCurr(step); %ACROSS CELL?;
	  if(cell==1)
            itonic=injCurr1(step); %ACROSS CELL?;
	   elseif(cell==2)
	    itonic=injCurr2(step);
	   end
        %end

	iDriveRecord(step)=itonic;
	totalFeedFwdSynDrive(step)=isynExt;

    %calculate values to compute dGates
  

      %tauz=75.0;
      %zinf=1/(1+exp((vSpecific-z_Vt)/z_Gain));

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %increment variables using euler's method of ODE integration
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	vInc=double(dt*(-il-ina-ik-ika-ih-inap-iks-isyn-isynExt+itonic)/cm);
    %vInc=double(dt*(-il-ina-ik-inap-ika-iks-isyn-isynExt+itonic)/cm);
    
	%vInc=double(dt*(-il-ina-ik-ika-ih-inap-iks-isyn+itonic)/cm);
	%vInc=double(dt*(-il-ina-ik+itonic)/cm);

	mInc=double(dt*(minf-mSpecific)/taum);
	nInc=double(dt*(ninf-nSpecific)/taun);
	hInc=double(dt*(hinf-hSpecific)/tauh);

	mkaInc=double(dt*(mkaInf-mkaSpecific)/tau_mka);
	hkaInc=double(dt*(hkaInf-hkaSpecific)/tau_hka);

	kappaH_Inc=double(dt*(kappaH_inf-kappaHSpecific)/tau_kappaH);
	
	mnapInc=double(dt*(mnapInf-mnapSpecific)/tau_mnap);
	
	%zInc=double(dt*(zinf-zSpecific)/tauz);
	nksInc=double(dt*(nksInf-nksSpecific)/tau_nks);
      
       %V=V+dV
      v(step+1,cell)=vSpecific+vInc;
      %Gates=Gates+dGates
      n(step+1,cell)=nSpecific+nInc;
      m(step+1,cell)=mSpecific+mInc;
      h(step+1,cell)=hSpecific+hInc;
      mka(step+1,cell)=mkaSpecific+mkaInc;
      hka(step+1,cell)=hkaSpecific+hkaInc;
      kappaH(step+1,cell)=kappaHSpecific+kappaH_Inc;
      mnap(step+1,cell)=mnapSpecific+mnapInc;
      nks(step+1,cell)=nksSpecific+nksInc;
    end
      %if(currentPerturbation==numPerturbationsTotal)
       %  break               
       %end
end
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculateAndSavePhasePrecessionProperties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hilbertGinh=hilbert(-(g_Inh-mean(g_Inh)));
%hilbertGinh=hilbert(g_Inh);
g_Inh_Phase=angle(hilbertGinh);
g_Inh_Phase = ((g_Inh_Phase/pi) + 1)/2 * 360;

%error may arise from old findpeaks.m version in ANALYSIS_CODE - change name of old version to fix
ALL_PEAKS=1;
%ALL_PEAKS=0;

%[entryPhase1,phasePrecessSlope1,subTpeakTimes1,subTpeakPhases1]=analyzePhasePrecessionFromVmTrace(v(:,1),thetaPeriod,rampStartTime1,rampPeakTime1,g_Inh_Phase,timeAxis,ALL_PEAKS);
%[entryPhase2,phasePrecessSlope2,subTpeakTimes2,subTpeakPhases2]=analyzePhasePrecessionFromVmTrace(v(:,2),thetaPeriod,rampStartTime2,rampPeakTime2,g_Inh_Phase,timeAxis,ALL_PEAKS);
[entryPhase1,phasePrecessSlope1,subTpeakTimes1,subTpeakPhases1,placeFieldWidth1]=analyzePhasePrecessionFromVmTrace(v(:,1),thetaPeriod,rampStartTime1,rampPeakTime1,g_Inh_Phase,timeAxis,ALL_PEAKS);
[entryPhase2,phasePrecessSlope2,subTpeakTimes2,subTpeakPhases2,placeFieldWidth2]=analyzePhasePrecessionFromVmTrace(v(:,2),thetaPeriod,rampStartTime2,rampPeakTime2,g_Inh_Phase,timeAxis,ALL_PEAKS);

phasePrecessSlopeDegPerSec1=phasePrecessSlope1*1000;
phasePrecessSlopeDegPerSec2=phasePrecessSlope2*1000;

if(ALL_PEAKS)
	save(sprintf('AllPeaksSlopeOffsetBiophysicsData_gNaP_%.5f_gKS_%.5f_Cell.mat',gnap, gks), 'phasePrecessSlopeDegPerSec1','entryPhase1','phasePrecessSlopeDegPerSec2','entryPhase2','gnap','gks','gsyn12','gsyn21','gsyn12Idx','gsyn21Idx','placeFieldWidth1','placeFieldWidth2')
else
	save(sprintf('SlopeOffsetBiophysicsData_gNaP_%.5f_gKS_%.5f_Cell.mat',gnap, gks), 'phasePrecessSlopeDegPerSec1','entryPhase1','phasePrecessSlopeDegPerSec2','entryPhase2','gnap','gks','gsyn12','gsyn21','gsyn12Idx','gsyn21Idx','placeFieldWidth1','placeFieldWidth2')
end

if(plotVm)
	figure

	subplot(3,1,1)
	ax1=plot(timeAxis,v(:,1), 'LineWidth',2,'Color','k');
	title({'coupled place cell membrane potentials',sprintf('gsyn_{12}=%.2f, gsyn_{21}=%.2f (mS/cm^2)',gsyn12,gsyn21)})
	%hold on
	%ax2=plot(timeAxis,v(:,2), 'LineWidth',2,'Color','b');

	%legend([ax1 ax2],{sprintf('gnap=%.2f,gks=%.2f',gnap1,gks1),sprintf('gnap=%.2f,gks=%.2f',gnap2,gks2)})

	ylim([-75 10])
	xlabel('Time (msec)')
	ylabel('V_m (mV)')

	subplot(3,1,2)
	%ax1=plot(timeAxis,v(:,1), 'LineWidth',2,'Color','k');
	%title({'coupled place cell membrane potentials',sprintf('gsyn_{12}=%.2f, gsyn_{21}=%.2f (mS/cm^2)',gsyn12,gsyn21)})
	%hold on
	ax2=plot(timeAxis,v(:,2), 'LineWidth',2,'Color','b');

	legend([ax1 ax2],{sprintf('gnap=%.2f,gks=%.2f',gnap1,gks1),sprintf('gnap=%.2f,gks=%.2f',gnap2,gks2)},'Location','Best')

	ylim([-75 10])

	xlabel('Time (msec)')
	ylabel('V_m (mV)')
	subplot(3,1,3)
	plot(subTpeakTimes1,subTpeakPhases1,'o','MarkerSize',7,'MarkerFaceColor','k','MarkerEdgeColor','k')
	hold on 
	plot(subTpeakTimes2,subTpeakPhases2,'o','MarkerSize',7,'MarkerFaceColor','b','MarkerEdgeColor','b')

	placeFieldTimes1=subTpeakTimes1(subTpeakTimes1>rampStartTime1 & subTpeakTimes1<rampPeakTime1);
	placeFieldTimes2=subTpeakTimes2(subTpeakTimes2>rampStartTime2 & subTpeakTimes2<rampPeakTime2);

	plot(placeFieldTimes1,entryPhase1+phasePrecessSlope1*(placeFieldTimes1-placeFieldTimes1(1)),'k--')
	plot(placeFieldTimes2,entryPhase2+phasePrecessSlope2*(placeFieldTimes2-placeFieldTimes2(1)),'b--')
	ylim([100 360])
	xlabel('Time (msec)')
	ylabel('Phase in theta')
	title(sprintf('Phase precession slope ratio: %.4f', phasePrecessSlope1/phasePrecessSlope2))
	maxFigManual2d(1,2)
	setFigFontTo(20)

	if(ALL_PEAKS)
		saveas(gcf,sprintf('AllPeaks_coupledCellEx_%s_tracesAndPhases.tif',saveStrID))
	else
		saveas(gcf,sprintf('coupledCellEx_%s_tracesAndPhases.tif',saveStrID))
	end

end

phasePrecessSlopeDegPerSec1=phasePrecessSlope1*1000;
phasePrecessSlopeDegPerSec2=phasePrecessSlope2*1000;

if(ALL_PEAKS)
        save(sprintf('AllPeaksSlopeOffsetTwoCellBiophysicsData_%s.mat',saveStrID), 'phasePrecessSlopeDegPerSec1','entryPhase1','gnap1','gks1','phasePrecessSlopeDegPerSec2','entryPhase2','gnap2','gks2','gsyn12', 'gsyn21','gsyn12Idx','gsyn21Idx','placeFieldWidth1','placeFieldWidth2')
else
        save(sprintf('SlopeOffsetTwoCellBiophysicsData_%s.mat',saveStrID), 'phasePrecessSlopeDegPerSec1','entryPhase1','gnap1','gks1','phasePrecessSlopeDegPerSec2','entryPhase2','gnap2','gks2','gsyn12', 'gsyn21','gsyn12Idx','gsyn21Idx','placeFieldWidth1','placeFieldWidth2')

end
disp('DONE')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plotPhasePrecessionDetailsForCell
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

