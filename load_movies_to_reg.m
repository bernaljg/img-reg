% Created by: Bernal Jimenez
% 03/17/2016


function [mov_to_reg_dir, output_dir] = choose_dirs()

disp('Choose folder containing czi movies');
mov_to_reg_dir = uigetdir;
disp('Choose folder to save registered movies');
output_dir = uigetdir;

end

function [roiFiles, cziFiles, nMovies] = load_mov_names()

cd(mov_to_reg_Dir)
roiFiles=dir(fullfile(cd,'*NMJ_ROIs.mat')); % select all ROI .mat files
nMovies = size(roiFiles,1); % number of movies to analyze

for movieNum = 1:nMovies
	fname = roiFiles(movieNum).name;
	fname(end-12:end)=[];
	cziFiles(movieNum,1) = dir([fname '.czi']);
end

end

