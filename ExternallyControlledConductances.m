classdef ExternallyControlledConductances < handle  & matlab.mixin.Copyable 

	properties
		timeAxis
		typeStr

		baselineMatrix
		amplitudeMatrix
	
		esyn
		conductanceTimeSeries
	end

	methods
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Constructor
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function thisObj=ExternallyControlledConductances(extInParams)
			if(nargin==1)
				thisObj.timeAxis=extInParams.timeAxis;
				thisObj.typeStr=extInParams.typeStr;
				
				thisObj.baselineMatrix=extInParams.baselineMatrix;
				thisObj.amplitudeMatrix=extInParams.amplitudeMatrix;
				thisObj.esyn=extInParams.esyn;
			end
		end

		function displayContent(thisObj)
			figure
			count=0;
			
			nr=size(thisObj.amplitudeMatrix,1);
                        nc=size(thisObj.amplitudeMatrix,2);

			axHs=[];
			for r=1:nr
				for c=1:nc
					count=count+1;
					axH=subplot(nr,nc,count)
					plot(thisObj.timeAxis,squeeze(thisObj.conductanceTimeSeries(r,c,:)))
					axHs=[axHs axH];
				end
			end

			linkaxes(axHs,'xy')

			xlim([thisObj.timeAxis(1) thisObj.timeAxis(end)])
			maxFigManual2d(3,1,28)
			saveas(gcf,'currentThetaInputArray.tif')
		end

	end

	methods(Abstract)
		setConductanceTimeSeries(thisObj)
	end
end
