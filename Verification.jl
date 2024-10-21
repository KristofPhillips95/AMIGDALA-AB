#-------------------------------------------------------------------------------
#-------------------------------DISPATCH MODEL----------------------------------
#-------------------------------------------------------------------------------
using Plots
using StatsPlots

# Home directory
const home_dir = @__DIR__

include(joinpath(home_dir,"Procedures","economic_dispatch.jl"))

# Reading input data
data = YAML.load_file(joinpath(@__DIR__, "Input_Data", "data.yaml"))
ts = CSV.read(joinpath(@__DIR__, "Input_Data", "timeseries.csv"), DataFrame)

# Input data
temporal_resolution = 24
number_representative_days = 1

# Running economic dispatch model 
sol = economic_dispatch(data,
ts,
temporal_resolution,
number_representative_days)

JD = sol[1]
JH = sol[2]
I = sol[3]
fobj = sol[4]
Dmat = sol[5]
gmat = sol[6]
λmat = sol[7]
βbar = sol[8]

# Visualization
# parameters
Dvec = Dmat[:,1]

# variables/expressions
Ivec = [i for i in I]
gvec = gmat[:,:,1]
λvec = λmat[:,1]

# electricity price price
p1 = plot(JH,λvec, xlabel="Timesteps [-]",ylabel="λ [EUR/MWh]",label="",legend=:outertopright);
# display(p1)

# dispatch
p2 = groupedbar(transpose(gvec[:,:]),bar_position = :stack,label=permutedims(Ivec),legend=:outertopright);
plot!(JH,Dvec, xlabel="Timesteps [-]",ylabel="Generation [MWh]", linewidth = 2,label="");
plot(p1, p2, layout = (1,2))
plot!(size=(900,400))

#-------------------------------------------------------------------------------
#--------------------------------------SET UP-----------------------------------
#-------------------------------------------------------------------------------
using YAML

include(joinpath(home_dir, "Definitions", "collective_structure.jl"))

# Home directory
const home_dir = @__DIR__

include("set_up.jl")

# Input data
initial_operating_technologies = YAML.load_file(joinpath(@__DIR__, "Input_Data", "initial_operating_technologies.yaml"))

# Model initialization 
my_initialization = set_up(initial_operating_technologies)

operating_technologies = my_initialization[1]
vector_technologies = my_initialization[2]
vector_ownerships = my_initialization[3]
vector_generation_companies = my_initialization[4]

#-------------------------------------------------------------------------------
#-------------------------------INVESTMENT PROCESS----------------------------------
#-------------------------------------------------------------------------------
using YAML
using CSV 
using XLSX

# import Pkg; Pkg.add("XLSX")

# Home directory
const home_dir = @__DIR__

include(joinpath(home_dir, "Definitions", "collective_structure.jl"))
include("set_up.jl")
include(joinpath(home_dir,"Procedures","investment_process.jl"))

# Reading input data
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
temporal_resolution = other_input_parameters["temporal_resolution"]
value_of_lost_load = other_input_parameters["value_of_lost_load"]

# Initialization
vector_generation_companies = Array{Agent, 1}(undef, 0)
vector_technologies = Vector{Technology}(undef, 0)
vector_ownerships = Vector{SocialEdge}(undef, 0)

# Create a genco
label = "Genco_1"
physicalProperties = Dict()
economicProperties = Dict("discount_rate" => 0.05)
personalValues = Dict()
information = Dict()
technologies = Dict()
possibleRoles = Dict("investor" => true)
intrinsicBehaviors = Dict()
decisionMakingCriteria = Dict("sight" => 5)
technologies = Array{Technology, 1}(undef, 0)
inEdges = Array{Edge, 1}(undef,0)
outEdges = Array{Edge, 1}(undef,0)

genco = Agent(label,
physicalProperties,
economicProperties,
personalValues,
information,
technologies,
possibleRoles,
intrinsicBehaviors,
decisionMakingCriteria,
outEdges,
inEdges)

# Update the vector of generation companies
push!(vector_generation_companies, genco)

vector_gencos = vector_generation_companies
operating_technologies = initial_operating_technologies
current_year = initial_year

# Running investment function 
sol = investment_process!(vector_gencos,
vector_technologies,
vector_ownerships,
alternatives_technology,
operating_technologies,
time_series_years,
temporal_resolution,
representative_days,
number_representative_days,
value_of_lost_load,
CO2_prices,
current_year,
final_year)

###############################################################################################################
#  OTHER CODES 
###############################################################################################################
