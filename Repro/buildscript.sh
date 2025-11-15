#!/bin/bash
#SBATCH --job-name=build
#SBATCH --partition=xeon     # The main partition of miniHPC
#SBATCH --hint=nomultithread # Disable hardware multithreading
#SBATCH --exclusive          # Exclusive access to resources
#SBATCH --time=00:10:00      # Requested execution time
#SBATCH --nodes=1            # Requested number of nodes

export PATH=$HOME/go/bin:$PATH
cd ~/Express

cd ./serverA && GOFLAGS=-mod=vendor go build
cd ../serverB && GOFLAGS=-mod=vendor go build
cd ../client && GOFLAGS=-mod=vendor go build
