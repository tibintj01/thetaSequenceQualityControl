%initialize model
gsyn=zeros(numSteps,numCells);
v=zeros(numSteps,numCells);
n=zeros(numSteps,numCells);
m=zeros(numSteps,numCells);

h=zeros(numSteps,numCells);
mka=zeros(numSteps,numCells);
hka=zeros(numSteps,numCells);

kappaH=zeros(numSteps,numCells);
mnap=zeros(numSteps,numCells);
nks=zeros(numSteps,numCells);

pulse=zeros(numSteps,1);

%initial conditions
v(1,:)=normrnd(-60,3,numCells,1);
n(1,:)=normrnd(0.1,0.01,numCells,1);
m(1,:)=normrnd(0.1,0.01,numCells,1);

h(1,:)=normrnd(0.1,0.1,numCells,1);
mka(1,:)=normrnd(0.1,0.1,numCells,1);
hka(1,:)=normrnd(0.1,0.1,numCells,1);

kappaH(1,:)=normrnd(0.1,0.1,numCells,1);
mnap(1,:)=normrnd(0.1,0.1,numCells,1);
nks(1,:)=normrnd(0.1,0,numCells,1);
%h(1,:)=normrnd(0.5,0.1,numCells,1);
%z(1,:)=normrnd(0.5,0,numCells,1);

totalSynapticCurrent=zeros(numSteps,1);
