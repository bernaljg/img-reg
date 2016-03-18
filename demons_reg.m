% Created by: Bernal Jimenez
% 03/17/2016

function [affined_nmjs] = load_affined_nmjs(nNmjs,affinedFileNames)

	affined_nmjs = cell(nNmjs,1);
	for affined_nmjieNum = 1:nNmjs   
	    load(affinedFileNames(affined_nmjieNum).name,'affine','maxFrameNum')
	    affined_nmjs{affined_nmjieNum,1}=affine;
	    clear affine
	end   
end

function [demonized_mov, disp_fields] = apply_demon_transf(roiFiles,movieNum,affined_nmjs)

	load(roiFiles(movieNum).name)

	demonized_mov = cell(nNmjs,1);
	dispFields = cell(nNmjs,1);

	parfor nmjNum = 1:nNmjs   
	    	affined_nmj = affined_nmjs{nmjNum};
		disp(['Starting Demon NMJ #: ',num2str(nmjNum)])

		refFrameNorm = affined_nmj(:,:,maxFrameNum);
		refFrame = enhanceContrastForDemon(refFrameNorm);

		demonDispFields = cell(nFrames,1);
		demon=zeros(size(refFrame,1),size(refFrame,2),nFrames,'uint16');

		for qq = 1:nFrames
		    frameNorm = affined_nmj(:,:,qq);
		    movingFrame=enhanceContrastForDemon(frameNorm);
		    
		    [dField,~] = imregdemons(movingFrame,refFrame,[400 200 100],...
		    'PyramidLevels',3,'AccumulatedFieldSmoothing',1);

		    movingRegistered = imwarp(frameNorm,dField);  
		    
		    demonDispFields{qq,1}=dField;
		    demon(:,:,qq)=(movingRegistered);
		    disp(['NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   
	  
		end
		
		demonized_mov{nmjNum,1}=demon;
		dispFields{nmjNum,1}=demonDispFields;     
	end

end

function [] = save_demon_mov(demonized_mov,disp_fields,affinedFileNames,nNmjs)

	for demonMovieNum = 1:nNmjs   
	    demon=demonized_mov{demonMovieNum,1};
	    demonDispFields=disp_fields{demonMovieNum,1};
	    FileNameApp = affinedFileNames(demonMovieNum).name;
	    save(FileNameApp,'demonDispFields','demon','-append')
	    clear demon demonDispFields
	end        
end
