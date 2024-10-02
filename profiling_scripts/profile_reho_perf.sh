#!/bin/bash

BENCHMARK="PerfSimpleCase_5000_building_scale"
PROGRAM="/home/ecurbtw/REHO/venv/bin/python3 profiling_reho_SimpleCase.py"

timestamps=$(date +"%Y-%m-%d_%H-%M")
RESULTS_DIR=/data/ecurbtw/reho/profiling_results/$BENCHMARK/$timestamps

# Set the output files for perf
PERF_RESULT_DIR=$RESULTS_DIR/perf_report

mkdir -p $RESULTS_DIR
mkdir -p $PERF_RESULT_DIR

# Set environment variables
cd /home/ecurbtw/REHO/scripts/lausanne
source /home/ecurbtw/REHO/venv/bin/activate
export AMPL_PATH="/home/ecurbtw/urbantwin-ecocloud-profiling/reho/ampl/ampl.linux-intel64"
# source /opt/intel/oneapi/setvars.sh


# Set the CPU cores to be used for profiling
cores="0-31,64-95"

# Set the CPU frequency to 2.5 GHz for all cores
sudo cpupower frequency-set -u 2.1GHz -d 2.1GHz

# Enable idle states for power saving
sudo cpupower idle-set -E

# Define log files for each measurement
CYCLES_LOG="$RESULTS_DIR/cycles_stats.txt"
TIME_LOG="$RESULTS_DIR/time_stats.txt"
MEMORY_LOG="$RESULTS_DIR/memory_stats.txt"
ENERGY_LOG="$RESULTS_DIR/energy_stats.txt"
PROGRAM_LOG="$RESULTS_DIR/program_output.txt"

# Run the program in the background
$PROGRAM > "$PROGRAM_LOG" 2>&1 &
PROGRAM_PID=$!

# Run perf to collect different metrics concurrently
# Collect CPU cycles for all cores and other metrics
sudo perf stat -I 1000 -e cycles -a --pid $PROGRAM_PID 2>&1 | while read -r line; do
    if [[ $line =~ ([0-9,]+)\ cycles ]]; then
        current_time=$(date +"%Y-%m-%d %H:%M:%S")
        cycles="${BASH_REMATCH[1]}"
        cycles=$(echo "$cycles" | sed 's/,//g')
        cycle_array=($cycles)

        # Initialize row data with timestamp
        row="$current_time"

        # Append each core's cycle count to the row
        for core in {0..31} {64..95}; do
            row+=","${cycle_array[$core]:-0}
        done

        echo "$row" >> "$CYCLES_CSV"
    fi
done &

 perf stat -C 0-127 -e cycles --pid $PROGRAM_PID -I 1000 > "$CYCLES_LOG" 2>&1 &
 perf stat -C 0-127 -e task-clock --pid $PROGRAM_PID -I 1000 > "$TIME_LOG" 2>&1 &
 perf stat -C 0-127 -e cache-misses --pid $PROGRAM_PID -I 1000 > "$MEMORY_LOG" 2>&1 &
 perf stat -C 0-127 -e power/energy-pkg/,power/energy-psys/,power/energy-ram/ --pid $PROGRAM_PID -I 1000 > "$ENERGY_LOG" 2>&1 &

# # Run perf to collect different metrics concurrently
#  perf stat -C 0-127 -e cycles -- echo "hello" -I 1000 > "$CYCLES_LOG" 2>&1 &
#  perf stat -C 0-127 -e task-clock -- echo "hello" -I 1000 > "$TIME_LOG" 2>&1 &
#  perf stat -C 0-127 -e cache-misses -- echo "hello" -I 1000 > "$MEMORY_LOG" 2>&1 &
#  perf stat -C 0-127 -e power/energy-pkg/,power/energy-psys/,power/energy-ram/ -- echo "hello" -I 1000 > "$ENERGY_LOG" 2>&1 &

# perf stat -C 0-127 -e power/energy-pkg/ -- echo "hello"


# Wait for the program to finish
wait $PROGRAM_PID

# Restore CPU frequency settings
sudo cpupower frequency-set -d 1GHz -u 3.0GHz

# Notify user
echo "Profiling complete. Results saved to $RESULTS_DIR."

# Change ownership of the results directory
chown ecurbtw $RESULTS_DIR -R

