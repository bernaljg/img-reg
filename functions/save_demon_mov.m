% Created by: Bernal Jimenez
% 03/17/2016


function [] = save_demon_mov(demonized_mov,disp_fields,FileNames,nNmjs,skipAffine)

	for demonMovieNum = 1:nNmjs   
	    demon=demonized_mov{demonMovieNum,1};
	    demonDispFields=disp_fields{demonMovieNum,1};
	    if skipAffine
		mkdir('demon')
	    	FileNameApp = strcat('demon/', FileNames(demonMovieNum).name);
    	 else
	    	FileNameApp = FileNames(demonMovieNum).name;
	    	save(FileNameApp,'demonDispFields','demon','-append')
        end
	    clear demon demonDispFields
    end
