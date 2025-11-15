#!/bin/bash
#SBATCH --job-name=test    # The name of the job
#SBATCH --partition=xeon     # The main partition of miniHPC
#SBATCH --hint=nomultithread # Disable hardware multithreading
#SBATCH --exclusive          # Exclusive access to resources
#SBATCH --time=00:15:00      # Requested execution time
#SBATCH --nodes=1            # Requested number of nodes
#SBATCH --ntasks-per-node=1  # Requested processes per node
#SBATCH --cpus-per-task=16    # Requested threads per process
#SBATCH --mem-per-cpu=2G 
#SBATCH --output=myoutput.log
module load OpenSSL/3 
# Tell Slurm to execute something (e.g. your code)
srun launchLatency.sh
