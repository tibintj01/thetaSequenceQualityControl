
figure
ax1=subplot(6,1,1)
plot(timeAxis,v(:,1), 'LineWidth',2);
title('place cell membrane potential')
hold on
%ylim([-75 -30])
ylim([-75 10])
currYlim=ylim
ylimSpan=diff(currYlim);
for subPeakNum=1:length(subTpeakTimes)
	plot([subTpeakTimes(subPeakNum) subTpeakTimes(subPeakNum)],[currYlim(1) currYlim(1)+ylimSpan/5],'k--', 'LineWidth',2);
end
ylabel('V_m (mV)')


ax2=subplot(6,1,2)

plot(timeAxis,iDriveRecord, 'LineWidth',2);
title('place field ramp input')
ylabel('I_{app}')

hold on
for subPeakNum=1:length(subTpeakTimes)
        plot([subTpeakTimes(subPeakNum) subTpeakTimes(subPeakNum)],ylim,'k--', 'LineWidth',2);
end

ax3=subplot(6,1,3)

yyaxis left
p1=plot(timeAxis,g_Inh,'b-', 'LineWidth',2)
hold on
p2=plot(timeAxis,g_Exc,'g-','LineWidth',2)
title('feedforward theta synaptic conductance')
ylabel('mS/cm^2')

yyaxis right
%had to subtract mean to get phase!! (negative so 180==trough)

plot(timeAxis,g_Inh_Phase,'r')
ylabel('Inh phase')



hold on
for subPeakNum=1:length(subTpeakTimes)
        plot([subTpeakTimes(subPeakNum) subTpeakTimes(subPeakNum)],ylim,'k--', 'LineWidth',2);
end
legend([p1 p2],{'g_{Inh}','g_{Exc}'})

ax4=subplot(6,1,4)
plot(timeAxis,totalFeedFwdSynDrive, 'LineWidth',2);
title('feedforward theta synaptic current')

ylabel('I_{syn}')
hold on
for subPeakNum=1:length(subTpeakTimes)
        plot([subTpeakTimes(subPeakNum) subTpeakTimes(subPeakNum)],ylim,'k--', 'LineWidth',2);
end


ax5=subplot(6,1,5)
yyaxis left
p3=plot(timeAxis,mnap(:,1), 'LineWidth',2);
hold on
ylabel('Prob')
yyaxis right
p4=plot(timeAxis,nks(:,1), 'LineWidth',2);
title('rhythm generating current gating variables')

hold on
for subPeakNum=1:length(subTpeakTimes)
        plot([subTpeakTimes(subPeakNum) subTpeakTimes(subPeakNum)],ylim,'k--', 'LineWidth',2);
end

legend([p3 p4],{'m_{nap}','n_{ks}'})


%g_Inh_Phase = (g_Inh_Phase/pi) *180;


ylabel('Prob')

ax6=subplot(6,1,6)
plot(subTpeakTimes,subTpeakPhases,'o','MarkerSize',7,'MarkerFaceColor',[0    0.4470    0.7410])
%ylim([0 360])
%ylim([270 360])
%ylim([180 360])
ylim([100 360])

ylabel('Phase (degrees)')

hold on
%for subPeakNum=1:length(subTpeakTimes)
%        plot([subTpeakTimes(subPeakNum) subTpeakTimes(subPeakNum)],ylim,'k--', 'LineWidth',2);
%end




linkaxes([ax1 ax2 ax3 ax4 ax5 ax6],'x')
xlabel('Time (msec')
baselinePeriod=median(diff(spikeTimes(spikeTimes<equilibrateTime)))
ISIs=diff(spikeTimes);




hold on

plot(placeFieldTimes,linFit(1)+linFit(2)*(placeFieldTimes-placeFieldTimes(1)),'b--')
title(sprintf('phase of subthreshold peaks and spikes; slope: %.2f deg/sec, intercept: %.2f deg',linFit(2)*1000,linFit(1)))
%model=placeFieldTimes\placeFieldPhases

uberTitle(sprintf('G_{NaP}=%.2f, G_{KS}=%.2f',gnap,gks))

maxFigManual2d(1,2)
saveas(gcf,sprintf('phasePrecessionDetails_%sSingleCell.tif',sprintf('gNaP_%.2f_gKS_%.2f',gnap,gks)))
% plot(timeAxis,n(:,1),'r')
% hold on
% plot(timeAxis,h(:,1),'b')
% plot(timeAxis,z(:,1),'g')
% 
% legend('n','h','z')
