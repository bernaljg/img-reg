%Created  by: Bernal Jimenez
%04/20/2014

function [] = join_mov(batchDir,nNmjs,movOutputDir,numOfNodes)
	
	
	completedBatches = 0;
	while completedBatches < numOfNodes

		completedBatches = 0;
		for batchNum =1:numOfNodes
			try
			load([batchDir,'/completed_batch',num2str(batchNum),'.mat'])
			completedBatches = completedBatches + 1
			catch
			end
		end
	end
	
	disp('Free from infinite loop')

	fullMovie = cell(nNmjs,1);
	fullDispField = cell(nNmjs,1);
	
	tic
	for nmjNum=1:nNmjs
		%Create empty array to perform movie concatenation
		fullNmjMov = [];
		fullNmjDispField = cell(0,1);
		
		for batch = 1:numOfNodes
			batchName = ['/Batch',num2str(batch),'.mat']
			load([batchDir,batchName]);
			demonized_mov = genvarname(['demonized_mov',num2str(batch)])
			fullNmjMov = cat(3,fullNmjMov,eval([demonized_mov '{nmjNum}']));
			fullNmjDispField = cat(1,fullNmjDispField,disp_fields{nmjNum});
			disp(['Batch',num2str(batch),' Complete'])
		end
		fullMovie{nmjNum} = fullNmjMov;
		fullDispField{nmjNum} = fullNmjDispField;
	end
	joinMoviesTime = toc
	save([movOutputDir, '/fullMovie.mat'],'fullMovie','fullDispField','joinMoviesTime','-v7.3')
