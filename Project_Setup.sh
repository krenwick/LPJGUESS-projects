#!/bin/bash

################################################################################
# Creates new directories on hyalite for a new project
# copies master scripts and modifies file paths
# July 2015
# katie.renwick#gmail.com modified by kristen.emmett#gmail.com
################################################################################

#SBATCH -N 1
#SBATCH -n 1
#SBATCH -J Setup
#SBATCH -o Setup.out
#SBATCH -e Setup.err 
#SBATCH -p express

# CHANGE THESE VALUES
username="katie.renwick"
jobname="Wusa2_CRU4"
nprocs=32
nnodes=4

# These stay the same
subset="_Subset"
slurm="_Master_Slurm"
shell="_Master_Shell"
ins="_Master"

# Create new directories for this project
mkdir /home/$username/scripts/Slurm_scripts/$jobname
mkdir /home/$username/scripts/Shell_scripts/$jobname
mkdir /home/$username/scripts/Ins_files/$jobname
mkdir /mnt/lustrefs/work/$username/Output_$jobname
mkdir /mnt/lustrefs/store/$username/Gridlists/$jobname

# copy master subset script into appropriate folder
cp -p Master_Subset.sh $jobname$subset.sh
# copy master slurm script into appropriate folder
cp -p Master_Slurm.sh Slurm_scripts/$jobname/$jobname$slurm.sh
# copy master shell script into appropriate folder
cp -p Master_Shell.sh Shell_scripts/$jobname/$jobname$shell.sh
# copy ins file into appropriate folder
cp -p Master.ins Ins_files/$jobname/$jobname$ins.ins

# change project name in new subset script
sed -i s/"replacethis"/"$jobname"/g $jobname$subset.sh

# change project name in new slurm script
sed -i s/"replacethis"/"$jobname"/g Slurm_scripts/$jobname/$jobname$slurm.sh


# change nprocs and nnodes in subset_jobs script
sed -i s/"nnodes=1"/"nnodes=$nnodes"/g Slurm_scripts/$jobname/$jobname$slurm.sh $jobname$subset.sh


# 1. EDIT MASTER INS FILE in newly-created folder
# 2. RECORD PROJECT META IN SPREADSHEET
# 3. Run newly-created subset_jobs script
# 4. CD into Slurm_scripts/jobname
# 5. submit jobs using sbatch

