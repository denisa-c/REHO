#!/usr/bin/python3
import sys
sys.path.append('/home/ecurbtw/REHO')

from reho.model.reho import *
import time
import warnings
warnings.filterwarnings("ignore")

# TO PROFILE REHO REMOVE COMMENTS IN reho.py, LINES 456 to 462

tic = time.perf_counter()

scenarios_list = ['totex']
nb_buildings_list = [5000]
nb_excl_list = [1]
nb_excl_list.reverse()
excluded_list = ['NG_Cogeneration', 'Battery', 'OIL_Boiler', 'NG_boiler', 'ThermalSolar', 'WaterTankSH', 'HeatPump', 'PV']

results = {}  # Dictionary to store results

if __name__ == '__main__':
    method = {'district-scale': True}
    for scenarios in scenarios_list:
        for nb_buildings in nb_buildings_list:
            for nb_excl in nb_excl_list:
                # Set scenario
                scenario = dict()
                if scenarios == 'totex':
                    scenario['Objective'] = 'TOTEX'
                    scenario['EMOO'] = {}
                    scenario['specific'] = []
                    scenario['name'] = scenarios
                for nb_buildings in nb_buildings_list:
                    # Set building parameters
                    reader = QBuildingsReader()
                    qbuildings_data = reader.read_csv(buildings_filename='/home/ecurbtw/REHO/scripts/lausanne/QBuildings/Lausanne_sectors.csv', nb_buildings=nb_buildings)

                    # Set specific parameters 
                    parameters = {}

                    # Select clustering file
                    cluster = {'Location': 'Pully', 'Attributes': ['I', 'T', 'W'], 'Periods': 10, 'PeriodDuration': 24}

                    # Choose energy system structure options
                    scenario['exclude_units'] = excluded_list[:nb_excl]
                    scenario['enforce_units'] = []

                    # Initialize available units and grids
                    grids = infrastructure.initialize_grids({'Electricity': {"Cost_demand_cst": 0.08, "Cost_supply_cst": 0.20},
                                                             'NaturalGas': {"Cost_demand_cst": 0.06, "Cost_supply_cst": 0.20}})
                    units = infrastructure.initialize_units(scenario, grids)

                    # Run optimization
                    reho_model = reho(qbuildings_data=qbuildings_data, units=units, grids=grids, parameters=parameters,
                                      cluster=cluster, scenario=scenario, method=method, solver='gurobiasl', scenarios=scenarios, nb_buildings=nb_buildings, nb_excl=nb_excl)

                    reho_model.method['building_scale'] = True
                    #reho_model.method['district_scale'] = True
                    #reho_model.method['parallel_computation'] = True

                    if 'totex' in scenarios:
                        reho_model.single_optimization()  # profile this
                    elif 'pareto' in scenarios:
                        reho_model.generate_pareto_curve()

                    # Store results
                    print("results for scenario=",scenarios,", nb_buldindings=", nb_buildings, ", nb_excl=", nb_excl)
                    results[(scenarios, nb_buildings, nb_excl)] = reho_model

# measure this apart
# Save results outside the loop
for key, result in results.items():
    scenarios, nb_buildings, nb_excl = key
    reho.save_results(result, format=['pickle', 'xlsx'], filename=f'VtuneSimpleCaseDS_{scenarios}_{nb_buildings}_{nb_excl}')

toc = time.perf_counter()
print(f"Took {(toc-tic)/60:.4f} minutes")
