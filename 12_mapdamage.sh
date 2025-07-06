#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=mapdamage
#SBATCH --partition nocona
#SBATCH --nodes=1 --ntasks=4
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-208

# define main working directory
workdir=/lustre/scratch/jmanthey/09_mexico

basename_array=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/genotype_helper.txt | tail -n1 | cut -f 1 )
refgenome=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/genotype_helper.txt | tail -n1 | cut -f 2 )

source activate mapdamage

module load  gcc/10.1.0 gsl/2.7 r/4.3.0

# make mapdamage output directory
mkdir ${workdir}/01_bam_files/mapdamage_${basename_array}

# run mapdamage 
mapDamage -i ${workdir}/01_bam_files/${basename_array}_prefinal.bam -r ${refgenome} \
-d ${workdir}/01_bam_files/mapdamage_${basename_array} --merge-reference-sequences 

