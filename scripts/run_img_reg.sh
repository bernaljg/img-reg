#!/bin/bash
# Job name
#SBATCH --job-name=Img_Reg
#
# Partition:
#SBATCH --partition=cortex
#
# Wall clock limit:
#SBATCH --time=5:00:00
#
# Memory:
#SBATCH --mem-per-cpu=15G
#
# Constraint:
#SBATCH --constraint=cortex_nogpu
#
# Output:
#SBATCH --output=/clusterfs/cortex/users/bernaljg/LOGS/%j.out
module load matlab/R2016a
matlab -nodisplay
postSelectMovReg;
exit;
