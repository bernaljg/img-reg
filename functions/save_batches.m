function batchDir = save_batches(nmjMovie,movOutputDir, numOfNodes, nNmjs, nFramesPerBatch, maxFrameNum)
	
	batchDir= fullfile(movOutputDir,'batches')
	mkdir(batchDir)

	for nodeNum = 1:numOfNodes
		batchNum = nodeNum

		batchNmjs = cell(nNmjs,1);
		refFrames = cell(nNmjs,1);

		for nmjNum = 1:nNmjs
			nmj = nmjMovie{nmjNum};
			batchNmjs{nmjNum} = nmj(:,:,(nodeNum-1)*nFramesPerBatch+1:nodeNum*nFramesPerBatch);
			refFrames{nmjNum} = nmj(:,:,maxFrameNum);

		save([batchDir '/Batch' num2str(nodeNum)],'batchNmjs','refFrames','batchNum')

		end
	end
