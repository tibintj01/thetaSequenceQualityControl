function [DI]=getDI(numList)
	matrixMode=0;
	if(size(numList,1)>1 && size(numList,2)>1)
		matrixMode=1;
	end

if(matrixMode)
	numRows=size(numList,1);
	DI=NaN(numRows,1);

	for r=1:numRows

	    cmpcount=0;
	    swapcount = 0;
	   
            numRow=numList(r,:);
 
	    for j=0:(length(numRow)-1)
		for i =1:(length(numRow)-j-1)
		    cmpcount =cmpcount+1;
		    if numRow(i-1+1) > numRow(i+1)
			swapcount =swapcount+1;
			temp=numRow(i-1+1);
			numRow(i-1+1)=numRow(i+1);
			numRow(i+1)=temp;
		    end
		end
	    end

		DI(r)=swapcount;

	end
else
    cmpcount=0;
    swapcount = 0;
    
    for j=0:(length(numList)-1)
        for i =1:(length(numList)-j-1)
            cmpcount =cmpcount+1;
            if numList(i-1+1) > numList(i+1)
                swapcount =swapcount+1;
                temp=numList(i-1+1);
		numList(i-1+1)=numList(i+1);
		numList(i+1)=temp;
    	    end
	end
    end

	DI=swapcount;

end
