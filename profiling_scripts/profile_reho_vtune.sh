#!/bin/bash

BENCHMARK="64CoresVtuneSimpleCase_5000_building_scale"
PROGRAM="/home/ecurbtw/REHO/venv/bin/python3 profiling_reho_SimpleCase.py"

timestamps=$(date +"%Y-%m-%d_%H-%M-%S")
RESULTS_DIR=/data/ecurbtw/reho/profiling_results/$BENCHMARK/$timestamps

# Set the output files for vtune
VTUNE_RESULT_DIR=$RESULTS_DIR/vtune_report

mkdir -p $RESULTS_DIR
mkdir -p $VTUNE_RESULT_DIR


# Set environment variables
cd /home/ecurbtw/REHO/scripts/lausanne
source /home/ecurbtw/REHO/venv/bin/activate
export AMPL_PATH="/home/ecurbtw/urbantwin-ecocloud-profiling/reho/ampl/ampl.linux-intel64"
source /opt/intel/oneapi/setvars.sh


# Set the CPU cores to be used for profiling
cores="0-63"

# Set the CPU frequency to 2.5 GHz for all cores
cpupower frequency-set -u 2.1GHz -d 2.1GHz
#   cpupower frequency-set -u 4GHz -d 4GHz

# for i in {1..10}; do
#     sudo cpufreq-set -c $i -f 2.0GHz
# done


# Enable idle states for power saving
#  cpupower idle-set -E


# Run VTune
# vtune -collect hotspots -knob sampling-mode=hw -knob enable-characterization-insights=true -result-dir $VTUNE_RESULT_DIR -- $PROGRAM > "$RESULTS_DIR/log_experiment_vtune.txt"
# taskset -c 1-10 vtune -collect hotspots -knob sampling-mode=hw -knob enable-characterization-insights=true -knob enable-stack-collection=true -result-dir $VTUNE_RESULT_DIR -- $PROGRAM > "$RESULTS_DIR/log_experiment_vtune.txt"
taskset -c 0-63 vtune -collect hotspots -knob sampling-mode=hw -data-limit 0 -knob enable-characterization-insights=true -knob enable-stack-collection=true -knob stack-size=0 -result-dir $VTUNE_RESULT_DIR -- $PROGRAM > "$RESULTS_DIR/log_experiment_vtune.txt"


# vtune -collect hpc-performance -knob collect-memory-bandwidth=true 


# Notify user
echo "Profiling complete. VTune results saved to $VTUNE_RESULT_DIR."

cpupower frequency-set -d 1GHz -u 3.GHz

chown ecurbtw $RESULTS_DIR -R
