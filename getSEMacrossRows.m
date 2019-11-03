function [semRowVector] = getSEMacrossRows(dataMatrix)
        semRowVector=nanstd(dataMatrix,[],1)./sqrt(sum(~isnan(dataMatrix),1));
