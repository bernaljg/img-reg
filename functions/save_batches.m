function [batchDir] = save_batches(roiFiles, nmjMovie,movOutputDir, numOfNodes, nNmjs)

	assert(mod(nFrames,numOfNodes)=0,'Number of Nodes is not a factor of the number of frames. Parallelization might not be optimal.')
	
	nFrames = nFrames/NumOfNodes;

	save(roiFiles,'nFrames','-append')
	
	batchDir= fullfile(MovOutputDir,'batches')
	mkdir(batchDir)

	for nodeNum = 1:numOfNodes
		
		batch_nmjs = cell(nNmjs,1)
		ref_frames = cell(nNmjs,1)

		for nmjNum = nNmjs
			nmj = nmjs{nmjNum}
			maxNum = maxFrameNum(nmjNum)
			batch_nmjs{nmjNum} = nmj(:,:,(nodeNum-1)*nFrames+1:nodeNum*nFrames)
			ref_frames{nmjNum} = nmj(:,:,maxNum)

		save([batchDir '/Batch' num2str(nodeNum)],'batchNmjs','refFrames')
