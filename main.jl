# Activate environment - ensure consistency accross computers
# using Pkg
using Pkg
Pkg.activate(@__DIR__) # @__DIR__ = directory this script is in
Pkg.instantiate() # Download and install this environments packages
Pkg.precompile() # Precompiles all packages in environment


# LOADING OTHER FUNCTIONS OR SCRIPTS
#-------------------------------------------------------------------------------
using CSV
using DataFrames
using YAML
using XLSX

# Home directory
const home_dir = @__DIR__

#include(joinpath(home_dir,"Procedures","data_wrangling.jl"))
include(joinpath(home_dir, "simulation.jl"))


# READING INPUT DATA
#-------------------------------------------------------------------------------
println("Reading input data ...")
println(" ")

initial_operating_technologies = YAML.load_file(joinpath(@__DIR__, "Input_Data", "initial_operating_technologies.yaml"))
alternatives_technology = YAML.load_file(joinpath(@__DIR__, "Input_Data", "alternatives_technology.yaml"))
economic_drivers = CSV.read(joinpath(@__DIR__, "Input_Data", "economic_drivers.csv"), DataFrame)
time_series_years = XLSX.readxlsx(joinpath(@__DIR__, "Input_Data", "representative_days_time_series_years.xlsx"))
CO2_prices = select(economic_drivers, [:Year, :CO2_Price])
other_input_parameters = YAML.load_file(joinpath(@__DIR__, "Input_Data", "simulation_general_input_parameters.yaml"))

# Creating the dataframe 'representative_days'
sheet = XLSX.gettable(time_series_years["representativeDays"])

# Convert the DataTable to a DataFrame
representative_days = DataFrame(sheet)

number_representative_days = nrow(representative_days)

initial_year = other_input_parameters["initial_year"]
final_year = other_input_parameters["final_year"]
milestone_year = other_input_parameters["milestone_year"]
temporal_resolution = other_input_parameters["temporal_resolution"]
value_of_lost_load = other_input_parameters["value_of_lost_load"]
repetitions = other_input_parameters["repetitions"]
vector_seed = other_input_parameters["vector_seed"]

println("Finish reading input data ...")
println(" ")

# RUNNING THE SIMULATION
#-------------------------------------------------------------------------------
println("Running the simulation ...")
println(" ")

my_simulation = simulation(initial_operating_technologies,
alternatives_technology,
time_series_years,
CO2_prices,
representative_days,
temporal_resolution,
number_representative_days,
value_of_lost_load,
initial_year,
final_year,
milestone_year,
repetitions,
vector_seed)


my_simulation[2020][1].technologies
# PROCESSING DATA AND GENERATION OF FIGURES
#-------------------------------------------------------------------------------
println("Processing the results and generating figures")
println(" ")

# NOTE: ADD POSTPROCESSING FILE 

println("Finish processing the results and generating figures")
println(" ")

# NOTE: ADD VISUALIZATION FILE 

# Generation of the CSV file
println("Generation of a CSV file")
println(" ")

# CSV.write(joinpath(home_dir, "Results", "Experiment_01-07-2023_EUT_14_40.csv"), df)

println("Finish generation of a CSV file")
println(" ")

