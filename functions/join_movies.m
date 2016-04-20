%Created  by: Bernal Jimenez
%04/20/2014

function [] = join_mov(batchDir,roiFile,movOutputDir,numOfNodes)
	load(roiFile)

	while completedBatches < numOfNodes
		load(roiFile)
		pause(10)
	end
	
	disp('Free from infinite loop')

	fullMovie = cell(nNmjs,1);
	fullDispField = cell(nNmjs,1);

	for nmjNum=1:nNmjs
		%Create empty array to perform movie concatenation
		fullNmjMov = [];
		fullNmjDispField = cell(0,1);

		for batch = 1:numOfNodes
			load([batchDir,'/Batch',num2str(batch),'.mat']);
			fullNmjMov = cat(3,fullNmjMov,demonized_mov{nmjNum});
			fullNmjDispField = cat(1,fullNmjDispField,disp_fields{nmjNum});
			disp(['Batch',batch,' Complete'])
		end
		fullMovie{nmjNum} = fullNmjMov;
		fullDispField{nmjNum} = fullNmjDispField;
	end

	save([movOutputDir, '/fullMovie.mat'],'fullMovie','fullDispField','-v7.3')
