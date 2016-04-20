% Created by: Bernal Jimenez
% 03/17/2016

function [] = parallel_demon_reg(roiFile,batchFile)

    params = load(roiFile);
    nNmjs = params.nNmjs;
    nFrames = params.nFramesPerBatch;

    load(batchFile)

    demonized_mov = cell(nNmjs,1);
    disp_fields = cell(nNmjs,1);

    for nmjNum = 1:nNmjs   
	nmj = batchNmjs{nmjNum};
	disp(['Starting Demon NMJ #: ',num2str(nmjNum)])
	
	refFrame = refFrames{nmjNum};
	refFrame = enhanceContrastDemon(refFrame);

	demonDispFields = cell(nFrames,1);
	demon=zeros(size(refFrame,1),size(refFrame,2),nFrames,'uint16');
	
	tic
	for qq = 1:nFrames
	    frameNorm = nmj(:,:,qq);
	    movingFrame=enhanceContrastDemon(frameNorm);
	    
	    %Apply Demons Transformation
	    [dField,~] = imregdemons(movingFrame,refFrame,[400,200,100],'PyramidLevels',3,'DisplayWaitbar',false);
	    movingReg = imwarp(frameNorm,dField);
    
	    demonDispFields{qq,1} = dField; 
	    demon(:,:,qq)=movingReg;
	    disp(['NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   
 	    demonframetime = toc 
	end
	demonTime = toc
	
	demonized_mov{nmjNum,1} = demon
	disp_fields{nmjNum,1} = demonDispFields;     

    save(batchFile,'demonized_mov','disp_fields','demonTime','-append')
    end

