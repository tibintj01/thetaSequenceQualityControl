%create connectivity weight matrix
if(numCells>1)
        %tausyn=0.5;

        synCurrentIdxes=1:round(400/dt);
        periodSampleLength=min(length(synCurrentIdxes),round(approxPeriod/dt));
        
        %rawArea=sum(exp(-dt*(synCurrentIdxes-(step+1))/tausyn));
        rawArea=sum(exp(-dt*(synCurrentIdxes(1:periodSampleLength))/tausyn));
        normWeight=CONDUCT_AREA/rawArea;
        
        ave_w=normWeight*3
       
        %fds
        
        %ave_w=0.07;
        %sig_w=0.01;
        sig_w=ave_w/5;
        %sig_w=0;
        
        %connProb=0.3;
        %connProb=0.02;
            connProb=0.03;
            
        if(allToAll)
           connProb=1; 
           sig_w=0;
        end
         %connProb=0.1;
        
        %connProb=0.1;
        
         if(blockAllSynapses)
            ave_w=0;
            sig_w=0;
        end
        
        [connectivityMatrix]= getConnMatrix(numCells,ave_w,sig_w,connProb);
        %if(numCells==2 && uniDir)
        %    connectivityMatrix=[0 1; 0 0];
        %end
        esyn=0;
        
end

%get random drive to each neuron
%ave_gtonic=0.1
%g_tonic_sig=0.0001;
%g_tonic=normrnd(ave_gtonic,g_tonic_sig,numCells,1);
%etonic=0;

