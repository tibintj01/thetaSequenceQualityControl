function [isOnLocalComputer]=onLocalComputer()

isOnLocalComputer=0;
currDir=pwd;
if(contains(currDir,'/Users/tibinjohn'))
        isOnLocalComputer=1;
end
