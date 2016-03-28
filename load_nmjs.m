% Created by: Bernal Jimenez
% 03/17/2016

function [nmjMovies] = load_nmjs(nNmjs,FileNames)

	nmjMovies = cell(nNmjs,1);
	for nmj = 1:nNmjs   
	    load(FileNames(nmj).name,'nmjMovie');
	    nmjMovies{nmj,1}=nmjMovie;
	    
	    clear nmjMovie
	end   
