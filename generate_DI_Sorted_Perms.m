function [] = generate_DI_Sorted_Perms(numPlaces)

	if(~exist('numPlaces'))
		numPlaces=5;
	end


	originalPerms=perms(1:numPlaces);


	diCol=getDI(originalPerms);

	originalPerms=[originalPerms diCol(:)];

	numCols=size(originalPerms,2);
	sortedPerms=sortrows(originalPerms,numCols);

	DIs=sortedPerms(:,end);

	sortedPerms=sortedPerms(:,1:(numCols-1));

	save(sprintf('DI_SORTED_%d_PERMUTATIONS.mat',numPlaces),'sortedPerms','DIs')
