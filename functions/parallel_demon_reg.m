% Created by: Bernal Jimenez
% 03/17/2016

function [] = parallel_demon_reg(roiFile,batchFile)

    params = load(roiFile);
    nNmjs = params.nNmjs;
    nFrames = params.nFramesPerBatch;

    load(batchFile)

    demonized_mov = cell(nNmjs,1);
    disp_fields = cell(nNmjs,1);

    try
	gpuDevice
	gpuEnabled = true
    catch
	gpuEnabled = false
    end
    
    if gpuEnabled

	    for nmjNum = 1:nNmjs   
		nmj = batchNmjs{nmjNum};
		disp(['Starting Demon NMJ #: ',num2str(nmjNum)])

		refFrame = refFrames{nmjNum};
		refFrame = enhanceContrastDemon(refFrame);
		refFrameGPU = gpuArray(refFrame);

		demonDispFields = cell(nFrames,1);
		demon=zeros(size(refFrame,1),size(refFrame,2),nFrames,'uint16');
		demonGPU = gpuArray(demon);
		
		tic
		for qq = 1:nFrames
		    frameNorm = nmj(:,:,qq);
		    movingFrame=enhanceContrastDemon(frameNorm);

		    %Pass Arrays to GPU
		    movingFrameGPU = gpuArray(movingFrame);
		    
		    %Apply Demons Transformation
		    [dFieldGPU,movingRegGPU] = imregdemons(movingFrameGPU,refFrameGPU,[400,200,100],'PyramidLevels',3);
		    dFieldGPU = gather(dFieldGPU);
		    movingRegGPU = imwarp(frameNorm,dFieldGPU);
	    
		    demonDispFields{qq,1} = dFieldGPU; 
		    demonGPU(:,:,qq)=movingRegGPU;
		    disp(['NMJ #: ',num2str(nmjNum),' Frame #: ',num2str(qq)]);   
	  
		end
		demonTime = toc

		demonized_mov{nmjNum,1}=gather(demonGPU);
		disp_fields{nmjNum,1}=demonDispFields;
	        
		demon_variable = genvarname(['demonized_mov',num2str(batchNum)])
	        eval([demon_variable '= demonized_mov'])
		
		save(batchFile,['demonized_mov',num2str(batchNum)],'disp_fields','demonTime','-append')	
	   end

   else
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
   end

