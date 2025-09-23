#!/bin/bash

### load modules

module purge
module load gcc angsd


### Set up directories and variables

REPO="/users/s/r/srkeller/projects/eco_genomics_2025/population_genomics"

mkdir ${REPO}/myresults/ANGSD

mkdir ${REPO}/myresults/ANGSD/diversity

INPUT="${REPO}/mydata/ANGSD"

OUT="${REPO}/myresults/ANGSD/diversity"

REF="/gpfs1/cl/ecogen/pbio6800/PopulationGenomics/ref_genome/Pmariana/Pmariana1.0-genome_reduced.fa"

MYPOP="2030"

SUFFIX="ALL"   # All sites (=ALL) or just polymorphic sites (=POLY)?

#Estimation of the SFS
realSFS ${INPUT}/${MYPOP}_${SUFFIX}.saf.idx \
        -maxIter 1000 \
        -tole 1e-6 \
        -P 1 \
        > ${OUT}/${MYPOP}_${SUFFIX}.sfs
        
        
# Estimate thetas using the SFS

realSFS saf2theta ${INPUT}/${MYPOP}_${SUFFIX}.saf.idx \
        -sfs ${OUT}/${MYPOP}_${SUFFIX}.sfs \
        -outname ${INPUT}/${MYPOP}_${SUFFIX}

# Note the strange use of ${INPUT} in the -outname -- this is b/c the file is too large to include in your `myresults/` folder (github won't like it) so we have to store it in `mydata/`

#### Calculate diversity stats along sliding windows 

# Set window size and step interval (in bp)
# Decide if you want windows overlapping (step<win) or non-overlapping (step=win):

WIN=50000
STEP=50000

thetaStat do_stat ${INPUT}/${MYPOP}_${SUFFIX}.thetas.idx \
-win $WIN \
-step $STEP \
-outnames ${OUT}/${MYPOP}_${SUFFIX}_win${WIN}_step${STEP}.thetasWindow.gz


### Cut out the relevant columns for downstream input to R:

cut -f2-5,9,14 ${OUT}/${MYPOP}_${SUFFIX}_win${WIN}_step${STEP}.thetasWindow.gz.pestPG > ${OUT}/${MYPOP}_${SUFFIX}_win${WIN}_step${STEP}.thetas


