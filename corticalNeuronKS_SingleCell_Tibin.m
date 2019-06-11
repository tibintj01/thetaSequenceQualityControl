clear all;  clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%To do:
%-raster plots
%-Inoise (+ not minus!)
%-phase response curve (positive pulse in I drive), low and high Ach (gKS,Idrive)

%-inhibitory synapses
%-small world and rewiring prob
%-quantify synchrony - paper?
%-parameter search of time constant
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

%set simulation time, stepsize
%simTime=70000	%msec
simTime=5000	%msec
dt=0.01
numSteps=round(simTime/dt);

%set randomization seed to constant
rng(1)


numCells=1;


%set single neuron properties
setDefaultParamsCorticalNeuron;
%setDefaultParamsCorticalNeuronHighAch;

setCorticalNetworkProperties;
initializeCorticalNetwork;

tic

%dt=vpa(dt,16)	%msec
%dt=double(vpa(dt,64))	%msec

interTrialTime=200;
%numPerturbationsTotal=100;
numPerturbationsTotal=100;
currentPerturbation=1;
approxPeriod=121.3100; %low Ach
%approxPeriod=50.2100; % high Ach
timeSinceLastPulse=0;

prcPerturbAmp=3; %high Ach
%prcPerturbAmp=10; %low Ach

prcPerturbDuration=0.06; 
equilibrateTime=5000;

iDriveRecord=zeros(numSteps,1);
targetTime=-Inf;
spikeCount=0;
spikeTimes=[];
spikesPrecedingPulse=[];
%loop through time in dt-size steps
for step=1:numSteps-1
	%loop through cells in current time step
	for cell=1:numCells
		vSpecific=v(step,cell);
		nSpecific=n(step,cell);
		hSpecific=h(step,cell);
		zSpecific=z(step,cell);

		%check for spike in  time step
        if(step>1 && v(step,cell)>-30 && v(step-1,cell) <-30)
            spikeTimes=[spikeTimes; step*dt];
        end
      %leak
      il=gl*(vSpecific-el);

      %transient sodium current
      %minf=xinf(vSpecific,naM_Vt,naM_Gain);
      minf=1/(1+exp((vSpecific-naM_Vt)/naM_Gain));
      ina=gna*minf^3*(hSpecific)*(vSpecific-ena);
      
      %delayed-rectifier potassium current
      ik=gk*nSpecific^4*(vSpecific-ek);

      %slow, low threshold potassium current
      iks=gks*zSpecific*(vSpecific-ek);
      
	%synaptic current
	if(numCells>1)
      		isyn=gsyn(step,cell)*(vSpecific-esyn);
    else
		isyn=0;
	end
     
      %drive current
      %itonic=g_tonic(cell)*(vSpecific-etonic);
        if(abs(step*dt-targetTime)<=prcPerturbDuration/2)  
            itonic=iDrive(cell)+prcPerturbAmp;
        else
            itonic=iDrive(cell);
        end

	iDriveRecord(step)=itonic;

    %calculate values to compute dGates
	taun=kdrTauN_offset+kdrTauN_Range/(1+exp((vSpecific-kdrTauN_Vt)/kdrTauN_Gain));
     ninf=1/(1+exp((vSpecific-kdrN_Vt)/kdrN_Gain)); 
    tauh=naTauH_offset+naTauH_Range/(1+exp((vSpecific-naTauH_Vt)/naTauH_Gain));

	hinf=1/(1+exp((vSpecific-naH_Vt)/naH_Gain));
	tauz=75.0;
      zinf=1/(1+exp((vSpecific-z_Vt)/z_Gain));
	
	vInc=double(dt*(-il-ina-ik-iks-isyn+itonic)/cm);
	nInc=double(dt*(ninf-nSpecific)/taun);
	hInc=double(dt*(hinf-hSpecific)/tauh);
	zInc=double(dt*(zinf-zSpecific)/tauz);
      
       %V=V+dV
      v(step+1,cell)=vSpecific+vInc;
      %Gates=Gates+dGates
      n(step+1,cell)=nSpecific+nInc;
      h(step+1,cell)=hSpecific+hInc;
      z(step+1,cell)=zSpecific+zInc;
    end
      %if(currentPerturbation==numPerturbationsTotal)
       %  break               
       %end
end
toc

timeAxis=(dt:dt:simTime).';
figure
ax1=subplot(2,1,1)
plot(timeAxis,v(:,1))
ax2=subplot(2,1,2)
plot(timeAxis,iDriveRecord)
linkaxes([ax1 ax2],'x')

baselinePeriod=median(diff(spikeTimes(spikeTimes<equilibrateTime)))
ISIs=diff(spikeTimes);

% plot(timeAxis,n(:,1),'r')
% hold on
% plot(timeAxis,h(:,1),'b')
% plot(timeAxis,z(:,1),'g')
% 
% legend('n','h','z')
