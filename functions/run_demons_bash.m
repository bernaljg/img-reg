%Created by: Bernal Jimenez
%4/14/2016


function [] = run_demons_bash(batchDir,nNmjs,nFrames,numOfNodes)
	
	cd(batchDir)
	for nodeNum=1:numOfNodes
		
		batchFile = ['Batch',num2str(nodeNum),'.mat']

		fid = fopen(['batchscript.sh'], 'w+');
		
		fprintf(fid,['#!/bin/bash\n']);
		fprintf(fid,['# Job name:\n']);
		fprintf(fid,['#SBATCH -J Demons',num2str(nodeNum),'\n']);
		fprintf(fid,['#\n']);
		fprintf(fid,['# Partition:\n']);
		fprintf(fid,['#SBATCH -p cortex\n']);
		fprintf(fid,['#\n']);
		fprintf(fid,['# Constrain Nodes:\n']);
		fprintf(fid,['#SBATCH --constraint=cortex_k40\n']);
		fprintf(fid,['#\n']);
		fprintf(fid,['# Processors:\n']);
		fprintf(fid,['#SBATCH -n 1\n']);
		
		fprintf(fid,['#\n']);
		fprintf(fid,['# Exclude the Following Nodes:\n']);
		fprintf(fid,['#SBATCH -x n0012.cortex0\n']);
		%fprintf(fid,['#SBATCH -x n0002.cortex0,n0003.cortex0,n0004.cortex0,n0005.cortex0,n0006.cortex0,n0007.cortex0,n0008.cortex0,n0009.cortex0,n0010.cortex0,n0011.cortex0\n']);
		fprintf(fid,['#\n']);
		fprintf(fid,['# Memory:\n']);
		fprintf(fid,['#SBATCH --mem-per-cpu=2000\n']);
		fprintf(fid,['#\n']);
		fprintf(fid,['# Wall clock limit:\n']);
		fprintf(fid,['#SBATCH --time=00:30:00\n']);
		fprintf(fid,['#\n']);
		fprintf(fid,['#\n']);
		fprintf(fid,['#SBATCH -o output',num2str(nodeNum),'.out\n']);
		fprintf(fid,['#\n']);

		fprintf(fid,['module load matlab/R2016a\n']);
		fprintf(fid,['\n']);
		fprintf(fid,['matlab -nosplash -nodesktop -noFigureWindows << EOF\n']);   % was matlab -nodisplay but that stopped working on cluster.
		fprintf(fid,['\n']);
		fprintf(fid,['cd(', mat2str(batchDir), ');\n']);
		fprintf(fid,['parallel_demon_reg_test(',num2str(nNmjs),',',num2str(nFrames),',',mat2str(batchFile),');\n']);
		fprintf(fid,['batch', num2str(nodeNum),'Complete=true\n']);
		fprintf(fid,['save(''completed_batch',num2str(nodeNum),'.mat'',''batch',num2str(nodeNum),'Complete'');\n']);
		fprintf(fid,['exit\n']);
		fprintf(fid,['EOF\n']);
		fclose(fid);

		!sbatch batchscript.sh
	end


