% Created by: Bernal Jimenez
% 03/17/2016

function [fileNames, roiFullFiles, cziFullFiles, nMovies] = load_mov_names(mov_to_reg_dir)

files=dir(fullfile(mov_to_reg_dir,'*NMJ_ROIs.mat'));% select all ROI .mat files
nMovies = size(files,1); % number of movies to analyze

for movieNum = 1:nMovies
	fileName = files(movieNum).name;
	roiFullFiles{movieNum} = fullfile(mov_to_reg_dir,fileName);
	fileName(end-12:end)=[];
	fileNames{movieNum} = fileName;
	cziFullFiles{movieNum} = fullfile(mov_to_reg_dir,[fileName '.czi']);
end

