#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=count_sites
#SBATCH --partition nocona
#SBATCH --nodes=1 --ntasks=4
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --array=1-12

workdir=/lustre/scratch/jmanthey/09_mexico

dir_array=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/40_data_char/dir_helper.txt | tail -n1 )

cd ${workdir}/${dir_array} 


for i in $( ls *vcf.gz ); do
	
	echo "number sites" >> ../filtering_stats_${dir_array}.txt

	gzip -cd $i | grep -v "^#" | cut -f5 |  wc -l >> ../filtering_stats_${dir_array}.txt
	
	echo "number snps" >> ../filtering_stats_${dir_array}.txt
	
	gzip -cd $i | grep -v "^#" | cut -f5 | grep -v "\\." | wc -l >> ../filtering_stats_${dir_array}.txt
	
done
