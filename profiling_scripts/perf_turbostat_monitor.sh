#!/bin/bash

# Set environment variables
export PCM_NO_MSR=1
export PCM_KEEP_NMI_WATCHDOG=1
cd /home/ecurbtw/REHO/scripts/lausanne
export AMPL_PATH="/home/ecurbtw/urbantwin-ecocloud-profiling/reho/ampl/ampl.linux-intel64"
source /opt/intel/oneapi/setvars.sh
source ../../venv/bin/activate

# Define the path to PCM tools
pcm_path="/home/ecurbtw/tools/pcm/build/bin"

# Define benchmark name and directory for results
BENCHMARK="reho_catarina_5000buildings"
timestamps=$(date +"%Y-%m-%d_%H-%M-%S")
RESULTS_DIR="/home/ecurbtw/REHO/profiling_results/$BENCHMARK/$timestamps"

# Create the directory for storing results
mkdir -p $RESULTS_DIR

# Define the command to start your profiled application
application_command="/home/ecurbtw/REHO/venv/bin/python3 reho_catarina.py"

# Start the profiled application in the background
$application_command > $RESULTS_DIR/reho_log.txt &
app_pid=$!


sudo $pcm_path/pcm-memory > "$RESULTS_DIR/pcm_memory_output.txt" &
pcm_memory_pid=$!

# sudo $pcm_path/pcm-latency > "$RESULTS_DIR/pcm_latency_output.txt" &
# pcm_latency_pid=$!

# Start PCM monitoring tools
sudo $pcm_path/pcm-power> "$RESULTS_DIR/pcm_power_output.txt" &
pcm_power_pid=$!

# # Monitor the PCM output and consolidate data
# echo "Time | CPU Power (W) | DRAM Power (W) | System Power (W)" > "$RESULTS_DIR/consolidated_pcm_power_stats.txt"
# (
#     while kill -0 $app_pid 2> /dev/null; do
#         # Read the latest power data from pcm-power.x output
#         read -r power_data < "$RESULTS_DIR/pcm_power_output.txt"
#         # Extract and format the necessary power values (assuming positions; adjust as needed)
#         cpu_power=$(echo $power_data | awk '{print $2}') # Example position
#         dram_power=$(echo $power_data | awk '{print $3}') # Example position
#         system_power=$(echo $power_data | awk '{print $4}') # Example position
#         echo "$(date +%H:%M:%S) | $cpu_power | $dram_power | $system_power" >> "$RESULTS_DIR/consolidated_pcm_power_stats.txt"
#         sleep 1 # Adjust sampling rate as needed
#     done
# ) &

# Start turbostat in the background and pipe output to a temp file
turbostat -c package --quiet --show Busy%,Avg_MHz,PkgTmp,PkgWatt,DRAMWatt --interval 5 > "$RESULTS_DIR/temp_turbostat.txt" &
turbostat_pid=$!

# Start perf in the background to collect CPU performance data
perf record -g --pid $app_pid -o "$RESULTS_DIR/perf_output.data" &
perf_pid=$!

# # Prepare the output file
# echo "Date Time | CPU Busy% | Avg MHz | Package Temp | Package Watt | DRAM Watt | Mem Total | Mem Used | Mem Free" > "$RESULTS_DIR/consolidated_output.txt"

# # Monitor memory and CPU in real-time
# (
#     while kill -0 $app_pid 2> /dev/null; do
#         # Get the latest turbostat data
#         cpu_data=$(tail -n 1 "$RESULTS_DIR/temp_turbostat.txt")
        
#         # Get current memory usage
#         mem_usage=$(free -m | awk 'NR==2{printf "%s %s %s", $2, $3, $4}')
        
#         # Log with timestamp
#         echo "$(date +%Y-%m-%d_%H-%M-%S) $cpu_data $mem_usage"
#         sleep 5
#     done
# ) >> "$RESULTS_DIR/consolidated_output.txt" &

# Wait for the profiled application to finish
wait $app_pid

# After the application finishes, kill the PCM process
kill $pcm_power_pid

# Kill both monitoring processes
kill $turbostat_pid
kill $perf_pid

# Generate a perf report (optional)
perf report -i "$RESULTS_DIR/perf_output.data" > "$RESULTS_DIR/perf_report.txt"

# Clean up temp files
rm "$RESULTS_DIR/temp_turbostat.txt"

echo "Monitoring complete. Profiled application, turbostat, and perf have exited. Results are saved in $RESULTS_DIR"