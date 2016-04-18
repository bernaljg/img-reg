% Created by: Bernal Jimenez
% 03/17/2016


function [mov_to_reg_dir, output_dir] = choose_dirs()

dir = pwd

try
disp('Choose folder containing czi movies');
mov_to_reg_dir = uigetdir;
catch
mov_to_reg_dir = [getenv('DATA_PATH') '/img-reg']
end

try
disp('Choose folder to save registered movies');
output_dir = uigetdir;
catch
output_dir =  [getenv('OUTPUT_PATH') '/img-reg']
end
