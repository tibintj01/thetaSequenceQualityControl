eWeight=0.01;
eWeight=0.05;
%iWeight=eWeight/(8.1325);
%iWeight=eWeight/(3.5781);
iWeight=eWeight;
dt=0.002;
tausyn_E=2;
tausyn_I=6;

step=1;

synEndStep=step+1+round(50/dt);
synCurrentIdxes=(step+1):synEndStep;

synTimeAxis=dt*(synCurrentIdxes-(step+1));

gsyn_E=eWeight*exp(-synTimeAxis/tausyn_E);
gsyn_I=iWeight*(synTimeAxis/tausyn_I).*exp(1-(synTimeAxis/tausyn_I));

%vTyp=-47;
vTyp=-45;
typicalDrivingForceE=(vTyp-(0));
typicalDrivingForceI=(vTyp-(-72));
isyn_E=gsyn_E*typicalDrivingForceE
isyn_I=gsyn_I*typicalDrivingForceI;

%totalE=sum(gsyn_E)
%totalI=sum(gsyn_I)

totalE=sum(isyn_E)
totalI=sum(isyn_I)


figure;
plot(synTimeAxis,gsyn_E,'g','LineWidth',5)
hold on
plot(synTimeAxis,gsyn_I,'b','LineWidth',5)
xlabel('Time (msec)')


