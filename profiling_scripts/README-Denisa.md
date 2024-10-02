# TODO:

 
 - prepare scripts to automate process - done
 - document 
 - discuss with Ali on the analysis to be done and KPIs


 - [Catarina, Denisa, Ali ... by 16th of July] make sure we have the setup
    - current state: python verisn is not the same in vtune and reho-env
    - try to reinforce REHO env python version inside Vtune --> didn't work
    - reinstall REHO without a virtual env & test Vtune --> worked!!
    Final solution for hotspots: 

    screen reho200
    
    ```
    sudo su
    screen -S reho
    cd /home/ecurbtw/REHO
    ./profile_reho.sh
    CRTL+a; d
    screen -r reho
    ``
      ```sh
      cd /home/ecurbtw/REHO/scripts/lausanne
      export AMPL_PATH="/home/ecurbtw/urbantwin-ecocloud-profiling/reho/ampl/ampl.linux-intel64"
      source /opt/intel/oneapi/setvars.sh
      source ../../venv/bin/activate
      vtune -collect hotspots -knob sampling-mode=hw -knob sampling-interval=0.5 python3 profiling_reho_SimpleCase.py 
      ```


 - [All] evaluate deployent of some research questions that make sense with REHO (before next leader's meeting 21st august)
     -[Catarina, Pal, Denisa - week of 5th] identify some research questions
    - [Catarina, Denisa - week of 12th] Discuss with Georgios, Francois, David - propose concrete research questions
    - [Denisa, Ali, Miguel] eval HW req for their deployment
    - measure deployment KPIs 
    - HW deployment KPIs to be refined with Ali


# Log profiling results

## summary report 1000 buildings
![alt text](image-1.png)

## summary report for 10 buildings
Elapsed Time: 59.688s
    CPU Time: 55.889s
        Effective Time: 54.699s
        Spin Time: 1.190s
        Overhead Time: 0s
    Instructions Retired: 2,308,137,300,000
    Microarchitecture Usage: 100.0% of Pipeline Slots
        CPI Rate: 0.071
    Total Thread Count: 7,923
    Paused Time: 0s

Top Hotspots
Function                        Module                         CPU Time  % of CPU Time(%)
------------------------------  -----------------------------  --------  ----------------
func@0x95f7b0                   highs                            9.300s             16.6%
blas_thread_server              libscipy_openblas-c128ec02.so    7.342s             13.1%
ipx::NormalMatrix::_Apply       highs                            2.782s              5.0%
ipx::ConjugateResiduals::Solve  highs                            1.672s              3.0%
ipx::TriangularSolve            highs                            1.275s              2.3%
[Others]                        N/A                             33.518s             60.0%
Effective Physical Core Utilization: 4.9% (3.118 out of 64)
 | The metric value is low, which may signal a poor physical CPU cores
 | utilization caused by:
 |     - load imbalance
 |     - threading runtime overhead
 |     - contended synchronization
 |     - thread/process underutilization
 |     - incorrect affinity that utilizes logical cores instead of physical
 |       cores
 | Explore sub-metrics to estimate the efficiency of MPI and OpenMP parallelism
 | or run the Locks and Waits analysis to identify parallel bottlenecks for
 | other parallel runtimes.
 |
    Effective Logical Core Utilization: 0.7% (0.916 out of 128)
     | The metric value is low, which may signal a poor logical CPU cores
     | utilization. Consider improving physical core utilization as the first
     | step and then look at opportunities to utilize logical cores, which in
     | some cases can improve processor throughput and overall performance of
     | multi-threaded applications.
     |
Collection and Platform Info
    Application Command Line: /home/ecurbtw/REHO/venv/bin/python3 "profiling_reho_biggest.py"
    Operating System: 6.2.0-37-generic DISTRIB_ID=Ubuntu DISTRIB_RELEASE=22.04 DISTRIB_CODENAME=jammy DISTRIB_DESCRIPTION="Ubuntu 22.04.3 LTS"
    Computer Name: ecocloud-exp04
    Result Size: 697.1 MB
    Collection start time: 11:34:24 17/07/2024 UTC
    Collection stop time: 11:35:23 17/07/2024 UTC
    Collector Type: Driverless Perf system-wide sampling
    CPU
        Name: Intel(R) Xeon(R) Processor code named Sapphirerapids
        Frequency: 2.100 GHz
        Logical CPU Count: 128
        LLC size: 62.9 MB
        Cache Allocation Technology
            Level 2 capability: available
            Level 3 capability: available

If you want to skip descriptions of detected performance issues in the report,
enter: vtune -report summary -report-knob show-issues=false -r <my_result_dir>.
Alternatively, you may view the report in the csv format: vtune -report
<report_name> -format=csv.

## summary report for 5000 buildings
Top Hotspots
Function  Module  CPU Time  % of CPU Time(%)
--------  ------  --------  ----------------
Effective Physical Core Utilization: 0.0% (0.000 out of 64)
 | The metric value is low, which may signal a poor physical CPU cores
 | utilization caused by:
 |     - load imbalance
 |     - threading runtime overhead
 |     - contended synchronization
 |     - thread/process underutilization
 |     - incorrect affinity that utilizes logical cores instead of physical
 |       cores
 | Explore sub-metrics to estimate the efficiency of MPI and OpenMP parallelism
 | or run the Locks and Waits analysis to identify parallel bottlenecks for
 | other parallel runtimes.
 |
    Effective Logical Core Utilization: 0.0% (0.000 out of 128)
     | The metric value is low, which may signal a poor logical CPU cores
     | utilization. Consider improving physical core utilization as the first
     | step and then look at opportunities to utilize logical cores, which in
     | some cases can improve processor throughput and overall performance of
     | multi-threaded applications.
     |
Collection and Platform Info
    Application Command Line: /home/ecurbtw/REHO/venv/bin/python3 "profiling_reho_biggest.py"
    Operating System: 6.2.0-37-generic DISTRIB_ID=Ubuntu DISTRIB_RELEASE=22.04 DISTRIB_CODENAME=jammy DISTRIB_DESCRIPTION="Ubuntu 22.04.3 LTS"
    Computer Name: ecocloud-exp04
    Result Size: 2.7 GB
    Collection start time: 18:24:29 16/07/2024 UTC
    Collection stop time: 22:46:59 16/07/2024 UTC
    Collector Type: Driverless Perf system-wide sampling
    CPU
        Name: Intel(R) Xeon(R) Processor code named Sapphirerapids
        Frequency: 2.100 GHz
        Logical CPU Count: 128
        LLC size: 62.9 MB
        Cache Allocation Technology
            Level 2 capability: available
            Level 3 capability: available



## Debugging: 

 [done] a) Install Intel Sampling Drivers. --> located in /opt/intel/oneapi/vtune/latest 
 installed follwing https://community.intel.com/t5/Analyzers/Using-Vtune-Amplifier-as-quot-non-root-quot-user-on-linux/m-p/789928 and https://www.intel.com/content/www/us/en/docs/vtune-profiler/user-guide/2023-2/build-install-sampling-drivers-for-linux-targets.html
  - installed sep driver from /opt/intel/oneapi/vtune/latest/sepdk/src
  - added user ecurbtw to vtune group
  - created sep_vtune group and added ecurbtw

 [done] profile simple c++ code with VTune -> done
 [done] profile simple python code with VTune -> done
      -> [solution] include #!/usr/bin/python3 at the top of .py executable
                    make to_profile.py executable
 [doing] profiling_reho_smallest.py with VTune
    [try] source everything in the terminal before running vtune
          ```
          cd /home/ecurbtw/urbantwin-ecocloud-profiling
          source activate_env.sh
          cd reho/reho_catarin/REHO/reho/model
          vtune -collect hotspots -knob sampling-mode=hw -knob sampling-interval=0.5 ../../scripts/lausanne/profiling_reho.py
          ```
        [failed]
    [try] https://community.intel.com/t5/Analyzers/Profiling-on-python-scripts-created-in-virtual-environment/td-p/1541282
          set python3 as application and set_env.py and parameters of application

          #this might work

          cd /home/ecurbtw/urbantwin-ecocloud-profiling
          source activate_env.sh
          cd reho/reho_catarin/REHO/reho/model
          vtune -collect hotspots -knob enable-stack-collection=true -data-limit=500 -ring-buffer=10 -app-working-dir /home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/reho/model -- python3 ../../scripts/lausanne/profiling_reho_smallest.py
          
    [try] this other one
          cd /home/ecurbtw/urbantwin-ecocloud-profiling
          source activate_env.sh

           vtune -collect hotspots -knob enable-stack-collection=true -data-limit=500 -ring-buffer=10 -app-working-dir /home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/reho/model -- python3 /home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/scripts/lausanne/profiling_reho_smallest.py
          
        [error]  
            vtune -collect hotspots -knob enable-stack-collection=true -data-limit=500 -ring-buffer=10 -app-working-dir /home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/reho/model -- python3 ../../scripts/lausanne/profiling_reho_smallest.py
            vtune: Collection started. To stop the collection, either press CTRL-C or enter from another console window: vtune -r /home/ecurbtw/vtune/reho/r002hs -command stop.
            AMPLXE_TPSSCOLLECTOR: find_pyobject_offsets:50: 0 : Offset of field of struct was not found (tstate.frame)
            Assertion failed: find_pyobject_offsets:50: 0 : Offset of field of struct was not found (tstate.frame). Please contact the technical support. vtune: Error: Assertion failed: find_pyobject_offsets:50: 0 : Offset of field of struct was not found (tstate.frame). Please contact the technical support.
            vtune: Collection stopped.
            vtune: Using result path `/home/ecurbtw/vtune/reho/r002hs'    


    [try] included #!/usr/bin/python3 in all python scripts at the top 

        -> does not work for bash!

                /home/ecurbtw/urbantwin-ecocloud-profiling/vtune-script.sh: 3: source: not found
                Traceback (most recent call last):
                  File "/home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/reho/model/../../scripts/lausanne/profiling_reho_smallest.py", line 4, in <module>
                    from reho.model.reho import *
                  File "/home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/reho/model/../../reho/model/reho.py", line 4, in <module>
                    from scipy.stats import qmc
                ModuleNotFoundError: No module named 'scipy'
                /home/ecurbtw/urbantwin-ecocloud-profiling/vtune-script.sh: 2: !#/bin/bash: not found
                /home/ecurbtw/urbantwin-ecocloud-profiling/vtune-script.sh: 4: source: not found
                Traceback (most recent call last):
                  File "/home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/reho/model/../../scripts/lausanne/profiling_reho.py", line 3, in <module>
                    from reho.model.reho import *
                  File "/home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/reho/model/../../reho/model/reho.py", line 4, in <module>
                    from scipy.stats import qmc

    
    [try] # python your_script.py /path/to/your/folder

          cd /home/ecurbtw/urbantwin-ecocloud-profiling
          source activate_env.sh
          cd reho/reho_catarin/REHO/reho/model

          vtune -collect hotspots -knob enable-stack-collection=true -data-limit=500 -ring-buffer=10 -app-working-dir /home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/reho/model -- python3 /home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/scripts/lausanne/profiling_reho_smallest.py

          vtune -collect hotspots -knob enable-stack-collection=true -data-limit=500 -ring-buffer=10 -app-working-dir /home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/reho/model -- /home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho-env/bin/python /home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/scripts/lausanne/profiling_reho_smallest.py

          /home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho-env/bin/python ../../scripts/lausanne/profiling_reho_smallest.py

    [try] vtune -collect hotspots -result-dir results -- myenv/bin/python script.py
    ```bash
    source /opt/intel/oneapi/setvars.sh
    cd reho/reho_catarin/REHO/reho/model
    vtune -collect hotspots -knob enable-stack-collection=true -data-limit=500 -ring-buffer=10 -app-working-dir /home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/reho/model -- /home/ecurbtw/REHO/venv/bin/python /home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/scripts/lausanne/profiling_reho_smallest.py
      [failed] --> give up and try perf



    vtune -collect hotspots -knob enable-stack-collection=true -data-limit=500 -ring-buffer=10 /home/ecurbtw/REHO/venv/bin/python3 profiling_reho.py

    AMPLXE_TPSSCOLLECTOR: find_pyobject_offsets:50: 0 : Offset of field of struct was not found (tstate.frame)

    [try perf] 
        perf record -g --call-graph dwarf -- python3 /home/ecurbtw/REHO/venv/bin/python3 profiling_reho.py


      -g: Enables call graph recording (stack trace capturing).
      --call-graph dwarf: Uses DWARF debug information to unwind the stack, providing detailed stack traces.
      The command after -- is the Python script you want to profile.


      cd /home/ecurbtw/urbantwin-ecocloud-profiling
      source activate_env.sh
      cd reho/reho_catarin/REHO/reho/model
      echo -1 | sudo tee /proc/sys/kernel/perf_event_paranoid
      export AMPL_PATH="/home/ecurbtw/urbantwin-ecocloud-profiling/reho/ampl/ampl.linux-intel64"


      perf record -g --call-graph dwarf -- /home/ecurbtw/REHO/venv/bin/python3 profiling_reho.py

      vtune -collect hotspots -knob enable-stack-collection=true -data-limit=500 -ring-buffer=10 /home/ecurbtw/REHO/venv/bin/python3 profiling_reho.py


      sudo export AMPL_PATH="/home/ecurbtw/urbantwin-ecocloud-profiling/reho/ampl/ampl.linux-intel64"
      
      sudo perf record -g --call-graph dwarf -- /home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho-env/bin/python ../../scripts/lausanne/profiling_reho_smallest.py


    ```




# Install and run REHO scenariosn

## Setup repo
cd ~/urbantwin-ecocloud-profiling/reho/
cd reho_catarin/
git clone https://github.com/IPESE/REHO.git
<!-- git checkout catrina_braz -->
git checkout remotes/origin/catarina_braz

## Setup environment
~/urbantwin-ecocloud-profiling$ source activate_env.sh

## Places of interest
/home/ecurbtw/urbantwin-ecocloud-profiling/reho/lausanne_data
/home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/scripts/lausanne

## For testing AMPL and REHO - TODO config ampl license
cd /home/ecurbtw/urbantwin-ecocloud-profiling/reho/reho_catarin/REHO/reho/model
python3 ../../scripts/examples/0_compact_totex.py
python3 ../../scripts/examples/0_compact_totex.py


## For running Lausanne profiling scripts
cd urbantwin-ecocloud-profiling
source activate_env.sh
cd reho/reho_catarin/REHO/reho/model

## Run one of the following commands to launch execution of different REHO 
python3 ../../scripts/lausanne/profiling_reho_biggest.py 

python3 ../../scripts/lausanne/profiling_reho_smallest.py 

python3 ../../scripts/lausanne/profiling_reho.py 


# Profiling REHO

## Vtune

Before using VTune:
 source /opt/intel/oneapi/setvars.sh
cd 
Optinally:
 source source /opt/intel/oneapi/vtune/latest/sep_vars.sh

vtune-gui


## Perf and Turbostat (Script Ali)

```
workload="prueba"
time=60
cores="0-31,64-95"

# sets the frequency of all cores to 2.5 GHz
sudo cpupower frequency-set -u 2.5GHz -d 2.5GHz
# enables the idle states
sudo cpupower idle-set -E

sleep 2
# profiles the network bandwidth usage
timeout ${time}s bmon -i netlink:notc -o ascii | tee $workload/network_usage.txt

sleep 2
# profiles the memory bandwidth usage
sudo timeout ${time}s pcm-memory 1 -csv=$workload/memory_usage.txt

sleep 2
echo "cpu utilization"
sudo perf stat -A -C $cores -e cycles --output=$workload/cpu_utilization.txt -- sleep ${time}

sleep 2
# profiles the package power consumption
sudo timeout ${time}s turbostat -c package --quiet --show Busy%,Avg_MHz,PkgTmp,PkgWatt --interval 2 | tee $workload/power_consumption_idle_enabled.txt

<!-- sleep 2
echo "L3MPKI 48MB"
~/users/ali/CAT/give_socket_0_48MB_LLC.sh
# profiles the cache miss rate and IPC
sudo perf stat -C $cores -M L3MPKI,IPC --output=$workload/L3MPKI_48MB.txt -- sleep ${time}

sleep 2
echo "L3MPKI 32MB"
~/users/ali/CAT/give_socket_0_32MB_LLC.sh
sudo perf stat -C $cores -M L3MPKI,IPC --output=$workload/L3MPKI_32MB.txt -- sleep ${time}

sleep 2
echo "L3MPKI 16MB"
~/users/ali/CAT/give_socket_0_16MB_LLC.sh
sudo perf stat -C $cores -M L3MPKI,IPC --output=$workload/L3MPKI_16MB.txt -- sleep ${time}

sleep 2
echo "L3MPKI 8MB"
~/users/ali/CAT/give_socket_0_8MB_LLC.sh
sudo perf stat -C $cores -M L3MPKI,IPC --output=$workload/L3MPKI_8MB.txt -- sleep ${time}
-->

sleep 2 
echo "REHO Big"
python3 ../../scripts/lausanne/profiling_reho_biggest.py 
sudo perf stat -C $cores -M L3MPKI,IPC --output=$workload/L3MPKI_4MB.txt -- sleep ${time}
<!-- 
sleep 2
~/users/ali/CAT/give_socket_0_48MB_LLC.sh
sudo cpupower idle-set -D 1 -->

sleep 60
sudo timeout ${time}s turbostat -c package --quiet --show Busy%,Avg_MHz,PkgTmp,PkgWatt --interval 2 | tee $workload/power_consumption_idle_disabled.txt

echo "finished"
```


## Check Other Perf Tools
VTune
- flamegraphs
