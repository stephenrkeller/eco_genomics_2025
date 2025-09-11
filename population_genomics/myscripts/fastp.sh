#!/bin/bash   

# You can add notes/annotations/comments with a "#" at the start of a line

# Go ahead and add some notes to yourself here about this analysis

# Next, let's load our required modules:

module purge
module load gcc fastp

# Define the path to the population_genomics folder in your Github repo.

MYREPO=/users/s/r/srkeller/projects/eco_genomics_2025/population_genomics

# make a new directory within myresults/ to hold the fastp QC reports

mkdir ${MYREPO}/myresults/fastp_reports

# cd to the location (path) where data for the Population Genomics module live:

cd /gpfs1/cl/ecogen/pbio6800/PopulationGenomics/fastq/red_spruce

# Define the population code to anlayze
# Be sure to replace with your 4-digit pop code

MYPOP="2030" 

# for each file that has "MYPOP" and "R1" (read 1) in the name 
# start a loop with this file as the input:

for READ1 in ${MYPOP}*R1.fastq.gz
do

# the partner to this file (read 2) can be found by replacing the R1.fastq.gz with R2.fastq.gz
# second part of the input for PE reads

READ2=${READ1/R1.fastq.gz/R2.fastq.gz}

# make the output file names: print the fastq name, replace _R# with _R#_clean

NAME1=$(echo $READ1 | sed "s/_R1/_R1_clean/g")
NAME2=$(echo $READ2 | sed "s/_R2/_R2_clean/g")

# print the input and output to screen 

echo $READ1 $READ2
echo $NAME1 $NAME2

# call fastp
fastp -i ${READ1} -I ${READ2} -o ../../cleanreads/${NAME1} -O ../../cleanreads/${NAME2} \
--detect_adapter_for_pe \
--trim_front1 12 \
--thread 4 \
--cut_right \
--cut_window_size 6 \
--qualified_quality_phred 20 \
--length_required 35 \
--html ${MYREPO}/myresults/fastp_reports/${NAME1}.html \
--json ${MYREPO}/myresults/fastp_reports/${NAME1}.json 

done

