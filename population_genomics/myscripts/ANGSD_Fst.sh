#!/bin/bash

#---------  Slurm preamble, defines the job with #SBATCH statements

# Give your job a name that's meaningful to you, but keep it short
#SBATCH --job-name=Fst_2030_WISC

# Name the output file: Re-direct the log file to your home directory
# The first part of the name (%x) will be whatever you name your job 
#SBATCH --output=/users/s/r/srkeller/projects/eco_genomics_2025/population_genomics/mylogs/%x_%j.out

# Which partition to use: options include short (<3 hrs), general (<48 hrs), or week
#SBATCH --partition=general

# Specify when Slurm should send you e-mail.  You may choose from
# BEGIN, END, FAIL to receive mail, or NONE to skip mail entirely.
#SBATCH --mail-type=ALL
#SBATCH --mail-user=srkeller@uvm.edu

# Run on a single node with four cpus/cores and 8 GB memory
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=64G

# Time limit is expressed as days-hrs:min:sec; this is for 24 hours.
#SBATCH --time=24:00:00

#---------  End Slurm preamble, job commands now follow


# Below here, give you bash script with your list of commands


# load your modules

module purge

module load gcc angsd

# This script wioll use ANGSD to estimate Fst between my red spruce pop
# and black spruce from outside the range

# Path to the `population_genomics` folder in your repo

REPO="/users/s/r/srkeller/projects/eco_genomics_2025/population_genomics"

# Path to the Black Spruce (BS) input saf.idx data (I made this file for you using the ANGSD.sh script)

BLKSPR="/gpfs1/cl/ecogen/pbio6800/PopulationGenomics/ANGSD/black_spruce"

# Make directory in `myresults/ANGSD` to store your results

mkdir ${REPO}/myresults/ANGSD/Fst

MYBSPOP="WISC"

MYRSPOP="2030"

SUFFIX="ALL"

### Estimate Fst between my red spruce pop and black spruce:

# Step 1: estimate the 2D site frequency spectrum for BS and your RS pop
realSFS \
${REPO}/mydata/ANGSD/${MYRSPOP}_${SUFFIX}.saf.idx \
${BLKSPR}/${MYBSPOP}_${SUFFIX}.saf.idx \
>${REPO}/myresults/ANGSD/Fst/${MYRSPOP}_${MYBSPOP}_2D.sfs \
-P 10

# Step 2: Calculate Fst for all SNPs and store it in a binary format (.fst.idx)
realSFS fst index \
${REPO}/mydata/ANGSD/${MYRSPOP}_${SUFFIX}.saf.idx \
${BLKSPR}/${MYBSPOP}_${SUFFIX}.saf.idx \
-sfs ${REPO}/myresults/ANGSD/Fst/${MYRSPOP}_${MYBSPOP}_2D.sfs \
-fstout ${REPO}/mydata/ANGSD/${MYRSPOP}_${MYBSPOP} \
-whichFst 1 \
-P 10

# Step 3: Caclulate the average Fst across all sites (we use the weighted average)
realSFS fst stats \
${REPO}/mydata/ANGSD/${MYRSPOP}_${MYBSPOP}.fst.idx \
>${REPO}/myresults/ANGSD/Fst/${MYRSPOP}_${MYBSPOP}_Fst.txt \
-P 10

# Step 4 (optional): Calculate the averate Fst in sliding windows
realSFS fst stats2 \
${REPO}/mydata/ANGSD/${MYRSPOP}_${MYBSPOP}.fst.idx \
-win 50000 \
-step 50000 \
>${REPO}/myresults/ANGSD/Fst/${MYRSPOP}_${MYBSPOP}_Fst_50kbWindows.txt \
-P 10




