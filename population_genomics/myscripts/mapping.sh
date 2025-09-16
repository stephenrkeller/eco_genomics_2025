#!/bin/bash


#---------  Slurm preamble, defines the job with #SBATCH statements

# Give your job a name that's meaningful to you, but keep it short
#SBATCH --job-name=mapping

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




### Add your comments/annotations here


# Remove all software modules and load all and only those needed

module purge

module load bwa-mem2/2.2.1


# Indexing the genome 
# Note: This only needs to be done once, and I have already done it for you.  
# In the future, you'll need this step if working on a new project/genome

# bwa-mem2 index reference.fasta

# Define the path to and name of the indexed reference genome

REF="/gpfs1/cl/ecogen/pbio6800/PopulationGenomics/ref_genome/Pmariana/Pmariana1.0-genome_reduced.fa"

# Define a variable called MYPOP that will loop through all the samples for you pop

MYPOP="2030"

# Define the input directory with your *cleaned* fastq files

INPUT="/gpfs1/cl/ecogen/pbio6800/PopulationGenomics/cleanreads"


# Define your output directory where the mapping files will be saved

OUT="/gpfs1/cl/ecogen/pbio6800/PopulationGenomics/bams"

# cd into the directory where the cleaned and trimmed reads live:

cd $INPUT

# Align individual sequences per population to the reference

for READ1 in ${MYPOP}*R1_clean.fastq.gz
do
	READ2=${READ1/R1_clean.fastq.gz/R2_clean.fastq.gz}
	IND=${READ1/_R1_clean.fastq.gz/}
	NAME=`basename ${IND}`
	echo "@ Aligning $NAME..."
	bwa-mem2 mem \
	-t 10 \
	-o ${OUT}/${NAME}.sam \
	${REF} \
	${READ1} \
	${READ2}
done



