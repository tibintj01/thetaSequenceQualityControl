%clear all;  clc;
function [phasePrecessSlope,entryPhase]=hippocampalPrecessingSingleCell(gnap,gks)
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

%set simulation time, stepsize
%simTime=70000	%msec
%simTime=5000	%msec
simTime=2000	%msec
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

numCells=1;


%set single neuron properties
%setDefaultParamsCorticalNeuron;
setDefaultParamsPlaceCell;

%setCorticalNetworkProperties;
initializeCorticalNetwork;

tic

iDriveRecord=zeros(numSteps,1);
totalFeedFwdSynDrive=zeros(numSteps,1);

spikeCount=0;
spikeTimes=[];

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
      if(~exist('gnap'))
            gnap=0.1; %mS/cm^2 (Table 2)
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
      if(~exist('gks'))
	gks=1;
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
            itonic=injCurr(step); %ACROSS CELL?;
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

calculateAndSavePhasePrecessionProperties

plotPhasePrecessionDetailsForCell


