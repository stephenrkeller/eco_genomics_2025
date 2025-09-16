#!/bin/bash

### Add your comments/annotations here

# Remove all software modules and load all and only those needed

module purge

module load gcc samtools


# Path to the population_genomics folder in your repo:

MYREPO="/users/s/r/srkeller/projects/eco_genomics_2025/population_genomics"


# Directory where the mapping alignment files live:

INPUT="/gpfs1/cl/ecogen/pbio6800/PopulationGenomics/bams"

# Your pop:

MYPOP="2030"


### Challenge ###

# For each section below, I've left blank (XXXX) a few of the places where variables names should go. 
# You'll need to replace with the correct variable at each step in your loops
# This will require you to think carefully about which vAriable name shouLd go in which placeholder!  
# Think: where do you want to use input paths vs. sample (pop) names? Where do you want to direct your results to?


### Make the header for your pop's stats file

echo -e "SampleID Num_reads Num_R1 Num_R2 Num_Paired Num_MateMapped Num_Singletons Num_MateMappedDiffChr Coverage_depth" \
  >${MYREPO}/myresults/${MYPOP}.stats.txt


### Calculate stats on bwa alignments

for FILE in ${INPUT}/${MYPOP}*.sorted.rmdup.bam  # loop through each of your pop's processed bam files in the input directory
do
	F=${FILE/.sorted.rmdup.bam/} # isolate the sample ID name by stripping off the file extension
	NAME=`basename ${F}`  # further isolate the sample ID name by stripping off the path location at the beginning
	echo ${NAME} >> ${MYREPO}/myresults/${MYPOP}.names  # print the sample ID names to a file
	samtools flagstat ${FILE} | awk 'NR>=9&&NR<=15 {print $1}' | column -x  # calculate the mapping stats
done >> ${MYREPO}/myresults/${MYPOP}.flagstats  # append the stats as a new line to an output file that increases with each iteration of the loop


### Calculate mean sequencing depth of coverage


for FILE2 in ${INPUT}/${MYPOP}*.sorted.rmdup.bam
do
	samtools depth ${FILE2} | awk '{sum+=$3} END {print sum/NR}'  # calculate the per-site read depth, sum across sites, and calc the mean by dividing by the total # sites
done >> ${MYREPO}/myresults/${MYPOP}.coverage # append the mean depth as a new line to an output file that increases with each iteration of the loop


### Put all the stats together into 1 file:

paste ${MYREPO}/myresults/${MYPOP}.names \
	${MYREPO}/myresults/${MYPOP}.flagstats \
	${MYREPO}/myresults/${MYPOP}.coverage \
	>>${MYREPO}/myresults/${MYPOP}.stats.txt # stitch ('paste') the files together column-wise
