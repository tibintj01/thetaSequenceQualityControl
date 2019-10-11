classdef FeedForwardConnectivity < handle & matlab.mixin.Copyable
	%encapsulate data and actions of connectivity to keep my interface and implementation details separate
	properties(Constant)
		%NUM_COLLATERALS=7;
		%NUM_COLLATERALS=3;
		NUM_COLLATERALS=1;
		%E_TO_I_NORM=1/(3.5781);
		%E_TO_I_NORM=1/(4.8794);
		E_TO_I_NORM=1/(4.8794*2);
		SYN_DEP_WINDOW=30;
                %SYN_DEP_FACT=1 %no synaptic depression
                SYN_DEP_FACT=0.1
                %SYN_DEP_FACT=0.3
                %SYN_DEP_FACT=0 %%%%%%%only first spike in 30 msec window???
		tausyn_I=6;
	end

	properties
		connectivityMatrix
		startCouplingTime=0;
		tausyn=5				%AMPA
		synapseTypeStr='E'
		%connectivityTypeStr='directed'
		connectivityTypeStr='none'
		
		numDendriticCompartments
		numPlaces
		dendriticDelayTemplateMatrix

		%weight_mu=0.05
		%weight_mu=0.01
		%weight_mu=0.0125
		
		%weight_mu=0.002
		%weight_mu=0.07
		%weight_mu=0.09
		%weight_mu=0.15
		%weight_mu=0.30
		%weight_mu=0.50
		weight_mu=0.60 %works well
		%weight_mu=0.70 
		%weight_mu=0.75
		%weight_mu=0.75
		%weight_mu=0.9
		weight_sigma=0.0025
		esyn_E=0;
		esyn_I=-72;

	end

	methods
		function thisObj=FeedForwardConnectivity(simSpecificInfo)
	
			thisObj.setConnectivityMatrix(simSpecificInfo)
		end

		%heatmap showing cell to dendrite compartment connectivity 
		function displayContent(thisObj)
			numPlaces=thisObj.numPlaces;
			numDendriticCompartments=thisObj.numDendriticCompartments;

			placeToDendriteCompartmentMap=NaN(numPlaces,numDendriticCompartments);


			%omarPcolor(placeMetaConnMatrix
			figH=figure
			%subplot(2,1,1)
			%omarPcolor(1:numPlaces,1:numDendriticCompartments,squeeze(thisObj.connectivityMatrix))
			omarPcolor(1:numDendriticCompartments,1:numPlaces,squeeze(thisObj.connectivityMatrix),figH)
			ylabel('CA3 Place No.')
			xlabel('CA1 Dendritic Compartment No.')
			%title('Synaptic weight (mS/cm^2)')
			shading flat
			daspect([1 1 1])
			cb1=colorbar
			caxis([0 0.05])
			ylabel(cb1,'Synaptic weight (mS/cm^2)')
			
			figH2=figure;
			%subplot(2,1,2)
			omarPcolor(1:numDendriticCompartments,1:numPlaces,squeeze(thisObj.dendriticDelayTemplateMatrix),figH2)
			ylabel('CA3 Place No.')
			xlabel('CA1 Dendritic Compartment No.')
			%title('Delay to soma (msec)')
			shading flat
			daspect([1 1 1])
			cb2=colorbar
			ylabel(cb2,'Delay to soma (msec)')

			%uberTitle(sprintf('CA1 dendritic decoder of theta sequences (%d collaterals per CA3 place cell)', FeedForwardConnectivity.NUM_COLLATERALS))
			%uberTitle(sprintf('CA1 dendritic decoder of theta sequences'))
			title(sprintf('CA1 dendritic decoder of theta sequences'))
			%setFigFontTo(16)
			maxFigManual2d(1,1,16)
		end
	end

	methods(Access=private)
		function setConnectivityMatrix(thisObj,simSpecificInfo)
			numPlaces=simSpecificInfo.numPlaces;
			numCellsPerPlace=simSpecificInfo.numCellsPerPlace;
			thisObj.numPlaces=numPlaces;
			%numCollaterals=simSpecificInfo.numCollaterals;
			numCollaterals=FeedForwardConnectivity.NUM_COLLATERALS; 
			if(isfield(simSpecificInfo,'numCellsL2'))
				numCellsL2=simSpecificInfo.numCellsL2;
			else
				numCellsL2=1;
			end
			
			
			normFactor=DelayObject.NORM_FACTOR;
                        convFactor=DelayObject.CONV_FACTOR;
                        baselineDelay=DelayObject.BASELINE_DELAY;      
                        imax=DelayObject.IMAX;
                        imin=DelayObject.IMIN;

			tonicTemplateStepSize=(imax-imin)/numPlaces;
			
			numDendriticCompartments=numPlaces*numCollaterals;
			thisObj.numDendriticCompartments=numDendriticCompartments;
			thisObj.dendriticDelayTemplateMatrix=zeros(numPlaces,numDendriticCompartments, numCellsL2);
			%{
			%numDendriticCompartments=7;
			%numDendriticCompartments=numPlaces;
			fineStepSize=(imax-imin)/(numDendriticCompartments*5);
			tonicMidpoint=floor(numDendriticCompartments/2);
			tonicValueSequence=imax-(1:tonicMidpoint)*fineStepSize;
			
			%coarseStepSize=(imax-imin)/(numDendriticCompartments/2);
			numCoarseSteps=ceil(numDendriticCompartments/2)
			%tonicValueSequence((end+1):(end+numCoarseSteps))=linspace(imin,tonicValueSequence(end)-fineStepSize,numCoarseSteps);
			tonicValueSequence((end+1):(end+numCoarseSteps))=linspace(tonicValueSequence(end)-fineStepSize,imin,numCoarseSteps);
			%tonicValueSequence=imin+(numPlaces:-1:1)*(imax-imin)/numPlaces;
			%}
			%{
			tonicValueSequence=1./linspace(1/imax,1/imin,numDendriticCompartments);
			%tonicValueSequence=1./linspace(1/imin,1/imax,numDendriticCompartments);
			tonicValueSequence(1)=imax;
			for i=2:numDendriticCompartments
				stepSize=1/tonicValueSequence(i-1);
				tonicValueSequence(i)=tonicValueSequence(i-1)-3.4*stepSize;
			end
			figure; plot(diff(tonicValueSequence))
			%}

			%normFactor*log(convFactor*(imax-tonicValueSequence(i)))+baselineDelay
			%targetDelaySequence=NaN(size(tonicValueSequence));

			%syncTime=5;
			%maxDendriticDelay=59.5;
			%targetDelaySequence=maxDendriticDelay+syncTime-linspace(syncTime,maxDendriticDelay,numDendriticCompartments);

			%tonicValueSequence=linspace(imin,imax,numDendriticCompartments);	
			%x=logspace(log10(imin),log10(imax),100000);
			%defaultPhaseSlope=baselineDelay/(imax-imin);	
			%targetTime=syncTime+(normFactor*log(convFactor*(imax-imin))+baselineDelay+defaultPhaseSlope*(imax-imin)); %all arrive at soma 5msec after latest possible delay
			%v=targetTime-(normFactor*log(convFactor*(imax-x))+baselineDelay+defaultPhaseSlope*(x-imin));
			%v=normFactor*log(convFactor*(imax-x));
			%figure; plot(x,v,'bo')

			%targetDelaySequence=linspace(0,1/(ThetaPopInput.frequencyDefault),numDendriticCompartments);
			%for i=1:numDendriticCompartments
			%	[~,j]=min(abs(v-targetDelaySequence(i)));
			%	tonicValueSequence(i)=x(j);	
			%end
		
			stepSize=(imax-imin)/numDendriticCompartments;
			%tonicValueSequence=linspace(imin,imax,numDendriticCompartments);	
			tonicValueSequence=(imin+stepSize/2):stepSize:(imax-stepSize/2);
			%targetDelaySequence=normFactor*log(convFactor*(imax-tonicValueSequence)); %what to add to reach fiduciary T
			targetDelaySequence=normFactor*log(convFactor*(tonicValueSequence-imin)); %what to add to reach fiduciary T
			%tonicValueSequence=-(exp((targetDelaySequence-baselineDelay)/normFactor)/convFactor-imax);
			%tonicValueSequence=imin+(exp((targetDelaySequence)/normFactor)/convFactor);
			%hold on
			%plot([imin imax],[targetTime targetTime],'k-')
			%fds
			%targetTime=5+(normFactor*log(convFactor*(imin+(imax-imin)/2))+baselineDelay); %all arrive at soma 5msec after latest possible delay
			%for i=1:length(tonicValueSequence)
			%	targetDelaySequence(i)=targetTime-(normFactor*log(convFactor*(imax-tonicValueSequence(i)))+baselineDelay); %add remaining time to synchronous detection time
				%exp((expectedDelay-baselineDelay)/normFactor)/convFactor
			%end
			thisObj.connectivityMatrix=zeros(numPlaces,numDendriticCompartments,numCellsL2);

			%it got reversed- highest place num should be closest to soma; first should be farthest (most dendritic delay)
			%targetDelaySequence=fliplr(targetDelaySequence);

			for postSynL2CellNum=1:numCellsL2			
				%connectionCount=1;
				startCompartNum=numPlaces*numCollaterals;
				for preSynPlaceNum=1:numPlaces
					endCompartNum=startCompartNum-numCollaterals+1;;
					for compartmentNum=startCompartNum:-1:endCompartNum
						thisObj.dendriticDelayTemplateMatrix(preSynPlaceNum,compartmentNum,postSynL2CellNum)=targetDelaySequence(compartmentNum);
						 thisObj.connectivityMatrix(preSynPlaceNum,compartmentNum,postSynL2CellNum)=thisObj.weight_mu/(numPlaces*numCellsPerPlace);
						%connectionCount=connectionCount+1;	
					end
					startCompartNum=endCompartNum-1;
				end 
			end
		
			%thisObj.dendriticDelayTemplateMatrix	
			
			%don't generate all permutations - choose 49 of them with increasing DI score (the rest fall between these points!)
			%scale invariance through timing code (pattern completion)
			%resistance to amplitude change and dropout through MANY ARE EQUAL (pattern completion)
			%sequence separation/dynamic range through dendritic reader (pattern separation)
			%noise correlation ~ field overlap improves separation (pattern separation, completion [speed invariance]); is this part of our criteria for a causal sequence? [relative timestamps!!!]
			%show pairwise (or multiple) heat map of input/output ranges with increasing sequence differnence (pattern separation) vs increasing spacing error (pattern completion) vs increasing amplitude variability (pattern completion) 
			%%are they trading off? all virtues of timing code
			%this may be how we can tell what the essence of a sequence is amidst noise, may be the main job of CA3-CA1 circuit

			%demonstrate robustness to weird speed variations; perhaps a cool audio example?
			%throw in old sequence quality plots
			%compare against firing rate over window in CA3 population; synfire chain? 
			
			%thisObj.dendriticDelayTemplateMatrix=perms(targetDelaySequence)';		
			%for preSynPlaceNum=1:numPlaces
			%	for postSynL2CellNum=1:numCellsL2			
			%		%if(rand(1) < thisObj.pConn) 
			%		%	thisObj.connectivityMatrix(preSynCellNum,preSynPlaceNum,postSynCellNum,postSynPlaceNum)=normrnd(thisObj.weight_mu,thisObj.weight_sigma,1);
			%		%end
			%	end
			%end 
			
			
		end
	end
end
