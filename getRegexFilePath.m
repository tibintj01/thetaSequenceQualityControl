function [matFilePaths]=getRegexFilePaths(dirName,regexStr)
                dirInfo=dir(fullfile(dirName,regexStr));
                fileNames={dirInfo(:).name};
                matFilePaths=fullfile(dirName,fileNames);
		if(length(matFilePaths)==1)
			matFilePaths=matFilePaths{1};
		end

