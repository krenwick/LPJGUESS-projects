#!/bin/bash
 
############################################################################
# Slurm Script to copy input and output directories/files onto compute node 
#/local folder and to submit LPJ-GUESS simulations on the Hyalite cluster
# June 2015
# Modified from KE by KR
############################################################################

# Running a job managed by Slurm
# -N number of nodes
# -n number of tasks, requests number of processor cores on cluster
# -c this many CPUs per task
# --ntasks-per-node= requests processor cores on a node
# --time= time limit to batch job
# --mail-type=END send user email at end of job
# -o create an out file of log
# -e create an error file

#SBATCH -N 1
#SBATCH -n 3
#SBATCH -J Wusa
#SBATCH --mail-user katie.renwick@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --mail-type=END
#SBATCH	-o Wusa_%j.out
#SBATCH	-e Wusa_%j.err
#SBATCH --exclusive
#SBATCH -p priority

# USER MUST SET THESE VALUES:
# nprocs = number of processors to use on each node
nprocs=32 # change to 32 when not testing
projectname="replacethis"
###############
# Copy files to /local on compute node

# Create temporary directory
rm -rf /local/LPJGUESS_temp_KR
mkdir /local/LPJGUESS_temp_KR
mkdir /local/LPJGUESS_temp_KR/Ins
mkdir /local/LPJGUESS_temp_KR/Shell

# Copy Climate_LPJGUESS data 
rsync -avP /mnt/lustrefs/store/katie.renwick/Climate_LPJGUESS/CRU /local/LPJGUESS_temp_KR
rsync -avP /mnt/lustrefs/store/katie.renwick/Climate_LPJGUESS/CRU_spinup /local/LPJGUESS_temp_KR

# Copy CO2 data 
rsync -avP /mnt/lustrefs/store/katie.renwick/Climate_LPJGUESS/CO2 /local/LPJGUESS_temp_KR

# Copy Soil_LPJGUESS data 
rsync -avP /mnt/lustrefs/store/katie.renwick/Soil_LPJGUESS/CRUsize_code4 /local/LPJGUESS_temp_KR

# Copy gridlists 
rsync -avP /mnt/lustrefs/store/katie.renwick/Gridlists/gridfolder /local/LPJGUESS_temp_KR

# Copy LPJGUESS executable
rsync -avP /home/katie.renwick/scripts/LPJGUESS/model/modules/guess /local/LPJGUESS_temp_KR

# Copy instruction files
rsync -avP /home/katie.renwick/scripts/Ins_files/$projectname /local/LPJGUESS_temp_KR/Ins

# Copy output directories
rsync -avP '/mnt/lustrefs/work/katie.renwick/Output_'$projectname /local/LPJGUESS_temp_KR

# Copy shell scripts to run subtasks
rsync -avP /home/katie.renwick/scripts/Shell_scripts/$projectname /local/LPJGUESS_temp_KR/Shell

###############
# Run loop

counter=1
let number=65
while (($counter < $nprocs+1))
do

# Submit the job to each node and each proccessor core
srun -n 1 /local/LPJGUESS_temp_KR/Shell/Subset_'$index'/Wusa$number.sh &

let number=$number+1
let counter=$counter+1
done

wait

###############
# Copy output data back to home directory
rsync -avP /local/LPJGUESS_temp_KR/data/local_output/$projectname /mnt/lustrefs/work/katie.renwick/Output_'$projectname'

###############
# Clean up
rm -rf /local/LPJGUESS_temp_KR