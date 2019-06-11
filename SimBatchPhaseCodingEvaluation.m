classdef SimBatchPhaseCodingEvaluation < handle
	
	properties
		simEvaluationArray
		simObjArray
	end

	methods
		function thisObj=SimBatchPhaseCodingEvaluation()
			thisObj.simEvaluationArray=simEvaluationArray;
		end

		function plotSummaryFigure(thisObj)

		end
		
		function run(thisObj)
			for i=1:size(simEvaluationArray,1)
				for j=1:size(simEvaluationArray,2)
					simEvaluationArray(i,j).run()	
				end
			end
		end
	end
end
