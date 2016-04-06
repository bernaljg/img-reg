% Created by: Bernal Jimenez
% 03/17/2016

function [disp_fields_gpu, demonized_mov_gpu] = apply_demon_transf(roiFiles,movieNum,nmjs)

    vars = load(roiFiles(movieNum).name);
    nNmjs = vars.nNmjs;
    nFrames = vars.nFrames;
    maxFrameNum = vars.maxFrameNum;

    demonized_mov_gpu = cell(nNmjs,1);
    disp_fields_gpu = cell(nNmjs,1);

    for nmjNum = 1:nNmjs   
	    nmj = nmjs{nmjNum};
		disp(['Starting Demon NMJ #: ',num2str(nmjNum)])

		refFrameNorm = nmj(:,:,maxFrameNum);
		refFrame = enhanceContrast(refFrameNorm);
		refFrameGPU = gpuArray(refFrame);

		demonDispFields = cell(nFrames,1);
		demon=zeros(size(refFrame,1),size(refFrame,2),nFrames,'uint16');
		demonGPU = gpuArray(demon);

		for qq = 1:nFrames
		    frameNorm = nmj(:,:,qq);
		    movingFrame=enhanceContrast(frameNorm);
		    %frameNorm = gpuArray(frameNorm);

		    %Pass Arrays to GPU
		    movingFrameGPU = gpuArray(movingFrame);
		    
		    %Apply Demons Transformation
		    [dFieldGPU,movingRegGPU] = imregdemons(movingFrameGPU,refFrameGPU,[200,200,1,1,1],'PyramidLevels',5);
      		dFieldGPU = gather(dFieldGPU);
		    movingRegGPU = imwarp(frameNorm,dFieldGPU);
            
            demonDispFields{qq,1} = dFieldGPU; 
		    demonGPU(:,:,qq)=(movingRegGPU);
		    disp(['NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   
	  
		end
		
		demonized_mov_gpu{nmjNum,1}=gather(demonGPU);
		disp_fields_gpu{nmjNum,1}=demonDispFields;     
   end

