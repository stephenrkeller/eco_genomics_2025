# Population Genomics Notebook

## Fall 2025 Ecological Genomics

## Author: Stephen Keller

This will keep my notes on population genomics coding sessions

### 09/11/25: Cleaning fastq reads of red spruce

-   We wrote a bash script called "fastp.sh" located within my Github repo:

`~/projects/eco_genomics_2025/population_genomics/myscripts`

-   We used this to trim the adapters out of our red spruce fastq sequence files.

-   The raw fastq files were located on the class share space:

`/gpfs1/cl/ecogen/pbio6800/PopulationGenomics/fastq/red_spruce`

-   Using the program fastp, we processed the raw reads and output the cleaned reads to the following directory on the class shared space:

`/gpfs1/cl/ecogen/pbio6800/PopulationGenomics/cleanreads`

-   Fastp produced html-formatted reports for each sample, which I saved into the directory:

`~/projects/eco_genomics_2025/population_genomics/myresults/fastp_reports`

-   The results showed high quality sequence, with most Q-scores being \>\>20, and low amount of adapted contamination, which we trimmed out. We also trimmed out the leading 12 bp to get rid of the barcoded indices.

-   Cleaned reads are now ready to proceed to the next step in our pipeline: mapping to the reference genome!

### 09/16/25: Mapping our cleaned reads to the reference genome

-   We mapped our clean reads to the black spruce reference genome using bwa-mem2.

    -   The script we wrote for this job is `mapping.sh` and is located in the `population_genomics/myscripts/` directory in my class repo.

    -   The ref genome is here:

        -   `/gpfs1/cl/ecogen/pbio6800/ref_genomes/Pmariana/`

-   After mapping, we processed the sequence alignment (.sam) files by converting to binary format (.bam), sorting, removing PCR duplicates, and indexing with the program `sambamba.`

    -   The script we wrote for this job is `process_bam.sh` and is located in the `population_genomics/myscripts/` directory in my class repo.

-   Lastly, we wrote a script to summarize the mapping success and depth of coverage `bam_stats.sh` saved to `myscripts/`

-   Because the mapping step was taking awhile on the cluster, we wrote a simple wrapper script `process_stats_wrapper.sh` and included the SBATCH header to submit the processing and stats scripts as a batch.

    -   the outputs are saved in `population_genomics/myresults/`

### 09/18/25: Review bamstats and set up nucleotide diversity estimation using ANGSD

-   Wrote a short script called bamstats_review.r located in `msycripts` to evaluate the mapping success

    -   saw roughly 66% of reads mapped in proper pairs

    -   obtained depth of coverage between 2-3X –\> suggests we need to use a probabilistic framework for analyzing the genotype data.

-   We wrote scripts to use ANGSD to call genotype likelihoods and calculate diversity stats

    -   `myresults/ANGSD.sh` to estimate the GLs

    -   `myresults/ANGSD_doTheta.sh` to estimate the nucleotide diversities

-   We then wrote a wrapper script to submit to SLURM `diversity_wrapper.sh`

### 09/19/25: Fix error in last line of `ANGSD_doTheta.sh`

-   The following line had an error in the path naming derived from variables:

    -   Original version:

        -   `cut -f2-5,9,14 ${OUT}/${MYPOP}_${SUFFIX}.thetasWindow.gz.pestPG > ${OUT}/${MYPOP}_${SUFFIX}_win${WIN}_step${STEP}.thetas`

    -   Should be:

        `cut -f2-5,9,14 ${OUT}/${MYPOP}_${SUFFIX}_win${WIN}_step${STEP}.thetasWindow.gz.pestPG > ${OUT}/${MYPOP}_${SUFFIX}_win${WIN}_step${STEP}.thetas`

-   Note: will require re-defining the following variables (assuming don't want to re-run ANGSD): `OUT, MYPOP, SUFFIX, WIN, STEP`

### 09/23/25: Visualize results nucleotide diversity in RMarkdown

-   We created an RMarkdown doc to store our processed theta results from ANGSD
-   plotted nSites, theta-W and pi, and Tajima's D
-   Added class results to google doc
    -   results suggest a latitudinal trend in diversity (higher in north) and inverse for TajD (more bottlenecked in south)
