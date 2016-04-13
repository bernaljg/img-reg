% Created by: Bernal Jimenez
% 03/17/2016
%  Since this function loads the tracked movies into both the affine transformation and the demons registration, nargin is used to allow the function to receive 3 or 4 inputs and the skipAffine flag can be given exclusively to the demons registration.

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
