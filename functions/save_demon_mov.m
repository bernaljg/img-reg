% Created by: Bernal Jimenez`
% 03/17/2016


function [] = save_demon_mov(demonized_mov,disp_fields,directory,FileNames,nNmjs,skipAffine)

	for demonMovieNum = 1:nNmjs   
	    demon=demonized_mov{demonMovieNum,1};
	    demonDispFields=disp_fields{demonMovieNum,1};
        
	    if skipAffine
            demon_dir = fullfile(directory,'demon')
            mkdir(demon_dir)
	    	FileNameApp = fullfile(demon_dir, FileNames(demonMovieNum).name);
            disp('Saving new file for demon and dfield')
            save(FileNameApp,'demonDispFields','demon','-v7.3');
        else
            demon_affine_dir = fullfile(directory,'demon_affine')
	    demon_affine = demon;
            mkdir(demon_affine_dir)
	    FileNameApp = fullfile(demon_affine_dir, FileNames(demonMovieNum).name);
            disp('appending demon and dfield')
            save(FileNameApp,'demonDispFields','demon_affine','-v7.3');
	    end


	clear demon demonDispFields
        end
