% Created by: Bernal Jimenez
% 03/17/2016

function [nmjMovies] = load_nmjs(nNmjs,directory,FileNames,skipAffine)
	
	switch nargin

	case 3
	nmjMovies = cell(nNmjs,1);
	for nmj = 1:nNmjs
            load([directory '/track/' FileNames(nmj).name],'nmjMovie');
            nmjMovies{nmj,1}=nmjMovie;
            clear nmjMovie
	end

	case 4
	nmjMovies = cell(nNmjs,1);
	for nmj = 1:nNmjs
        if skipAffine
            load([directory '/track/' FileNames(nmj).name],'nmjMovie');
            nmjMovies{nmj,1}=nmjMovie;
            clear nmjMovie
        else
            load([directory '/affine/' FileNames(nmj).name],'nmjMovie');
            nmjMovies{nmj,1}=nmjMovie;
            clear nmjMovie
        end
	end
end	
