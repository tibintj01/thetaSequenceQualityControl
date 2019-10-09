classdef Cells < handle & matlab.mixin.Copyable %create object by reference
	%encapsulate data and actions of cells to keep my interface and implementation details separate
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%public cells properties
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	properties(Constant)
		justSpikingConductances=1
		includeKS=1;
		NUM_CELLS_L2=1;
		INTEGRATOR_gL=0.005;
	end
	properties
		%voltage and time dependent gating variable matrices

		v
		n
		m

		h
		mka
		hka

		numCellsL2
                vL2
                nL2
                mL2
                hL2

		vInt
                nInt
                mInt
                hInt
		spikeTimesInt
		
		kappaH
		mnap
		nks

		gnapBar
	        gnapSigma
		gksBar
	        gksSigma

		%gl

		gnapMatrix
		gksMatrix

		injCurrMatrix
		inhThetaInputArray

		numCellsPerPlace
		numPlaces
		numSteps

		internalConnObj
		externalInputObj
		feedforwardConnObj
	
		dt

		spikeTimes
		delayedSpikeTimes
		doubleDelayedSpikeTimes
		spikeCellCoords
		gsyn
		
		spikeTimesL2
		spikeCellCoordsL2
		gsynL2
		gsynL2_I
		
		
		l2IsynRecord
		l2EsynRecord

		esyn_I
		esyn_E

		inaRecord
		ikRecord
		iksRecord
		%circuitRawOutput
		%sensoryInput
		%speedInput
		%placeInput
		%lfpInput	
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%cells conductance parameters
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	properties(Access=public)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%passive (linear) conductance parameters
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%specific membrane resistance 30,000 ohm-cm^2 (Gm=0.033mS/cm^2)
		% i.e. leak current
		%gl=0.033;        %mS/cm^2
		%gl=0.033*8;        %mS/cm^2
		%gl=0.033*5;        %mS/cm^2
		%gl=0.033*6;        %mS/cm^2
		%gl=SCAN_PARAM2;        %mS/cm^2
		gl=0.0333333333333;        %mS/cm^2

		%gl_L2=0.05; %CA1 20msec time constant
		gl_L2=0.1; %CA1 20msec time constant
		%gl_L2=0.2; %CA1 20msec time constant

		%gl=0.033*10;        %mS/cm^2
		%gl=0.033*6;        %mS/cm^2
		%gl=0.033*3;        %mS/cm^2
		%el=-70;         %mV "normally -70 mV but adjusted to keep resting membrane potential near -66 mV." (Leung, 2011)
		%el=-50;         %mV
		el=-60;         %mV "normally -70 mV but adjusted to keep resting membrane potential near -66 mV." (Leung, 2011)
		cm=1.0; %uF/cm^2		

	        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	     	%fast Na and K spiking parameters
	        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%fast Na;
		%gna=24.0;       %mS/cm^2
		%gna=60.0;       %mS/cm^2 - original, Sept 5, 2019
		%gna=70.0;       %mS/cm^2
	
		gna=80.0;       %mS/cm^2
		%gna=0;       %mS/cm^2
		%gna=22.0;       %mS/cm^2
		%ena=55;
		ena=58;

		%naM_Vt=-34; %normal spiking, corresponds to VNaD in Leung, 2011, pg 12285
		naM_Vt=-35; %push thresh down a bit - 12/3/18
		%naM_Vt_L2=-35; %push thresh down a bit - 12/3/18
		%naM_Vt_L2=-34.5; %push thresh down a bit - 12/3/18
		%naM_Vt_L2=-35; %push thresh down a bit - 12/3/18
		naM_Vt_L2=-35; %push thresh down a bit - 12/3/18
		%naM_Vt=-32; %without spiking, corresponds to VNaD in Leung, 2011, pg 12285
		%naM_Vt=-30; %without spiking, corresponds to VNaD in Leung, 2011, pg 12285
		%naM_Vt=100; %without spiking, corresponds to VNaD in Leung, 2011, pg 12285
		naM_Gain=4.5;


		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%revert to more active h gate!!! Oct 2nd 2019, TJ
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%naH_Vt=-53.0;
		naH_Gain=7.0;
		naH_Vt=-40;
		%naH_Gain=3;

		%naTauH_offset=0.37;
		%naTauH_Vt=-40.5;
		%naTauH_Gain=6;
		%naTauH_Range=2.78;

		%delayed rectifier
		%gk=3.0;         %mS/cm^2
		%gk=15;         %mS/cm^2
		%gk=17;         %mS/cm^2
		%gk=40;         %mS/cm^2; 1/1.6 of gna is too strong of inhibition - never leaves 50mV
		%gk=35;         %mS/cm^2; 
		
		gk=25;         %mS/cm^2; 
		%gk=20;         %mS/cm^2; 
		%gk=25.0;         %mS/cm^2
		%ek=-90;         %mV
		ek=-85;         %mV
		%kdrN_Vt=-30.0;
		kdrN_Vt=-29.0;
		%kdrN_Gain=-10;
		%kdrN_Gain=-13;
		kdrN_Gain=-14;


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
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%public methods
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods
		%constructor
		function thisObj=Cells(simProps)
			%set properties of this cells object
			if (nargin == 1)
				thisObj.setSimSpecificProperties(simProps);

				%if(isfield(simProps,'bias'))
				%	thisObj.setCellProps(simProps.extEnvObj,simProps.bias);
				%else
					thisObj.setCellProps(simProps.extEnvObj);
				%end

				thisObj.setIntrinsicsMatrix();
				
				%thisObj.injCurrMatrix=thisObj.currInjectorArray.getFloatMatrix();
				thisObj.injCurrMatrix=thisObj.externalInputObj.getFloatMatrix();
				
				thisObj.spikeTimes=[];
				thisObj.delayedSpikeTimes=[];
				thisObj.doubleDelayedSpikeTimes=[];
				thisObj.spikeCellCoords=[];
				
				thisObj.spikeTimesL2=[];
				thisObj.spikeCellCoordsL2=[];
				
				thisObj.spikeTimesInt=[];
				
				thisObj.gsyn=zeros(thisObj.numCellsPerPlace,thisObj.numPlaces,thisObj.numSteps);
				thisObj.gsynL2=zeros(thisObj.numCellsL2,thisObj.numSteps);
				thisObj.gsynL2_I=zeros(thisObj.numCellsL2,thisObj.numSteps);
				
				thisObj.esyn_E=thisObj.internalConnObj.esyn_E;
				thisObj.esyn_I=thisObj.internalConnObj.esyn_I;

			%elseif(nargin==2 && strcmp(initStr,'backbone'))
			%	thisObj.setSimSpecificProperties(simConfigObj);
                        %        thisObj.setCellProps();
			end
		end


		%stepping through time
		function go(thisObj)
			disp('solving cell diff equations....')
				thisObj.injCurrMatrix=thisObj.externalInputObj.getFloatMatrix();
			tic
			thisObj.letItRip()
			toc
		end
		
		
		function idStr=getCellIDstr(thisObj,r,placeIdx)
			gnap=thisObj.gnapMatrix(r,placeIdx);
			gks=thisObj.gksMatrix(r,placeIdx);
			
			itonic=thisObj.injCurrMatrix(r,placeIdx);
			idStr=sprintf('gnap: %.2f, gks: %.2f (nS/cm^2); i_{tonic}=%.2f',gnap,gks,itonic);
		end
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%private methods
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods(Access= protected)
		function letItRip(thisObj)
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%load variables		
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			numSteps=thisObj.numSteps;
			numPlaces=thisObj.numPlaces;
			numCellsPerPlace=thisObj.numCellsPerPlace;
			v=thisObj.v;
			n=thisObj.n;
			m=thisObj.m;
			h=thisObj.h;
		
			vL2=thisObj.vL2;
                        nL2=thisObj.nL2;
                        mL2=thisObj.mL2;
                        hL2=thisObj.hL2;
			
			vInt=thisObj.vInt;
                        nInt=thisObj.nInt;
                        mInt=thisObj.mInt;
                        hInt=thisObj.hInt;

			numCellsL2=thisObj.numCellsL2;

			mka=thisObj.mka;
			hka=thisObj.hka;
			kappaH=thisObj.kappaH;
			mnap=thisObj.mnap;
			nks=thisObj.nks;
			gl=thisObj.gl;
			gl_L2=thisObj.gl_L2;
			el=thisObj.el;
			gna=thisObj.gna;
			ena=thisObj.ena;
			naM_Vt=thisObj.naM_Vt;
			naM_Vt_L2=thisObj.naM_Vt_L2;

			naM_Gain=thisObj.naM_Gain;
			naH_Vt=thisObj.naH_Vt;
			naH_Gain=thisObj.naH_Gain;	
			gk=thisObj.gk;
			ek=thisObj.ek;
			kdrN_Vt=thisObj.kdrN_Vt;
			kdrN_Gain=thisObj.kdrN_Gain;
			fka=thisObj.fka;
			kaM_Vt=thisObj.kaM_Vt;
			kaM_Gain=thisObj.kaM_Gain;
			kaH_Vt=thisObj.kaH_Vt;
			kaH_Gain=thisObj.kaH_Gain;
			gh=thisObj.gh;
			eh=thisObj.eh;
			fh=thisObj.fh;
			justSpikingConductances=Cells.justSpikingConductances;	
			includeKS=Cells.includeKS;	
			%make sure these are updated based on gbar and gsigma
			thisObj.setIntrinsicsMatrix();
			gnapMatrix=thisObj.gnapMatrix;		
			gksMatrix=thisObj.gksMatrix;		
			
			injCurrMatrix=thisObj.injCurrMatrix;
			dt=thisObj.dt;
			cm=thisObj.cm;

			gInhThetaMatrix=thisObj.inhThetaInputArray.conductanceTimeSeries;
			%esynI=thisObj.inhThetaInputArray.esyn;
			spikeTimes=thisObj.spikeTimes;
			delayedSpikeTimes=thisObj.delayedSpikeTimes;
			doubleDelayedSpikeTimes=thisObj.doubleDelayedSpikeTimes;
			spikeCellCoords=thisObj.spikeCellCoords;

			spikeTimesL2=thisObj.spikeTimesL2;
                        spikeCellCoordsL2=thisObj.spikeCellCoordsL2;
			gsyn=thisObj.gsyn;
			
			spikeTimesInt=thisObj.spikeTimesInt;
			
			gsynL2=thisObj.gsynL2;
			gsynL2_I=thisObj.gsynL2_I;
			esyn_I=thisObj.esyn_I;
			esyn_E=thisObj.esyn_E;

			tausyn=thisObj.internalConnObj.tausyn;
			connectivityMatrix=thisObj.internalConnObj.connectivityMatrix;

			feedfwdGmatrix=thisObj.feedforwardConnObj.connectivityMatrix;
                        dendriticDelayTemplateMatrix=thisObj.feedforwardConnObj.dendriticDelayTemplateMatrix;

			startCouplingTime=thisObj.internalConnObj.startCouplingTime;

			inaRecord=NaN(size(v));
			ikRecord=NaN(size(v));
			iksRecord=NaN(size(v));

			l2IsynRecord=NaN(size(vL2));
			l2EsynRecord=NaN(size(vL2));
		
			normFactor=DelayObject.NORM_FACTOR;
			convFactor=DelayObject.CONV_FACTOR;
			baselineDelay=DelayObject.BASELINE_DELAY;	
			imax=DelayObject.IMAX;
			imin=DelayObject.IMIN;

			numCellsInt=1;

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%step through time
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			for step=1:numSteps-1
				if(mod(step,100000)==1)
					disp(sprintf('INTEGRATING!!!!! t=%d msec', round(dt*step)))
					%disp(sprintf('INTEGRATING!!!!! v=%.5f',v(1,1,step)))
				end
				for placeIdx=1:numPlaces
					for cellRow=1:numCellsPerPlace
						vSpecific=v(cellRow,placeIdx,step);
						nSpecific=n(cellRow,placeIdx,step);
						mSpecific=m(cellRow,placeIdx,step);
						hSpecific=h(cellRow,placeIdx,step);
						
						itonic=injCurrMatrix(cellRow,placeIdx,step);

						if(~justSpikingConductances)
							mkaSpecific=mka(cellRow,placeIdx,step);
							hkaSpecific=hka(cellRow,placeIdx,step);
							kappaHSpecific=kappaH(cellRow,placeIdx,step);
							mnapSpecific=mnap(cellRow,placeIdx,step);
						end
						if(includeKS)
							if(step==1)
								nks(cellRow,placeIdx,step)=0.5; %%%%
							end
							nksSpecific=nks(cellRow,placeIdx,step);
						end
						%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						%check for spike in  time step
						%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						if(step>1 && v(cellRow,placeIdx,step)>-30 && v(cellRow,placeIdx,step-1) <-30)
							spikeTimes=[spikeTimes; step*dt];
							if(numCellsPerPlace*numPlaces>=1)
								cellCoord=[cellRow placeIdx];
								spikeCellCoords=[spikeCellCoords; cellCoord];
								
								depConstant=1;
								numRecentSpikes=getNumSpikesInLastWind(spikeTimes,spikeCellCoords,FeedForwardConnectivity.SYN_DEP_WINDOW);
								 depConstant=(FeedForwardConnectivity.SYN_DEP_FACT)^(numRecentSpikes);

								%get synaptic conductance time course for all cells
								 %if this cell spikes, add a synaptic weight time course to all of
								 %its post-synaptic recipients' gsyn
								 %400 ms covers integrated timecourses without slowing down
								 %synEndStep=step+1+round(400/dt);
								 %4000 ms covers integrated timecourses with delay
								 synEndStep=step+1+round(4000/dt);
								 if(synEndStep>numSteps)
								     synEndStep=numSteps;
								 end
								 synCurrentIdxes=(step+1):synEndStep;

								 %count=0;
								%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                %L1 post-synaptic conductance changes
                                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                for postSynCellIdx=1:numCellsPerPlace
                                                                         for postSynPlaceIdx=1:numPlaces
                                                                             weight=connectivityMatrix(cellRow,placeIdx,postSynCellIdx,postSynPlaceIdx);

                                                                             if(step*dt>=startCouplingTime && weight>0)
                                                                                gsyn(postSynCellIdx,postSynPlaceIdx,synCurrentIdxes)=squeeze(gsyn(postSynCellIdx,postSynPlaceIdx,synCurrentIdxes))...
                                                                                    +weight*exp(-dt*(synCurrentIdxes-(step+1))/tausyn).'; %instantaneous conductance jump with single additive exp decay..
                                                                                %count=count+1;
                                                                             end
                                                                        end
                                                                end
								     
                                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                %inhibitory delay
								%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
								     defaultPhaseSlope=baselineDelay/(imax-imin);
                                                                     %phasePrecessionDelay=(normFactor*log(convFactor*(imax-itonic)))+(baselineDelay+(defaultPhaseSlope*(itonic-imin))); %see DelayObject for values
                                                                     %phasePrecessionDelay=(normFactor*log(convFactor*(imax-itonic)))+(baselineDelay+(defaultPhaseSlope*(itonic-imin))); %see DelayObject for values
                                                                     phasePrecessionDelay=-(normFactor*log(convFactor*(itonic-imin)))+(defaultPhaseSlope*(itonic-imin)); %see DelayObject for values
							             %phasePrecessionDelay=normFactor*log(convFactor*(imax-itonic))+baselineDelay; %see DelayObject for values
									%edge cases
                                                               		if(~isreal(phasePrecessionDelay) || phasePrecessionDelay<0)
										phasePrecessionDelay=0;
									end 
                                                        	    delayedSpikeTimes=[delayedSpikeTimes ;(step*dt + phasePrecessionDelay)];

                                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                %L2 post-synaptic conductance changes
                                                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
								for postSynL2CellIdx=1:numCellsL2
                                                                     %weight=feedfwdGmatrix(cellRow,placeIdx,postSynL2CellIdx);

                                                                     %phasePrecessionDelay=feedfwdDelay(itonic);

									weights=feedfwdGmatrix(placeIdx,:,postSynL2CellIdx);

									compartmentNumsInnervated=find(weights>0);
									weights=weights(compartmentNumsInnervated);
									dendriticDelays=dendriticDelayTemplateMatrix(placeIdx,compartmentNumsInnervated,postSynL2CellIdx);
                                                                      
									collateralTotalDelays=phasePrecessionDelay+dendriticDelays;
                                                                         %4000 ms covers integrated timecourses with delay
                                                                         synEndStep=step+1+round(max(collateralTotalDelays)/dt)+round(4000/dt);
                                                                         %synEndStep=step+1+round(delay/dt)+round(4000/dt);
                                                                         if(synEndStep>numSteps)
                                                                             synEndStep=numSteps;
                                                                         end
									for collateralIdx=1:length(collateralTotalDelays)
											
										currDelay=collateralTotalDelays(collateralIdx);
										if(collateralIdx==1)
											doubleDelayedSpikeTimes=[doubleDelayedSpikeTimes; (step*dt + currDelay)];
										end 
										 synCurrentIdxes=(step+1+round(currDelay/dt)):synEndStep;
										%{
										if(~isscalar(currDelay))
											fds
										end
										if(~isreal(currDelay))
											fds
										end
										if(isnan(currDelay))
											fds
										end
										if(isinf(currDelay))
											fds
										end
										%}
									synTimeAxis=dt*(synCurrentIdxes-(step+1+round(currDelay/dt)));
									     if(step*dt>=startCouplingTime)
										gsynL2(postSynL2CellIdx,synCurrentIdxes)=squeeze(gsynL2(postSynL2CellIdx,synCurrentIdxes))...
										    +depConstant*weights(collateralIdx)*exp(-(synTimeAxis)/tausyn); %instantaneous conductance jump with single additive exp decay..
										    %+weights(collateralIdx)*exp(-dt*(synCurrentIdxes-(step+1+round(currDelay/dt)))/tausyn); %instantaneous conductance jump with single additive exp decay..
										    %+weight*exp(-dt*(synCurrentIdxes-(step+1+round(currDelay/dt)))/tausyn).'; %instantaneous conductance jump with single additive exp decay..
										%count=count+1;
										%add total current normalized inhibitory alpha function 6ms time constant representing disynaptic inhibition (enhances synchrony selectivity?)
									
										gsynL2_I(postSynL2CellIdx,synCurrentIdxes)=squeeze(gsynL2_I(postSynL2CellIdx,synCurrentIdxes))...
										    +depConstant*weights(collateralIdx)*FeedForwardConnectivity.E_TO_I_NORM*(synTimeAxis/FeedForwardConnectivity.tausyn_I).*exp(1-(synTimeAxis/FeedForwardConnectivity.tausyn_I));
%exp(-dt*(synCurrentIdxes-(step+1+round(currDelay/dt)))/tausyn); %alpha function inhibitory conductnace representing feedfoward inhibition and selecting for high timing precision
									
									     end
									end
                                                                end
							end
						end


						%%%%%%%%%%%%%%%%%%
						%Il, leak current
						%%%%%%%%%%%%%%%%%%
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
						%tauh=1/(alphah+betah);
						tauh=1/(alphah+betah);
						%hinf=1/(1+exp((vSpecific+58)/5)); %why not alpha/(alpha+beta) in Leung model??
						%hinf=1/(1+exp((vSpecific+58)/10)); %why not alpha/(alpha+beta) in Leung model??
						hinf=1/(1+exp((vSpecific+58)/10)); %increasing gain definitely makes spikes more sparse!?
						%hinf=alphah/(alphah+betah);
						%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						%I_Kdr gates voltage and time dependence
						%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						%taun=kdrTauN_offset+kdrTauN_Range/(1+exp((vSpecific-kdrTauN_Vt)/kdrTauN_Gain));
						%ninf=1/(1+exp((vSpecific-kdrN_Vt)/kdrN_Gain)); 
						alphan=0.035*(vSpecific-kdrN_Vt)/(1-exp((vSpecific-kdrN_Vt)/kdrN_Gain));
						betan=0.035*(vSpecific-kdrN_Vt)/(exp((vSpecific-kdrN_Vt)/(-kdrN_Gain))-1);

						ninf=alphan/(alphan+betan);
						taun=1/(alphan+betan);

						if(includeKS)
						      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						      %I_KS gate voltage and time dependence
						      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						      %gks=8;
							%{
							if(cell==1)
								gks=gks1;
							elseif(cell==2)
								gks=gks2;
							end
							%}
							gks=gksMatrix(cellRow,placeIdx);

							nks_Vt=-35;
							%nks_Vt=-45;
							%nks_Vt=-50;
							%nks_Vt=-55;
						      %nks_Vt=-10;
						      %nks_Gain=-10;
						      nks_Gain=-11;
						      nksInf=1/(1+exp((vSpecific-nks_Vt)/nks_Gain));


						       tau_nks=1/((exp((vSpecific-nks_Vt)/40)+exp(-(vSpecific-nks_Vt)/20) )/81);

							%tau_nks=tau_nks/2;

						      %slow, low threshold potassium current
						      iks=gks*nksSpecific*(vSpecific-ek);
						end


						if(~justSpikingConductances)
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
							%{
							if(cell==1)
								gnap=gnap1;
							elseif(cell==2)
								gnap=gnap2;
							end
							%gnap=1; %mS/cm^2 
							%}
						      %mnap_Vt=-50;
							
							gnap=gnapMatrix(cellRow,placeIdx);
						      mnap_Vt=-50;
							    %mnap_Vt=-52;
						      %mnap_Vt=-47;
						      mnap_Gain=-5;
						      %mnap_Gain=-4;
						      mnapInf=1/(1+exp((vSpecific-mnap_Vt)/mnap_Gain));
						      tau_mnap=1; %ms

						      ika=gka*fka*mkaSpecific^4*hkaSpecific*(vSpecific-ek);

						      ih=gh*fh*kappaHSpecific*(vSpecific-eh);

						      %persistent sodium current, thresh -50mV
						      inap=gnap*mnapSpecific*(vSpecific-ena);
						end %not just spiking conductances if statement
						      
						     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						      %currents from driving force and gating variables
						      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						      %ina=gna*minf^3*(hSpecific)*(vSpecific-ena);
						      ina=gna*mSpecific^3*(hSpecific)*(vSpecific-ena);
						      %delayed-rectifier potassium current
						      ik=gk*nSpecific^4*(vSpecific-ek);


	
						%synaptic current
						%{
						if(numCells>1)
							isyn=gsyn(step,cell)*(vSpecific-esyn);
						else
							isyn=0;
						end
					
						isynExt=g_Inh(step)*(vSpecific-esynI) + g_Exc(step)*(vSpecific-esynE);
						%}

						isynIntE=gsyn(cellRow,placeIdx,step)*(vSpecific-esyn_E);
						isynExt=gInhThetaMatrix(cellRow,placeIdx,step)*(vSpecific-esyn_I);
					      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					      %increment variables using euler's method of ODE integration
					      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						
						inaRecord(cellRow,placeIdx,step)=ina;
						ikRecord(cellRow,placeIdx,step)=ik;
						iksRecord(cellRow,placeIdx,step)=iks;
						%vInc=double(dt*(-il-ina-ik-ika-ih-inap-iks-isyn-isynExt+itonic)/cm);
						if(justSpikingConductances)
							vInc=double(dt*(-il-ina-ik-iks*includeKS-isynIntE-isynExt+itonic)/cm);
						else
							vInc=double(dt*(-il-ina-ik-ika-ih-inap-iks-isynIntE-isynExt+itonic)/cm);
						end
						%vInc=double(dt*(-il-ina-ik-ika-ih-inap-iks+itonic)/cm);
						%vInc=double(dt*(-il-ina-ik-ika-ih-inap-iks-isynExt+itonic)/cm);
					    %vInc=double(dt*(-il-ina-ik-inap-ika-iks-isyn-isynExt+itonic)/cm);

						%vInc=double(dt*(-il-ina-ik-ika-ih-inap-iks-isyn+itonic)/cm);
						%vInc=double(dt*(-il-ina-ik+itonic)/cm);

						mInc=double(dt*(minf-mSpecific)/taum);
						nInc=double(dt*(ninf-nSpecific)/taun);
						hInc=double(dt*(hinf-hSpecific)/tauh);

					       %V=V+dV
					      v(cellRow,placeIdx,step+1)=vSpecific+vInc;

					      %Gates=Gates+dGates
					      n(cellRow,placeIdx,step+1)=nSpecific+nInc;
					      m(cellRow,placeIdx,step+1)=mSpecific+mInc;
					      h(cellRow,placeIdx,step+1)=hSpecific+hInc;
						if(~justSpikingConductances)
							mkaInc=double(dt*(mkaInf-mkaSpecific)/tau_mka);
							hkaInc=double(dt*(hkaInf-hkaSpecific)/tau_hka);

							kappaH_Inc=double(dt*(kappaH_inf-kappaHSpecific)/tau_kappaH);

							mnapInc=double(dt*(mnapInf-mnapSpecific)/tau_mnap);

							%zInc=double(dt*(zinf-zSpecific)/tauz);
						     
						      mka(cellRow,placeIdx,step+1)=mkaSpecific+mkaInc;
						      hka(cellRow,placeIdx,step+1)=hkaSpecific+hkaInc;
						      kappaH(cellRow,placeIdx,step+1)=kappaHSpecific+kappaH_Inc;
						      mnap(cellRow,placeIdx,step+1)=mnapSpecific+mnapInc;
						end
						if(includeKS)
							nksInc=double(dt*(nksInf-nksSpecific)/tau_nks);
						      nks(cellRow,placeIdx,step+1)=nksSpecific+nksInc;

						end
					end %loop over cells coding for current place
				end %loop over places
					
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %update L2 cells based on last time step
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                for cellNumL2=1:numCellsL2     
                                        
					vSpecific=vL2(cellNumL2,step);
                                        nSpecific=nL2(cellNumL2,step);
                                        mSpecific=mL2(cellNumL2,step);
                                        hSpecific=hL2(cellNumL2,step);

                                        if(step>1 && vL2(cellNumL2,step)>-30 && vL2(cellNumL2,step-1) <-30)
                                                spikeTimesL2=[spikeTimesL2; step*dt];
                                                spikeCellCoordsL2=[spikeCellCoordsL2;cellNumL2];
                                        end %spike detected if statement

                                        %%%%%%%%%%%%%%%%%%
                                        %Il, leak current
                                        %%%%%%%%%%%%%%%%%%
                                        il=gl_L2*(vSpecific-el);

                                        %minf=xinf(vSpecific,naM_Vt,naM_Gain);

                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %I_Na gates voltage and time dependence
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %minf=1/(1+exp((vSpecific-naM_Vt)/naM_Gain));
                                        alpham=0.364*(vSpecific-naM_Vt_L2)/(1-exp((-vSpecific+naM_Vt_L2)/naM_Gain));
                                        betam=-0.248*(vSpecific-naM_Vt_L2)/(1-exp((vSpecific-naM_Vt_L2)/naM_Gain));
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


                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %currents from driving force and gating variables
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %ina=gna*minf^3*(hSpecific)*(vSpecific-ena);
                                        ina=gna*mSpecific^3*(hSpecific)*(vSpecific-ena);
                                        %delayed-rectifier potassium current
                                        ik=gk*nSpecific^4*(vSpecific-ek);
					itonic_L2=3;
					isynIntE_L2=gsynL2(cellNumL2,step)*(vSpecific-esyn_E);
					isynIntI_L2=gsynL2_I(cellNumL2,step)*(vSpecific-esyn_I);

					L2_THETA_PHASE_OFFSET=90; %degrees
					l2ThetaTimeOffset=ThetaPopInput.L2_THETA_PHASE_OFFSET/360*(1/ThetaPopInput.frequencyDefault);

					l2ThetaStepOffset=round(l2ThetaTimeOffset/dt);
					if(step+l2ThetaStepOffset<=numSteps)
						thetaSampleStep=step+l2ThetaStepOffset;
						isynExt_L2=ThetaPopInput.L2_MULT_FACTOR*gInhThetaMatrix(1,1,thetaSampleStep)*(vSpecific-esyn_I); %same theta everywehre
					else
						isynExt_L2=ThetaPopInput.baselineDefault;
					end

					l2IsynRecord(cellNumL2,step)=isynIntI_L2;
					l2EsynRecord(cellNumL2,step)=isynIntE_L2;	
                                        
					vInc=double(dt*(-il-ina-ik-isynIntE_L2-isynExt_L2-isynIntI_L2+itonic_L2)/cm);
                                        %vInc=double(dt*(-il-ina-ik+itonic_L2)/cm);
                                        mInc=double(dt*(minf-mSpecific)/taum);
                                        nInc=double(dt*(ninf-nSpecific)/taun);
                                        hInc=double(dt*(hinf-hSpecific)/tauh);

                                        %V=V+dV
                                        vL2(cellNumL2,step+1)=vSpecific+vInc;
                                        %Gates=Gates+dGates
                                        nL2(cellNumL2,step+1)=nSpecific+nInc;
                                        mL2(cellNumL2,step+1)=mSpecific+mInc;	
 					hL2(cellNumL2,step+1)=hSpecific+hInc;
					%if(isnan(vL2(cellNumL2,step+1)))
					%	fds
					%end
                                 end%loop over layer 2 cells

				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %update integrator cell based on last time step
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				%vInt
				%nInt
				%mInt
				%hInt
				%spikeTimesInt
                                for cellNumInt=1:numCellsInt     
                                        
					vSpecific=vInt(cellNumInt,step);
                                        nSpecific=nInt(cellNumInt,step);
                                        mSpecific=mInt(cellNumInt,step);
                                        hSpecific=hInt(cellNumInt,step);

                                        if(step>1 && vInt(cellNumInt,step)>-30 && vInt(cellNumInt,step-1) <-30)
                                                spikeTimesInt=[spikeTimesInt; step*dt];
                                        end %spike detected if statement

                                        %%%%%%%%%%%%%%%%%%
                                        %Il, leak current
                                        %%%%%%%%%%%%%%%%%%
                                        il=Cells.INTEGRATOR_gL*(vSpecific-el);

                                        %minf=xinf(vSpecific,naM_Vt,naM_Gain);

                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %I_Na gates voltage and time dependence
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %minf=1/(1+exp((vSpecific-naM_Vt)/naM_Gain));
                                        alpham=0.364*(vSpecific-naM_Vt_L2)/(1-exp((-vSpecific+naM_Vt_L2)/naM_Gain));
                                        betam=-0.248*(vSpecific-naM_Vt_L2)/(1-exp((vSpecific-naM_Vt_L2)/naM_Gain));
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


                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %currents from driving force and gating variables
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %ina=gna*minf^3*(hSpecific)*(vSpecific-ena);
                                        ina=gna*mSpecific^3*(hSpecific)*(vSpecific-ena);
                                        %delayed-rectifier potassium current
                                        ik=gk*nSpecific^4*(vSpecific-ek);
					itonic_L2=3;
					isynL2E_L2=gsynL2(cellNumL2,step)*(vSpecific-esyn_E);
					isynL2I_L2=gsynL2_I(cellNumL2,step)*(vSpecific-esyn_I);


						isynExt_L2=ThetaPopInput.L2_MULT_FACTOR*gInhThetaMatrix(1,1,step)*(vSpecific-esyn_I); %same theta everywehre

					%l2IsynRecord(cellNumL2,step)=isynL2I_L2;
					%l2EsynRecord(cellNumL2,step)=isynL2E_L2;	
                                        
					vInc=double(dt*(-il-ina-ik-isynL2E_L2-isynExt_L2-isynL2I_L2+itonic_L2)/cm);
                                        %vInc=double(dt*(-il-ina-ik+itonic_Int)/cm);
                                        mInc=double(dt*(minf-mSpecific)/taum);
                                        nInc=double(dt*(ninf-nSpecific)/taun);
                                        hInc=double(dt*(hinf-hSpecific)/tauh);

                                        %V=V+dV
                                        vInt(cellNumInt,step+1)=vSpecific+vInc;
                                        %Gates=Gates+dGates
                                        nInt(cellNumInt,step+1)=nSpecific+nInc;
                                        mInt(cellNumInt,step+1)=mSpecific+mInc;	
 					hInt(cellNumInt,step+1)=hSpecific+hInc;
					%if(isnan(vInt(cellNumInt,step+1)))
					%	fds
					%end
                                 end%loop over integrator cells

			end %loop over time steps
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%store raw output
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		 	thisObj.v=v;
		 	thisObj.vL2=vL2;
		 	thisObj.vInt=vInt;
		 	thisObj.gsynL2=gsynL2;
		 	thisObj.gsynL2_I=gsynL2_I;
		 	thisObj.l2EsynRecord=l2EsynRecord;
		 	thisObj.l2IsynRecord=l2IsynRecord;

			thisObj.nks=nks;
			%thisObj.inaRecord=inaRecord;
			%thisObj.ikRecord=ikRecord;
			thisObj.iksRecord=iksRecord;
			thisObj.spikeTimes=spikeTimes;
			thisObj.delayedSpikeTimes=delayedSpikeTimes;
			thisObj.doubleDelayedSpikeTimes=doubleDelayedSpikeTimes;
			thisObj.spikeCellCoords=spikeCellCoords;

			thisObj.spikeTimesL2=spikeTimesL2;
			thisObj.spikeTimesInt=spikeTimesInt;
                        
			thisObj.spikeCellCoordsL2=spikeCellCoordsL2;
		end %letItRip function

		function setIntrinsicsMatrix(thisObj)
			thisObj.gnapMatrix=normrnd(thisObj.gnapBar,thisObj.gnapSigma,thisObj.numCellsPerPlace,thisObj.numPlaces);
		        thisObj.gksMatrix=normrnd(thisObj.gksBar,thisObj.gksSigma,thisObj.numCellsPerPlace,thisObj.numPlaces);
			thisObj.gnapMatrix(thisObj.gnapMatrix<0)=0;
			thisObj.gksMatrix(thisObj.gksMatrix<0)=0;
			
			%sort in order of increasing excitability
			thisObj.gnapMatrix=sort(thisObj.gnapMatrix,'descend');
			thisObj.gksMatrix=sort(thisObj.gksMatrix,'ascend');
		end	
		
		function setSimSpecificProperties(thisObj,simParams)
			thisObj.numCellsPerPlace=simParams.numCellsPerPlace;
			thisObj.numPlaces=simParams.numPlaces;
			thisObj.numSteps=simParams.numSteps;
			thisObj.dt=simParams.dt;
		end


		function setCellProps(thisObj,extEnvObj,bias)
			numCellsPerPlace=thisObj.numCellsPerPlace;
			numPlaces=thisObj.numPlaces;
			numSteps=thisObj.numSteps;
			dt=thisObj.dt;
			
			timeAxis=(dt:dt:(numSteps*dt)).'; %assumes simTime is divisible by dt
			
			simSpecificInfo.numCellsPerPlace=numCellsPerPlace;
			simSpecificInfo.numPlaces=numPlaces;
			simSpecificInfo.timeAxis=timeAxis;
			if(exist('bias','var'))
				simSpecificInfo.bias=bias;
			end

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%cell settings
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%gnapBar=0.05;
			%gnapBar=0.07;
			gnapBar=0.08;
			%gnapSigma=0.01;
			gnapSigma=0.005;
			%gnapSigma=0.03;

			%gksBar=0.2;
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%Oct 2 2019, TJ
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%gksBar=0.1;
			%gksBar=0.15;
			%gksBar=0.3;
			%gksBar=0.6;
			%gksBar=0.7;
			%gksBar=0.8;
			%gksBar=1.6;
			gksBar=2.1;
			
			gksSigma=0.05;
			%gksSigma=0.1;

			if(numCellsPerPlace*numPlaces==1)
				gnapSigma=0;
				gksSigma=0;
			end

			%gnapMatrix=normrnd(gnapBar,gnapSigma,numCellsPerPlace,numPlaces);
			%gksMatrix=normrnd(gksBar,gksSigma,numCellsPerPlace,numPlaces);

			currInjectorArray=CurrentInjectors(simSpecificInfo,extEnvObj);
			currInjectorArray.displayContent();
			%drawnow
			%injCurrMatrix=currInjectorArray.getFloatMatrix();


			inhThetaInputArray=ThetaPopInput(simSpecificInfo);
			inhThetaInputArray.displayContent();


			internalConnObj=InternalConnectivity(simSpecificInfo);
			%internalConnObj.displayContent();
			
			simSpecificInfoFwd.numPlaces=thisObj.numPlaces;
                        simSpecificInfoFwd.numCellsL2=Cells.NUM_CELLS_L2;
                        simSpecificInfoFwd.numCellsPerPlace=numCellsPerPlace;
			thisObj.feedforwardConnObj=copy(FeedForwardConnectivity(simSpecificInfoFwd));
			
			thisObj.feedforwardConnObj.displayContent();
			thisObj.numCellsL2=Cells.NUM_CELLS_L2;
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%initialize cell state variables
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			initV=NaN(numCellsPerPlace,numPlaces,numSteps);
			initN=NaN(numCellsPerPlace,numPlaces,numSteps);
			initM=NaN(numCellsPerPlace,numPlaces,numSteps);
			initH=NaN(numCellsPerPlace,numPlaces,numSteps);
			initMka=NaN(numCellsPerPlace,numPlaces,numSteps);
			initHka=NaN(numCellsPerPlace,numPlaces,numSteps);
			initKappaH=NaN(numCellsPerPlace,numPlaces,numSteps);
			initMnap=NaN(numCellsPerPlace,numPlaces,numSteps);
			initNks=NaN(numCellsPerPlace,numPlaces,numSteps);

			initV(:,:,1)=normrnd(-60,3,numCellsPerPlace,numPlaces);
			initN(:,:,1)=normrnd(0.1,0.01,numCellsPerPlace,numPlaces);
			initM(:,:,1)=normrnd(0.1,0.01,numCellsPerPlace,numPlaces);
			initH(:,:,1)=normrnd(0.1,0.1,numCellsPerPlace,numPlaces);
			initMka(:,:,1)=normrnd(0.1,0.1,numCellsPerPlace,numPlaces);
			initHka(:,:,1)=normrnd(0.1,0.1,numCellsPerPlace,numPlaces);
			initKappaH(:,:,1)=normrnd(0.1,0.1,numCellsPerPlace,numPlaces);
			initMnap(:,:,1)=normrnd(0.1,0.1,numCellsPerPlace,numPlaces);
			initNks(:,:,1)=normrnd(0.1,0,numCellsPerPlace,numPlaces);

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%group variables into output struct
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			thisObj.numCellsPerPlace=numCellsPerPlace;
			thisObj.numPlaces=numPlaces;
			%{
			thisObj.initV=initV;
			thisObj.initN=initN;
			thisObj.initM=initM;
			thisObj.initH=initH;
			thisObj.initMka=initMka;
			thisObj.initHka=initHka;
			thisObj.initKappaH=initKappaH;
			thisObj.initMnap=initMnap;
			thisObj.initNks=initNks;
			%}
			thisObj.v=initV;
			thisObj.n=initN;
			thisObj.m=initM;
			thisObj.h=initH;
			

			initVL2=NaN(thisObj.numCellsL2,numSteps);
                        initNL2=NaN(thisObj.numCellsL2,numSteps);
                        initML2=NaN(thisObj.numCellsL2,numSteps);
                        initHL2=NaN(thisObj.numCellsL2,numSteps);
			
			initVInt=NaN(1,numSteps);
                        initNInt=NaN(1,numSteps);
                        initMInt=NaN(1,numSteps);
                        initHInt=NaN(1,numSteps);

			initVL2(:,1)=normrnd(-60,3,thisObj.numCellsL2,1);
                        initNL2(:,1)=normrnd(0.1,0.01,thisObj.numCellsL2,1);
                        initML2(:,1)=normrnd(0.1,0.01,thisObj.numCellsL2,1);
                        initHL2(:,1)=normrnd(0.1,0.1,thisObj.numCellsL2,1);
			
			initVInt(:,1)=normrnd(-60,3,1,1);
                        initNInt(:,1)=normrnd(0.1,0.01,1,1);
                        initMInt(:,1)=normrnd(0.1,0.01,1,1);
                        initHInt(:,1)=normrnd(0.1,0.1,1,1);
			
			thisObj.vL2=initVL2;
			thisObj.nL2=initNL2;
			thisObj.mL2=initML2;
			thisObj.hL2=initHL2;
			
			thisObj.vInt=initVInt;
			thisObj.nInt=initNInt;
			thisObj.mInt=initMInt;
			thisObj.hInt=initHInt;

			thisObj.mka=initMka;
			thisObj.hka=initHka;
			thisObj.kappaH=initKappaH;
			thisObj.mnap=initMnap;
			thisObj.nks=initNks;

			%thisObj.gnapBar=gnapBar;

			thisObj.gnapBar=gnapBar;
			thisObj.gnapSigma=gnapSigma;
			thisObj.gksBar=gksBar;
			thisObj.gksSigma=gksSigma;

			%thisObj.injCurrMatrix=injCurrMatrix;

			thisObj.externalInputObj=copy(currInjectorArray);
			thisObj.inhThetaInputArray=copy(inhThetaInputArray);
			thisObj.internalConnObj=copy(internalConnObj);


			thisObj.dt=dt;
			thisObj.numSteps=numSteps;
		end
	end
end

