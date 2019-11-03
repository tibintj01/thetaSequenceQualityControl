heatMapInput.heatMatrix=currHeatMatrix;
heatMapInput.modelResponseVarName=modelResponseVarName;
if(exist('climVals'))
	heatMapInput.climVals=climVals;
else
	heatMapInput.climVals=[-Inf Inf];
end
try
	heatMapInput.titleStr=titleStrs{linearTimeCoding2};
catch
	heatMapInput.titleStr=titleStrs{i};

end
heatMapIt(heatMapInput)
