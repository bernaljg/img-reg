%Created by: Bernal Jimenez
%4/14/2016


function [] = make_run_demons_bash(batchDir,roiFile,numOfNodes)

	vars = load(roiFile);
	nNmjs = vars.nNmjs;
	nFrames = vars.nFrames;
	maxFrameNum = vars.maxFrameNum;

	cd batchDir
	batchFiles = dir(batchDir,'*.mat')

	for nodeNum=1:numOfNodes
		
		batchFile = batchFiles(nodeNum).name

		fid = fopen(['batchscript.sh'], 'w+');
		
		fprintf(fid,['#!/bin/bash\n']);
		fprintf(fid,['# Job name:\n']);
		fprintf(fid,['#SBATCH --job-name=Demons_Reg',num2str(nodeNum),'\n']);
		fprintf(fid,['#\n']);
		fprintf(fid,['# Partition:\n']);
		fprintf(fid,['#SBATCH --partition=cortex\n']);
		fprintf(fid,['#\n']);
		fprintf(fid,['# Constrain Nodes:\n']);
		fprintf(fid,['#SBATCH --constraint=cortex_nogpu\n']);
		fprintf(fid,['#\n']);
		fprintf(fid,['# Processors:\n']);
		fprintf(fid,['#SBATCH --ntasks=1\n']);
		
		%fprintf(fid,['#\n']);
		%fprintf(fid,['# Exclude the Following Nodes:\n']);
		%fprintf(fid,['#SBATCH -x n0000.cortex0,n0001.cortex0,n0012.cortex0,n0013.cortex0,n0007.cortex0,n0008.cortex0,n0009.cortex0,n0010.cortex0,n0011.cortex0\n']); % ,n0001.cortex0,n0012.cortex0,n0013.cortex0,
		
		fprintf(fid,['#\n']);
		fprintf(fid,['# Memory:\n']);
		fprintf(fid,['#SBATCH --mem-per-cpu=7500M\n']);
		fprintf(fid,['#\n']);
		fprintf(fid,['# Wall clock limit:\n']);
		fprintf(fid,['#SBATCH --time=2:0:00\n']);
		fprintf(fid,['#\n']);
		fprintf(fid,['#\n']);
		fprintf(fid,['#SBATCH -o ', batchDir,num2str(nodeNum),'.out\n']);
		fprintf(fid,['#\n']);
		fprintf(fid,['#SBATCH -e ', batchDir,num2str(nodeNum),'.err\n']);
		fprintf(fid,['\n']);
		%
		fprintf(fid,['\n']);
		fprintf(fid,['module load matlab/R2016a\n']);
		fprintf(fid,['\n']);
		fprintf(fid,['matlab -nosplash -nodesktop -noFigureWindows << EOF\n']);   % was matlab -nodisplay but that stopped working on cluster.
		fprintf(fid,['\n']);
		fprintf(fid,['echo Made it past\n']);
		fprintf(fid,['\n']);
		fprintf(fid,['cd', batchDir]);
		fprintf(fid,['\n']);
		fprintf(fid,['parallel_demons_reg(',roiFile,batchfile,');\n']);
		fprintf(fid,['\n']);
		fprintf(fid,['exit\n']);
		fprintf(fid,['EOF\n']);
		fclose(fid);
		
		!cd batchDir
		!sbatch batchscript.sh
	end


