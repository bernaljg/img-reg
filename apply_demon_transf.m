% Created by: Bernal Jimenez
% 03/17/2016

function [demonized_mov_gpu, disp_fields_gpu, time_to_gpu] = apply_demon_transf(roiFiles,movieNum,affined_nmjs)

    vars = load(roiFiles(movieNum).name)
    nNmjs = vars.nNmjs
    nFrames = vars.nFrames;
    maxFrameNum = vars.maxFrameNum;
    
	demonized_mov_gpu = cell(nNmjs,1);
	disp_fields_gpu = cell(nNmjs,1);

    for nmjNum = 1:nNmjs   
	    affined_nmj = affined_nmjs{nmjNum};
		disp(['Starting Demon NMJ #: ',num2str(nmjNum)])

		refFrameNorm = affined_nmj(:,:,maxFrameNum);
		refFrame = enhanceContrast(refFrameNorm);

		demonDispFields = cell(nFrames,1);
		demon=zeros(size(refFrame,1),size(refFrame,2),nFrames,'uint16');
		demonDispFieldsGPU = gpuArray(demonDispFields);
		demonGPU = gpuArray(demon);

		for qq = 1:nFrames
		    frameNorm = affined_nmj(:,:,qq);
		    movingFrame=enhanceContrast(frameNorm);
		    
		    %Pass Arrays to GPU
		    tic
		    movingFrameGPU = gpuArray(movingFrame);
		    refFrameGPU = gpuArray(refFrame);
		    time_to_gpu = toc
		    
		    %Apply Demons Transformation
		    [dFieldGPU,movingRegGPU] = imregdemons(movingFrameGPU,refFrameGPU,[400 200 100],...
		    'PyramidLevels',3,'AccumulatedFieldSmoothing',1);

		    demonDispFieldsGPU{qq,1}=dFieldGPU;
		    demonGPU(:,:,qq)=(movingRegGPU);
		    disp(['NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   
	  
		end
		
		demonized_mov_gpu{nmjNum,1}=demon;
		disp_fields_gpu{nmjNum,1}=demonDispFields;     
	end

