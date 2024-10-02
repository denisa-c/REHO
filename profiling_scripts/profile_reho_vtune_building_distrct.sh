#!/bin/bash

BENCHMARK="8CoresVtuneSimpleCase_5000_district_scale"
PROGRAM="/home/ecurbtw/REHO/venv/bin/python3 profiling_reho_SimpleCaseDistrictScale.py"

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
cores="0-7"

# Set the CPU frequency to 2.5 GHz for all cores
cpupower frequency-set -u 2.1GHz -d 2.1GHz


# Run VTune
taskset -c 0-7 vtune -collect hotspots -knob sampling-mode=hw -data-limit 0 -knob enable-characterization-insights=true -knob enable-stack-collection=true -knob stack-size=0 -result-dir $VTUNE_RESULT_DIR -- $PROGRAM > "$RESULTS_DIR/log_experiment_vtune.txt" ; \


# Notify user
echo "Profiling complete District Scal. VTune results saved to $VTUNE_RESULT_DIR."


BENCHMARK="8CoresVtuneSimpleCase_5000_building_scale"
PROGRAM="/home/ecurbtw/REHO/venv/bin/python3 profiling_reho_SimpleCaseBuildingScale.py"

timestamps=$(date +"%Y-%m-%d_%H-%M-%S")
RESULTS_DIR=/data/ecurbtw/reho/profiling_results/$BENCHMARK/$timestamps

# Set the output files for vtune
VTUNE_RESULT_DIR=$RESULTS_DIR/vtune_report

mkdir -p $RESULTS_DIR
mkdir -p $VTUNE_RESULT_DIR

# Run VTune
taskset -c 10-17 vtune -collect hotspots -knob sampling-mode=hw -data-limit 0 -knob enable-characterization-insights=true -knob enable-stack-collection=true -knob stack-size=0 -result-dir $VTUNE_RESULT_DIR -- $PROGRAM > "$RESULTS_DIR/log_experiment_vtune_2.txt"

# Notify user
echo "Profiling complete District Scal. VTune results saved to $VTUNE_RESULT_DIR."


cpupower frequency-set -d 1GHz -u 3.GHz

chown ecurbtw $RESULTS_DIR -R
