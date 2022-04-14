#!/bin/bash
#SBATCH --account=def-pawilson
#SBATCH --mail-type=ALL
#SBATCH --mail-user=bcrosby@trentu.ca
#SBATCH -c 4
#SBATCH --mem=32G
#SBATCH --time=0-1:0:0
#SBATCH -o megasat_1.2.log
#SBATCH -e megasat_1.2.err


module load perl


rm -r ./merged_$1/
mkdir ./merged_$1/

rm -r ./megasat_$1/
mkdir ./megasat_$1/


echo "#############################################################"
echo "# Running MEGASAT_Genotype.pl on run: $1 "
echo "#############################################################"

echo "#############################################################" >> megasat_1.2.err
echo "# Running MEGASAT_Genotype.pl on run: $1 " >> megasat_1.2.err
echo "#############################################################" >> megasat_1.2.err


ls /home/bcrosby/projects/def-pawilson/MiSeq_microsatellite/caribou/$1/fastq/*R1*.gz > fastq_list_R1.txt

sed -r "s:_S[0-9]+_L001_R1_001.fastq.gz::" fastq_list_R1.txt | \
        sed -r "s:/home/bcrosby/projects/def-pawilson/MiSeq_microsatellite/caribou/$1/fastq/::" | \
        > sample_list.txt


while IFS= read -r SAMPLE; do

        ((i=i%4)); ((i++==0)) && wait

        echo "# Merging sample ${SAMPLE} #" &
        echo "# Merging sample ${SAMPLE} #" >> megasat_1.2.err &

	/home/bcrosby/projects/def-pawilson/software/usearch11.0.667_i86linux32 \
		-fastq_mergepairs ./trim/${SAMPLE}_R1_trim.fastq -fastqout ./merged_$1/${SAMPLE}_merged.fastq &

done < sample_list.txt


perl /home/bcrosby/projects/def-pawilson/software/MEGASAT-master/'MEGASAT_1.0 for Linux'/MEGASAT_Genotype.pl \
	./primerfile_1.2.txt \
	4 \
	50 \
	4 \
	./merged_$1/ \
	./megasat_$1/
