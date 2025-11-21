#!/bin/bash

# Create log directory (in the directory where you launch the script)
mkdir -p logs # in latency test, only client output is relevant and has to be stored

# Define parameters
THREADS=2
ROWS=(99 999 9999) # the arguments for numRows, always 1 less than wanted.
#Rows tested in Express for latency: 100, 1000, 10'000, 100'000, 500'000, 1'000'000
#Datasize tested in Express: 1'000, 4'000, 16'000, 32'000, 64'000 (so until 64KB)
DATASIZE=4000
KB=$((DATASIZE / 1000)) # in KB

CODE_DIR="/users/stud/f/fehr0006/Express" # where the Express code is
BASE_DIR="$(pwd)" # path to the directory from which the script runs

for ROW in "${ROWS[@]}"; do
    echo "Running with rowDataSize = $ROW"

    # Start serverB in its own directory, output from server B is not needed
    (
        cd "$CODE_DIR/serverB" || exit
        ./serverB $THREADS 0 $ROW $DATASIZE > /dev/null 2>&1 & # Executing command from the Express repository
    )

    sleep 2 # Wait a bit so serverB starts up before serverA

    # Start serverA in its own directory, output also not needed
    (
        cd "$CODE_DIR/serverA" || exit
        ./serverA localhost:4442 $THREADS 0 $ROW $DATASIZE > /dev/null 2>&1 &
    )

    sleep 2 # Wait again to ensure servers are ready

    # Run client in its own directory, output printed into log files
    (
        cd "$CODE_DIR/client" || exit
        ./client localhost:4443 localhost:4442 $THREADS $DATASIZE > "$BASE_DIR/logs/client_${ROW}_${KB}KB.log" 2>&1
    )

    # Stop background processes after each run
    pkill serverA
    pkill serverB
    sleep 2
done

echo "Finished"
