function [pVal] = analyzeSummaryStatisticDiffByBootstrap(vec1,vec2,statName,titleStr)
	groupVec=[vec1(:); vec2(:)];

	numEl1=length(vec1);


	%statName='COV';	

	numElem=length(groupVec);
	numResamples=100000;

	bootstrappedDiffs=NaN(numResamples,1);
	disp('getting bootstrapped stat variability.....')
	tic
	for i=1:numResamples
		currPerm=randperm(numElem);
		currGroupVec=groupVec(currPerm);
		currVec1=currGroupVec(1:numEl1);
		currVec2=currGroupVec((numEl1+1):end);
	
		if(strcmp(statName,'COV'))
			 currStatValVec1=nanstd(currVec1(:),[],1)./nanmean(currVec1(:),1);
			 currStatValVec2=nanstd(currVec2(:),[],1)./nanmean(currVec2(:),1);
		end	
		
		currStatDiff=currStatValVec2-currStatValVec1;		
		bootstrappedDiffs(i)=currStatDiff;
	end

	toc


	if(strcmp(statName,'COV'))
		obsStat1=nanstd(vec1(:),[],1)./nanmean(vec1(:),1);
		obsStat2=nanstd(vec2(:),[],1)./nanmean(vec2(:),1);
	end

	obsStatDiff=obsStat2-obsStat1;

	threshSigDiff=prctile(bootstrappedDiffs,99);
	
	sortedDiffs=sort(bootstrappedDiffs);
	[~,closestDiffIdx]=min(abs(sortedDiffs-obsStatDiff));
	pVal=1-(closestDiffIdx/length(bootstrappedDiffs));

	figure
	numBins=500;
	edges=linspace(prctile(bootstrappedDiffs,0.1),prctile(bootstrappedDiffs,99.9),numBins)
	histogram(bootstrappedDiffs,edges)
	hold on

	xlabel(sprintf('%s difference',statName))
	ylabel('Count')

	currYlims=ylim;
	plot([threshSigDiff threshSigDiff],currYlims,'k--','LineWidth',5)
	hold on
	plot([obsStatDiff obsStatDiff],currYlims,'b--','LineWidth',5)
	legend(sprintf('shuffled %s diffs',statName),sprintf('99th percentile shuffled %s diff',statName),sprintf('observed %s diff',statName),'Location','Best')

	if(exist('titleStr'))
		title(removeUnderscores(sprintf('%s, p=%.6f', titleStr,pVal)))
		%saveas(gcf,sprintf('%s.tif',titleStr))
	end

