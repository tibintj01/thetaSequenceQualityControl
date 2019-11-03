parpool(19)
parfor p=1:192
%parfor p=1:384
	numValues1=12;
	numValues2=16;
	numValues3=1;
	
	idxList=NaN(192,3);
	
	count=1;
	for i=1:numValues1
	   for j=1:numValues2
		for k=1:numValues3
			idxList(count,1)=i;	
			idxList(count,2)=j;	
			idxList(count,3)=k;	
			count=count+1;
		end
	    end
	end
	curr_i=idxList(p,1);
	curr_j=idxList(p,2);
	curr_k=idxList(p,3);


	scanParamNames={'DI_SORTED_PERM_RANK','CONSTANT_RUN_SPEED','USE_LINEAR_DELAYS'}

	scanParam1Values=[1, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5040];
	scanParam2Values=linspace(15,45,16);
	scanParam3Values=[0];

	disp(sprintf('extracting values for %d %d %d',curr_i,curr_j,curr_k))
	tic
	%exitStatus=runAnalysisOfSimBatchPar(scanParamNames{1},scanParamNames{2},scanParamNames{3},scanParam1Values,scanParam2Values,scanParam3Values,curr_i,curr_j,curr_k);
	exitStatus=runSpikingAnalysisOfSimBatchPar(scanParamNames{1},scanParamNames{2},scanParamNames{3},scanParam1Values,scanParam2Values,scanParam3Values,curr_i,curr_j,curr_k);
	
	disp(sprintf('DONE extracting values for %d %d %d',curr_i,curr_j,curr_k))
	toc
end
