function [y]=getGaussianCurve(xVals,mu,sigma)
	y = exp(- 0.5 * ((xVals - mu) / sigma) .^ 2) / (sigma * sqrt(2 * pi));
