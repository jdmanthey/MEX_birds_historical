#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=qual
#SBATCH --partition nocona
#SBATCH --nodes=1 --ntasks=12
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-78

# define main working directory
workdir=/lustre/scratch/jmanthey/09_mexico

basename_array=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/basenames_historical.txt | tail -n1 )

# run bbduk to quality trim
/lustre/work/jmanthey/bbmap/bbduk.sh in1=${workdir}/01_working_h/${basename_array}_unmerged_R1.fastq.gz \
in2=${workdir}/01_working_h/${basename_array}_unmerged_R2.fastq.gz \
out1=${workdir}/01_working_h/${basename_array}_unmerged_cleaned_R1.fastq.gz \
out2=${workdir}/01_working_h/${basename_array}_unmerged_cleaned_R2.fastq.gz \
minlen=20 qtrim=rl trimq=6 ktrim=r k=25 mink=7 \
ref=/lustre/work/jmanthey/bbmap/resources/adapters.fa hdist=1 tbo tpe

/lustre/work/jmanthey/bbmap/bbduk.sh in=${workdir}/01_working_h/${basename_array}_merged.fastq.gz \
out=${workdir}/01_working_h/${basename_array}_merged_cleaned.fastq.gz \
minlen=20 qtrim=rl trimq=6 ktrim=r k=25 mink=7 \
ref=/lustre/work/jmanthey/bbmap/resources/adapters.fa hdist=1 tbo tpe

# low complexity removal
/home/jmanthey/nf-polish/bin/remove_low_complex.py \
-1 ${workdir}/01_working_h/${basename_array}_unmerged_cleaned_R1.fastq.gz \
-2 ${workdir}/01_working_h/${basename_array}_unmerged_cleaned_R2.fastq.gz \
-u ${workdir}/01_working_h/${basename_array}_merged_cleaned.fastq.gz \
-c 0.5 \
-p ${workdir}/01_cleaned_h/${basename_array}

# gzip 
gzip ${workdir}/01_cleaned_h/${basename_array}_R1.fastq
gzip ${workdir}/01_cleaned_h/${basename_array}_R2.fastq
gzip ${workdir}/01_cleaned_h/${basename_array}_U.fastq
rm ${workdir}/01_cleaned_h/${basename_array}_low_complex.fastq
