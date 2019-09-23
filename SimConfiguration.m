classdef SimConfiguration < handle & matlab.mixin.Copyable

	properties
		simParams
		%simsCategory='single_cell_precession_tuning';
		simsCategory='single_cell_timeConstVsPhaseLocking';
		simParamsIDStr
		%simsCategory='single_cell_precession_tuning';
		
		saveDirectoryBaseRawData='../results/%s/raw_data';
		%saveDirectoryFigures='../results/%s/figures';

		saveDirectoryRawData
	end

	methods
		function thisConfig=SimConfiguration(settingsStr)
			if(nargin==1 && strcmp(settingsStr,'default'))
				thisConfig.setSimProps();
			end
		end
	
		function printConfig(configObj)
			disp('***********simulation configuration********** ')
			disp(' ')
			disp(configObj.simParams)
			disp('***********cell configuration**************** ')
			disp(configObj.simParams.simCells)
			disp('********************************************* ')
			disp('***********initial conditions**************** ')
			disp(configObj.simParams.simCells.v(:,:,1))
			disp('********************************************* ')
		end

		function numCells=getNumCells(configObj)
			numCells=configObj.simParams.numPlaces*configObj.simParams.numCellsPerPlace;
		end

	end

	methods(Access=private)
		function setSimProps(thisObj)
			directory_names
			saveDirectoryBaseRawData=[DATA_DIR '%s/raw_data'];
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%global parameters
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%set simulation time, stepsize
			%simTime=2500    %msec
			simTime=1000    %msec
			%simTime=2000    %msec
			%simTime=3000    %msec
			%simTime=4000    %msec
			%simTime=250    %msec
			%dt=0.01
			%dt=0.005
			%dt=0.0001
			%dt=0.001
			dt=0.002
			%equilibrateTime=5000;
			%set randomization seed to constant
			rng(1)

			%numPlaces=1;
			%numCellsPerPlace=1;
			%numPlaces=2;
			%numPlaces=5;
			%numPlaces=4;
			%numCellsPerPlace=2;
			%numCellsPerPlace=4;
			%numPlaces=8;
			%numCellsPerPlace=3;
			%numPlaces=1;
			%numPlaces=5;
			%numCellsPerPlace=30;
			%numPlaces=4;
			numPlaces=1;
			%numCellsPerPlace=3;
			%numCellsPerPlace=2;
			numCellsPerPlace=1;
			%numCellsPerPlace=100;

			%numCellsPerPlace=18;
			maxPlaceEndTime=Inf;
			%reset simTime until fits end runing time of rodent
				while(maxPlaceEndTime>simTime) 
					for i=1:2	
						timeAxis=(dt:dt:simTime).';
						simProps.simTime=simTime;
						numSteps=round(simTime/dt);
						
						simProps.numSteps=numSteps;
						simProps.dt=dt;
						simProps.timeAxis=timeAxis;
						
						simProps.numPlaces=numPlaces;
						simProps.numCellsPerPlace=numCellsPerPlace;

						extEnvSettings.timeAxis=timeAxis;
						extEnvSettings.rodentRunningSpeed=linspace(20,20,length(timeAxis));  %cm/s
						
						%extEnvSettings.rodentRunningSpeed=[linspace(10,40,floor(length(timeAxis)/2)), linspace(40,10,floor(length(timeAxis)/2))];  %cm/s
						%extEnvSettings.rodentRunningSpeed=[linspace(40,10,floor(length(timeAxis)/2)), linspace(10,40,floor(length(timeAxis)/2))];  %cm/s
						extEnvSettings.numPlaces=numPlaces;			
						externalEnvironmentObj=ExternalEnvironment(extEnvSettings);

						%simTime
						maxPlaceEndTime=externalEnvironmentObj.maxPlaceEndTime
						%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
						if(numCellsPerPlace*numPlaces==1)% one cell experiments more control over simTime
							maxPlaceEndTime=simTime;
						end
						%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					
						if(i==1)	
								simTime=ceil(maxPlaceEndTime)
						end
					end	
				end
		%fds

			simProps.extEnvObj=copy(externalEnvironmentObj);
		

			simCells=copy(Cells(simProps));
			%simProps.simParamsIDStr=sprintf('gnapMu_%.5f_gnapSigma_%.5f_gksMu_%.5f_gksSigma_%.5f_Connectivity_%s',cellProps.gnapBar,cellProps.gnapSigma,cellProps.gksBar,cellProps.gksSigma,cellProps.internalConnObj.connectivityTypeStr)
			%simCells=Cells(cellProps);

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%group simulation properties into struct
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			simProps.simCells=copy(simCells);
			simProps.thetaPopInput=copy(simCells.inhThetaInputArray);
			%simProps.thetaPopInput.displayContent();
			simProps.externalEnvironmentObj=copy(externalEnvironmentObj);		
	
			thisObj.simParams=simProps;
		end
	end
end
