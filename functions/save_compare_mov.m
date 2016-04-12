%Created by: Bernal Jimenez
%4/11/2016

function [] = save_compare_mov(directory, filename)

load([directory '/demon/' filename],'demon')
load([directory '/demon_affine/' filename],'demon_affine')
size_mov = size(demon);
padding = zeros(25,size_mov(2),size_mov(3));

movie1 = demon;
movie2 = demon_affine;
compare_mov = cat(1,movie1,padding,movie2);

save_movie(compare_mov, fullfile(directory, [filename '_Comparison_Movie']))
