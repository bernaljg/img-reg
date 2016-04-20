function batchDir = save_batches(roiFile, nmjMovie,movOutputDir, numOfNodes, nNmjs)
	
	load(roiFile)
	assert(mod(nFrames,numOfNodes)==0,'Number of Nodes is not a factor of the number of frames. Parallelization might not be optimal.')

	batchDir= fullfile(movOutputDir,'batches')
	mkdir(batchDir)

	nFramesPerBatch = nFrames/numOfNodes;
	save(roiFile,'nFramesPerBatch','-append')

	for nodeNum = 1:numOfNodes
		
		batchNmjs = cell(nNmjs,1);
		refFrames = cell(nNmjs,1);

		for nmjNum = 1:nNmjs
			nmj = nmjMovie{nmjNum};
			batchNmjs{nmjNum} = nmj(:,:,(nodeNum-1)*nFramesPerBatch+1:nodeNum*nFramesPerBatch);
			refFrames{nmjNum} = nmj(:,:,maxFrameNum);

		save([batchDir '/Batch' num2str(nodeNum)],'batchNmjs','refFrames')

		end
	end
