%Created by: Bernal Jimenez
%4/11/2016

function [] = save_compare_mov(directory, movie1, movie2)

size_mov = size(movie1);
padding = zeros(25,size_mov(2),size_mov(3));

compare_mov = cat(1,movie1,padding,movie2);

save_movie(compare_mov, fullfile(directory, 'Comparison_Movie2'))
