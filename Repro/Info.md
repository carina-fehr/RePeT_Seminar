# Important notes

github repo link: https://github.com/SabaEskandarian/Express
code commit hash: 3c06848bef4bfcde2fd56cb82b484bcfe5526641

Evaluations done on my Mac with: Processor: 1.6 GHz Dual-Core Intel Core i5
Graphics: Intel UHD Graphics 617 1536 MB


# Information about files
The following files were used for the reproduction and evaluation:
- buildscript.sh
- launchLatency.sh
- launchTP.sh
- parseLogs.py

## buildscript.sh
This file is used on the HPC cluster. The precompiled files do not work there, because they use versions that are to new for the cluster.
But there is no internet on the cluster, so we have to preinstall everything needed and then compile everything on the cluster.

## launchLatency.sh
This script is used to automatize the commands proposed on the github. It writes the output into log files, named client_nrRows_xKB.log. It is possible to run it with multiple row arguments.

## launchTP.sh
This script is essentially doing the same thing as launchLatency, but it measures throughput, so in one command 'throughput' is added to the arguments. 

## parseLogs.py
This python code simplifies the evaluation. Instead of writing all the log outputs manually into one excel file, this creates an excel file. It can be run with 'python3 parseLogs.py' 


# Problems
1. First tried on mac. But this was not possible due to a openssl version problem. The old version needed in the code is not possible anymore to download on mac. 
``` ==> Fetching downloads for: openssl@1.1
Error: openssl@1.1 has been disabled because it is not supported upstream! It was disabled on 2024-10-24. ```
2. 
