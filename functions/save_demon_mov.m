% Created by: Bernal Jimenez
% 03/17/2016


function [] = save_demon_mov(demonized_mov,disp_fields,FileNames,nNmjs)

	for demonMovieNum = 1:nNmjs   
	    demon=demonized_mov{demonMovieNum,1};
	    demonDispFields=disp_fields{demonMovieNum,1};
	    FileNameApp = strcat('demon', FileNames(demonMovieNum).name);
	    save(FileNameApp,'demonDispFields','demon')
	    clear demon demonDispFields
    end
