function [exitStatus] = runAnalysisOfSimBatch(paramName1,paramName2,paramName3,param1Vals,param2Vals,param3Vals)

	directory_names

	for i = 1:length(param1Vals)
		for j=1:length(param2Vals)
			for k=1:length(param3Vals)
				filePath=getRegexFilePath(DATA_DIR,sprintf('simData_%s_%.5f_%s_%.5f_%s_%.5f.mat',paramName1,param1Vals(i),paramName2,param2Vals(j),paramName3,param3Vals(k)));

				data=load(filePath);
				currSimObj=data.thisObj

				
			end
		end
	end

	exitStatus=1;
