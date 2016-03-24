% Created by: Bernal Jimenez
% 03/17/2016

function [affined_nmjs] = load_affined_nmjs(nNmjs,affinedFileNames)

	affined_nmjs = cell(nNmjs,1);
	for affined_nmjieNum = 1:nNmjs   
	    load(affinedFileNames(affined_nmjieNum).name,'affine','maxFrameNum')
	    affined_nmjs{affined_nmjieNum,1}=affine;
	    clear affine
	end   
