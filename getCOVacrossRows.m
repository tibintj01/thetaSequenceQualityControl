function [covRowVector] =getCOVacrossRows(dataMatrix)
        covRowVector=nanstd(dataMatrix,[],1)./nanmean(dataMatrix,1);
