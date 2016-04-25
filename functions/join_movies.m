%Created  by: Bernal Jimenez
%04/20/2014

function [] = join_mov(batchDir,roiFile,movOutputDir,numOfNodes)
	load(roiFile)

	while completedBatches < numOfNodes
		load(roiFile)
		completedBatches = 0;
		for batchNum =1:numOfNodes
			if exist(['batch',num2str(batchNum),'Complete'])
				if eval(['batch',num2str(batchNum),'Complete'])
					completedBatches = completedBatches + 1
				end
			end
		end
		pause(60)
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
			load([batchDir,'/Batch',num2str(batch),'.mat']);
			fullNmjMov = cat(3,fullNmjMov,demonized_mov{nmjNum});
			fullNmjDispField = cat(1,fullNmjDispField,disp_fields{nmjNum});
			disp(['Batch',num2str(batch),' Complete'])
		end
		fullMovie{nmjNum} = fullNmjMov;
		fullDispField{nmjNum} = fullNmjDispField;
	end
	joinMoviesTime = toc
	save([movOutputDir, '/fullMovie.mat'],'fullMovie','fullDispField','joinMoviesTime','-v7.3')
