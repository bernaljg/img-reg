% Created by: Bernal Jimenez
% 03/17/2016

function [roiFiles, cziFiles, nMovies] = load_mov_names(mov_to_reg_dir)

cd(mov_to_reg_dir)
roiFiles=dir(fullfile(cd,'*NMJ_ROIs.mat')); % select all ROI .mat files
nMovies = size(roiFiles,1); % number of movies to analyze

for movieNum = 1:nMovies
	fname = roiFiles(movieNum).name;
	fname(end-12:end)=[];
	cziFiles(movieNum,1) = dir([fname '.czi']);
end

