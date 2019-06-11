function [] = centerCmap(matr)
	lb=prctile(matr(:),5);
	ub=-lb;
	caxis([lb ub])
