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
#SBATCH --mem-per-cpu=600
#
# Constraint:
#SBATCH --constraint=cortex_nogpu

module load matlab/R2016a
matlab -nosplash -nodisplay -r postSelectMovReg; exit;
