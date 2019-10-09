classdef InternalConnectivity < handle & matlab.mixin.Copyable
	%encapsulate data and actions of connectivity to keep my interface and implementation details separate
	properties
		connectivityMatrix
		startCouplingTime=0;
		%tausyn=5				%AMPA
		tausyn=2				%AMPA
		synapseTypeStr='E'
		%connectivityTypeStr='directed'
		connectivityTypeStr='none'

		numPlaces
		numCellsPerPlace
		timeAxis

		pConn=0.3

		p_IntraPlaceConn=0.4
		p_NextPlaceConn=0.8

		weight_mu=0.02
		weight_sigma=0.0025
		esyn_E=0;
		esyn_I=-72;

	end

	methods
		function thisObj=InternalConnectivity(simSpecificInfo)
			thisObj.numPlaces=simSpecificInfo.numPlaces;
			thisObj.numCellsPerPlace=simSpecificInfo.numCellsPerPlace;
			thisObj.timeAxis=simSpecificInfo.timeAxis;	
	
			%{	
			thisObj.tausyn=internalConnParams.tausyn;
			thisObj.weight_mu=internalConnParams.weight_mu;
			thisObj.weight_sigma=internalConnParams.weight_sigma;

			thisObj.connectivityTypeStr=internalConnParams.connectivityTypeStr;
			thisObj.synapseTypeStr=internalConnParams.synapseTypeStr;
			%thisObj.simConfig=internalConnParams.simConfig;

			if(thisObj.numCellsPerPlace*thisObj.numPlaces==1)
                                thisObj.connectivityTypeStr='SingleCell';
                        end

			if(strcmp(thisObj.connectivityTypeStr,'random'))
				thisObj.pConn=internalConnParams.pConn;
			elseif(strcmp(thisObj.connectivityTypeStr,'directed'))
				thisObj.p_IntraPlaceConn=internalConnParams.p_IntraPlaceConn;
				thisObj.p_NextPlaceConn=internalConnParams.p_NextPlaceConn;
			end
			%}
			thisObj.setConnectivityMatrix()
		end

		%heatmap showing matrix of matrices - each place-place combination having a cell-cell matrix
		function displayContent(thisObj)
			numPlaces=thisObj.numPlaces;
			numCellsPerPlace=thisObj.numCellsPerPlace;

			placeMetaConnMatrix=NaN(numPlaces*numCellsPerPlace,numPlaces*numCellsPerPlace);

                        for preSynPlaceNum=1:numPlaces
                                for postSynPlaceNum=1:numPlaces
					for preSynCellNum=1:numCellsPerPlace
                                                for postSynCellNum=1:numCellsPerPlace
							metaRow=(preSynPlaceNum-1)*numCellsPerPlace+preSynCellNum;
							metaCol=(postSynPlaceNum-1)*numCellsPerPlace+postSynCellNum;

							placeMetaConnMatrix(metaRow,metaCol)=thisObj.connectivityMatrix(preSynCellNum,preSynPlaceNum,postSynCellNum,postSynPlaceNum);		
						end
					end
				end
			end

			%pcolor(placeMetaConnMatrix
			figure
			imagesc(placeMetaConnMatrix)
			shading flat
			daspect([1 1 1])
			colorbar
		end
	end

	methods(Access=private)
		function setConnectivityMatrix(thisObj)
			numCellsPerPlace=thisObj.numCellsPerPlace;
			numPlaces=thisObj.numPlaces;
			thisObj.connectivityMatrix=zeros(numCellsPerPlace,numPlaces, numCellsPerPlace,numPlaces);
		
		
	
			for preSynCellNum=1:numCellsPerPlace
				for preSynPlaceNum=1:numPlaces
					for postSynCellNum=1:numCellsPerPlace
						for postSynPlaceNum=1:numPlaces
							
							if(strcmp(thisObj.connectivityTypeStr,'random'))
								if(rand(1) < thisObj.pConn) 
									thisObj.connectivityMatrix(preSynCellNum,preSynPlaceNum,postSynCellNum,postSynPlaceNum)=normrnd(thisObj.weight_mu,thisObj.weight_sigma,1);
								end
							elseif(strcmp(thisObj.connectivityTypeStr,'directed'))
								if(postSynPlaceNum==preSynPlaceNum+1)
									if(rand(1) < thisObj.p_NextPlaceConn) 
										thisObj.connectivityMatrix(preSynCellNum,preSynPlaceNum,postSynCellNum,postSynPlaceNum)=normrnd(thisObj.weight_mu,thisObj.weight_sigma,1);
									end
								elseif(postSynPlaceNum==preSynPlaceNum)
									if(rand(1) < thisObj.p_IntraPlaceConn) 
										thisObj.connectivityMatrix(preSynCellNum,preSynPlaceNum,postSynCellNum,postSynPlaceNum)=normrnd(thisObj.weight_mu,thisObj.weight_sigma,1);
									end
								end
							end

						end
					end
				end 
			end	
		
		end
	end
end
