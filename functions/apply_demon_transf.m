% Created by: Bernal Jimenez
% 03/17/2016

function [demonized_mov, disp_fields] = apply_demon_transf(roiFile,affined_nmjs)

    vars = load(roiFile)
    nNmjs = vars.nNmjs
    nFrames = vars.nFrames;
    maxFrameNum = vars.maxFrameNum;
    
	demonized_mov = cell(nNmjs,1);
	disp_fields = cell(nNmjs,1);

    for nmjNum = 1:nNmjs   
	    affined_nmj = affined_nmjs{nmjNum};
		disp(['Starting Demon NMJ #: ',num2str(nmjNum)])

		refFrameNorm = affined_nmj(:,:,maxFrameNum);
		refFrame = enhanceContrastDemon(refFrameNorm);

		demonDispFields = cell(nFrames,1);
		demon=zeros(size(refFrame,1),size(refFrame,2),nFrames,'uint16');

		for qq = 1:nFrames
		    frameNorm = affined_nmj(:,:,qq);
		    movingFrame=enhanceContrastDemon(frameNorm);
		    
		    [dField,movingRegistered] = imregdemons(movingFrame,refFrame,[400 200 100],...
		    'PyramidLevels',3,'AccumulatedFieldSmoothing',1);

		    movingRegistered = imwarp(frameNorm,dField);  
		    
		    demonDispFields{qq,1}=dField;
		    demon(:,:,qq)=(movingRegistered);
		    disp(['NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   
	  
		end
		
		demonized_mov{nmjNum,1}=demon;
		disp_fields{nmjNum,1}=demonDispFields;     
	end

