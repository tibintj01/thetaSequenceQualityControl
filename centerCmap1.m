function [] = centerCmap1(matr)
	lb=prctile(matr(:),5);
	ub=(1-lb)+1;
	caxis([lb ub])
