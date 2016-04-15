% Created by: Bernal Jimenez
% 03/17/2016

function [disp_fields, demonized_mov] = cluster_demons_reg(roiFile,nmjs)

    vars = load(roiFile);
    nNmjs = vars.nNmjs;
    nFrames = vars.nFrames;
    maxFrameNum = vars.maxFrameNum;

    demonized_mov = cell(nNmjs,1);
    disp_fields = cell(nNmjs,1);

    for nmjNum = 1:nNmjs   
	nmj = nmjs{nmjNum};
	disp(['Starting Demon NMJ #: ',num2str(nmjNum)])

	refFrameNorm = nmj(:,:,maxFrameNum);
	refFrame = enhanceContrastDemon(refFrameNorm);

	demonDispFields = cell(nFrames,1);
	demon=zeros(size(refFrame,1),size(refFrame,2),nFrames,'uint16');

	for qq = 1:nFrames
	    frameNorm = nmj(:,:,qq);
	    movingFrame=enhanceContrastDemon(frameNorm);
	    
	    %Apply Demons Transformation
	    [dField,~] = imregdemons(movingFrame,refFrame,[400,200,100],'PyramidLevels',3);
	    movingReg = imwarp(frameNorm,dField);
    
	    demonDispFields{qq,1} = dField; 
	    demon(:,:,qq)=(movingReg);
	    disp(['NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   
  
	end
		
	disp_fields{nmjNum,1}=demonDispFields;     
   end

