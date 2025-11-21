#!/bin/bash

# Create log directory (in the directory where you launch the script)
mkdir -p logs # in throughput test, only serverA output is relevant and has to be stored

THREADS=8
ROWS=(49999)
# Rows tested in Express for throughput 1KB: 1'000, 10'000, 25'000, 50'000, 75'000, 100'000, 200'000, 300'000, 400'000, 500'000
# Rows for 32KB: 1'000, 5'000, 10'000, 25'000, 50'000
DATASIZE=32000 # Throughput only 1 and 32KB
KB=$((DATASIZE / 1000)) # in KB

CODE_DIR="/users/stud/f/fehr0006/Express" # where the Express code is
BASE_DIR="$(pwd)" # path to the directory from which the script runs

TARGET_WRITES=500 # After how many writes we end measurements

for ROW in "${ROWS[@]}"; do

    # Start serverB in its own directory, output from server B is not needed
    cd "$CODE_DIR/serverB" || exit
    ./serverB $THREADS 0 $ROW $DATASIZE > /dev/null 2>&1 &
    SERVERB_PID=$!
    cd "$BASE_DIR" || exit

    sleep 2

    # Start serverA in its own directory, output printed into log files
    SERVERA_LOG="$BASE_DIR/logs/TP_${ROW}_${KB}KB.log"
    cd "$CODE_DIR/serverA" || exit
    ./serverA localhost:4442 $THREADS 0 $ROW $DATASIZE > "$SERVERA_LOG" 2>&1 &
    SERVERA_PID=$!
    cd "$BASE_DIR" || exit

    sleep 2

    # Start client in throughput mode
    cd "$CODE_DIR/client" || exit
    ./client localhost:4443 localhost:4442 $THREADS $DATASIZE throughput &
    CLIENT_PID=$!
    cd "$BASE_DIR" || exit

    # Monitor serverA log
    echo "Waiting until serverA reaches $TARGET_WRITES writes"
    while true; do
        if [[ -f "$SERVERA_LOG" ]]; then
            LAST_LINE=$(tail -n 1 "$SERVERA_LOG")
            WRITES=$(echo "$LAST_LINE" | awk -F"number of writes: " '{print $2}')
            if [[ -n "$WRITES" ]] && (( WRITES >= TARGET_WRITES )); then
                echo "Target reached: $WRITES writes"
                break
            fi
        fi
        sleep 2
    done

    # Kill processes
    pkill -f client
    pkill -f serverA
    kill $SERVERA_PID $SERVERB_PID $CLIENT_PID 2>/dev/null
    wait $SERVERA_PID $SERVERB_PID $CLIENT_PID 2>/dev/null
    sleep 2
done

echo "Finished"

