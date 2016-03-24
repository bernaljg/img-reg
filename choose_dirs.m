% Created by: Bernal Jimenez
% 03/17/2016


function [mov_to_reg_dir, output_dir] = choose_dirs()

disp('Choose folder containing czi movies');

try
mov_to_reg_dir = uigetdir;
catch
mov_to_reg_dir = pwd
end

disp('Choose folder to save registered movies');

try
output_dir = uigetdir;
catch
output_dir = pwd
end
