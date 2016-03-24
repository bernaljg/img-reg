% Created by: Bernal Jimenez
% 03/17/2016


function [mov_to_reg_dir, output_dir] = choose_dirs()

disp('Choose folder containing czi movies');
mov_to_reg_dir = uigetdir;
disp('Choose folder to save registered movies');
output_dir = uigetdir;

