function [m,b,R]=getLinearFit(x,y)

	X=[ones(length(x),1) x(:)];

	linFit=(X.'*X)\(X.'*y(:));

	m=linFit(2);
	b=linFit(1);

	[rMatr,pMatr]=corrcoef(x(:),y(:));

	R=rMatr(2,1);
	p=pMatr(2,1);
