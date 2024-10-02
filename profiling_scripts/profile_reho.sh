#!/bin/bash

# Set results directory
# BENCHMARK="reho_small"
# PROGRAM="/home/ecurbtw/REHO/venv/bin/python3 profiling_reho_smallest.py"

BENCHMARK="reho_big_5000buildings"
PROGRAM="/home/ecurbtw/REHO/venv/bin/python3 profiling_reho_biggest.py"

timestamps=$(date +"%Y-%m-%d_%H-%M-%S")
RESULTS_DIR=/home/ecurbtw/REHO/profiling_results/$BENCHMARK/$timestamps

# Set the output files for turbostat and vtune
TURBOSTAT_OUTPUT=$RESULTS_DIR/tubostat_power_consumption_idle_enabled.txt
VTUNE_RESULT_DIR=$RESULTS_DIR/vtune_report

mkdir -p $RESULTS_DIR
mkdir -p $VTUNE_RESULT_DIR


# Set environment variables
cd /home/ecurbtw/REHO/scripts/lausanne
export AMPL_PATH="/home/ecurbtw/urbantwin-ecocloud-profiling/reho/ampl/ampl.linux-intel64"
source /opt/intel/oneapi/setvars.sh
source ../../venv/bin/activate


# Set the duration of profiling in seconds
time=2

# Set the CPU cores to be used for profiling
cores="0-31,64-95"

# Set the CPU frequency to 2.5 GHz for all cores
sudo cpupower frequency-set -u 2GHz -d 2GHz

# Enable idle states for power saving
sudo cpupower idle-set -E



# Run turbostat with timestamps in the background
turbostat -c package --quiet --show Busy%,Avg_MHz,PkgTmp,PkgWatt  --interval 2 | tee $TURBOSTAT_OUTPUT &
TURBOSTAT_PID=$!


# Output headers
# echo "Date Time | CPU Busy% | Avg MHz | Package Temp | Package Watt | DRAM Watt | Mem Total | Mem Used | Mem Free"

# # Start turbostat and read its output
# turbostat -c package --quiet --show Busy%,Avg_MHz,PkgTmp,PkgWatt,DRAMWatt --interval 5 | while IFS= read -r line; do
#     # Get memory data
#     mem_usage=$(free -m | awk 'NR==2{printf "%s %s %s", $2, $3, $4}')
    
#     # Print both CPU and memory info with timestamp
#     echo "$(date +%Y-%m-%d_%H-%M-%S) $line $mem_usage"
# done

# Run VTune
vtune -collect hotspots -knob sampling-mode=hw -knob sampling-interval=0.5 -result-dir $VTUNE_RESULT_DIR -- $PROGRAM
# vtune -collect hotspots -knob sampling-mode=hw -knob sampling-interval=0.5 python3 profiling_reho_smallest.py 
# Stop turbostat after VTune finishes
sudo kill $TURBOSTAT_PID

# Notify user
echo "Profiling complete. Turbostat data saved to $TURBOSTAT_OUTPUT. VTune results saved to $VTUNE_RESULT_DIR.

su ecurbtw -c "echo 'Profiling complete. Turbostat data saved to $TURBOSTAT_OUTPUT. VTune results saved to $VTUNE_RESULT_DIR.' | mail -s 'REHO profiling complete'
chown ecurbtw $RESULTS_DIR -R
