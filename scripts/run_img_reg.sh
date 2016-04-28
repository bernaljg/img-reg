#!/bin/bash -l
# Job name
#SBATCH -J Img_Reg
#
# Partition:
#SBATCH -p cortex
#
# Wall clock limit:
#SBATCH --time=2:00:00
#
# Memory:
#SBATCH --mem-per-cpu=5000
#
# Constraint:
#SBATCH --constraint=cortex_nogpu

module load matlab/R2016a
matlab -nosplash -nodisplay -r "skipTrack=true;skipAffine=true;[moviesToRegisterDir,outputDir] = choose_dirs();[fileNames,roiFullFiles,cziFullFiles,nMovies] = load_mov_names(moviesToRegisterDir);if exist('skipAffine');skipAffine = skipAffine;else;skipAffine = false;end;for movieNum=1:nMovies;fileName = fileNames{movieNum};roiFile = roiFullFiles{movieNum};cziFile = cziFullFiles{movieNum};postSelectMovReg(moviesToRegisterDir,outputDir,fileName,roiFile,cziFile,skipTrack,skipAffine);end;exit;"
