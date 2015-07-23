#!/bin/bash
 
################################################################################
# Creates directories and files for ins, output, and shell scripts for all 
# subtasks based on the designated number of nodes and number of CPUs on each node
# June 2015
# katie.renwick@msu.montana.edu
################################################################################

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
#SBATCH -n 1
#SBATCH -J Subset
#SBATCH -o split.out
#SBATCH -e split.err 
#SBATCH -p priority

###########################################
# Before continuing, make sure you have
# Compiled model
# cd model/LPJGUESS_netcdf_dev_June_2015/modules/lib
# make clean; make all
# cd ..
# make clean; make all

###########################################
# Subset gridlists, instructional files,
# and shell scripts by number of CPUs to use
# on each node

# USER MUST SET THESE VALUES!!!
# nprocs = number of processors to use on each node
# nnodes = number of nodes
nnodes=1
nprocs=32 #CHANGE TO 32 IF NOT TESTING
projectname="replacethis"
let nsplits=($nprocs * $nnodes)

# Set initial values
let index=1
let number=1

while (($index < $nnodes+1))
do
# Clean up & Create new folders
rm -rf Ins_files/$projectname/Subset_$index
mkdir  Ins_files/$projectname/Subset_$index

rm -rf Shell_scripts/$projectname/Subset_$index
mkdir Shell_scripts/$projectname/Subset_$index

rm -rf /mnt/lustrefs/work/katie.renwick/Output_$projectname/Subset_$index
mkdir /mnt/lustrefs/work/katie.renwick/Output_$projectname/Subset_$index

# Reset counter
counter=1

	while (($counter < $nprocs+1))
	do	
	# Clean up & Create new folders
	rm -rf -rf /mnt/lustrefs/work/katie.renwick/Output_$projectname/Subset_$index/output_$number
	mkdir /mnt/lustrefs/work/katie.renwick/Output_$projectname/Subset_$index/output_$number
	
	# Edit the ins file to read the correct gridlist
	cp Ins_files/$projectname/$projectname'_Master.ins' Ins_files/$projectname/Subset_$index/Wusa$number.ins
	sed -i '11d' Ins_files/$projectname/Subset_$index/Wusa$number.ins #Delete line
	sed -i '11i param "file_gridlist" (str "'$projectname'/'$number'_Wusa.txt")' Ins_files/$projectname/Subset_$index/Wusa$number.ins #Add new line
	
	# Edit the ins file to create a new output file
	sed -i '39d' Ins_files/$projectname/Subset_$index/Wusa$number.ins #Delete line
	sed -i '39i param "file_pft_annual" (str "Output_'$projectname'/Subset_'$index'/output_'$number'/pft_annual_subset_'$number'.nc")' Ins_files/$projectname/Subset_$index/Wusa$number.ins #Add new line

	sed -i '40d' Ins_files/$projectname/Subset_$index/Wusa$number.ins #Delete line
	sed -i '40i param "file_stand_annual" (str "Output_'$projectname'/Subset_'$index'/output_'$number'/stand_annual_subset_'$number'.nc")' Ins_files/$projectname/Subset_$index/Wusa$number.ins #Add new line

	sed -i '44d' Ins_files/$projectname/Subset_$index/Wusa$number.ins #Delete line
	sed -i '44i param "file_stand_monthly" (str "Output_'$projectname'/Subset_'$index'/output_'$number'/stand_monthly_subset_'$number'.nc")' Ins_files/$projectname/Subset_$index/Wusa$number.ins #Add new line

	# Edit the shell file to create new shell files
	cp Shell_scripts/$projectname/$projectname'_Master_Shell.sh' Shell_scripts/$projectname/Subset_$index/Wusa$number.sh
	sed -i '10d' Shell_scripts/$projectname/Subset_$index/Wusa$number.sh #Delete line
	sed -i '10i ./guess Ins/'$projectname'/Subset_'$index'/Wusa'$number'.ins' Shell_scripts/$projectname/Subset_$index/Wusa$number.sh #Add new line
	
	let number=$number+1
	let counter=$counter+1
	done

let index=$index+1
done

#################
# Subset slurm shell scripts

# Set initial values
let index=1
let start=1

while (($index < $nnodes+1))
do

# Create new slurm script for each node
cp Slurm_scripts/$projectname/$projectname'_Master_Slurm.sh' Slurm_scripts/$projectname/Wusa_$index.sh

sed -i '22d' Slurm_scripts/$projectname/Wusa_$index.sh
sed -i '22i #SBATCH -J '$projectname'_'$index'' Slurm_scripts/$projectname/Wusa_$index.sh

sed -i '26d'  Slurm_scripts/$projectname/Wusa_$index.sh
sed -i '26i #SBATCH	-o '$projectname'_'$index'_%j.out'  Slurm_scripts/$projectname/Wusa_$index.sh

sed -i '27d' Slurm_scripts/$projectname/Wusa_$index.sh
sed -i '27i #SBATCH	-e '$projectname'_'$index'_%j.err' Slurm_scripts/$projectname/Wusa_$index.sh

sed -i '73d' Slurm_scripts/$projectname/Wusa_$index.sh
sed -i '73i let number='$start'' Slurm_scripts/$projectname/Wusa_$index.sh

sed -i '78d' Slurm_scripts/$projectname/Wusa_$index.sh
sed -i '78i srun -n 1 /local/LPJGUESS_temp_KR/Shell/$projectname/Subset_'$index'/Wusa$number.sh &' Slurm_scripts/$projectname/Wusa_$index.sh 

sed -i '88d' Slurm_scripts/$projectname/Wusa_$index.sh
sed -i '88i rsync -a --progress /local/LPJGUESS_temp_KR/Output_'$projectname'/Subset_'$index' /mnt/lustrefs/work/katie.renwick/Output_'$projectname'/' Slurm_scripts/$projectname/Wusa_$index.sh 

let start=($index * $nprocs)+1
let index=index+1
done
