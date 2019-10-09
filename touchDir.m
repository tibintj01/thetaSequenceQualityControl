function [] = touchDir(dirPath)
	if(~isdir(dirPath))
		mkdir(dirPath)
	end
