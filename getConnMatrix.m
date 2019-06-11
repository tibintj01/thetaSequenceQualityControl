function [connectivityMatrix]= getConnMatrix(numCells,ave_w,sig_w,connProb)

        %ave_w=0.07;
        %sig_w=0.01;
        rndWeight=normrnd(ave_w,sig_w,numCells,numCells)
        %tausyn=5;
        %esyn=-10;
        connectivityMatrix=ones(numCells,numCells);

        %connProb=0.3;

        for i=1:numCells
            for j=1:numCells
                if(i~=j && rand<connProb)
                    connectivityMatrix(i,j)=connectivityMatrix(i,j)*rndWeight(i,j);
                    connectivityMatrix(i,j)
                else
                    connectivityMatrix(i,j)=0;
                end
            end
        end

        
        figure
        imagesc(connectivityMatrix)
        %shading interp
        colorbar
        colormap(jet)
        drawnow
