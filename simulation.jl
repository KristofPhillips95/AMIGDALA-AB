# LOADING OTHER FUNCTIONS, SCRIPTS, OR PACKAGES
#-------------------------------------------------------------------------------
using Random

include("set_up.jl")
include("go_once!.jl")

# AUXILIARY FUNCTIONS
#-------------------------------------------------------------------------------
function results_dataframe()

    """
    
    """
    
    # NOTE: THE DATAFRAME NEEDS TO DEFINE IN ADVANCE THE VARIABLES TO BE STORED.
    df = DataFrame(run_number = Int64[ ],
    year = Int64[ ])


    return df


end

#-------------------------------------------------------------------------------
function results_dic()

    """
    
    """

    dic = Dict{Int64, Dict{String, Any}}()


    return dic


end



################################################################################
#------------------------------MAIN FUNCTION------------------------------------
################################################################################
function simulation(initial_operating_technologies::Dict,
    alternatives_technology::Dict,
    time_series_years::XLSX.XLSXFile,
    CO2_prices::DataFrame,
    representative_days::DataFrame,
    temporal_resolution::Int64,
    number_representative_days::Int64,
    value_of_lost_load::Float64,
    initial_year::Int64,
    final_year::Int64,
    milestone_year::Int64,
    repetitions::Int64,
    vector_seed::Array{Int64, 1})

    """
    
    """

    # Creation of the dataframe/dictionary to store simulation's outputs 
    dataframe_results = results_dataframe()
    dic_results = results_dic()

    for i = 1:repetitions 

        # Setting a seed to ensure replication of the run
        seed = vector_seed[i]
        Random.seed!(seed)

        # Initialization of the model
        my_initialization = set_up(initial_operating_technologies)

        # Results of the initialization of my model 
        operating_technologies = my_initialization[1]
        vector_technologies = my_initialization[2]
        vector_ownerships = my_initialization[3]
        vector_gencos = my_initialization[4]

        year = initial_year

        # Store inital data in dataframe or dictionary 
        # NOTE: TO BE DETERMINED 

        # Run the model narrative ("go_once")
        for year = initial_year:final_year

            Random.seed!(seed)

            year = year + 1

            # Running the simulation in one step 
            one_run_results = go_once!(vector_gencos,
            vector_technologies,
            vector_ownerships,
            alternatives_technology,
            operating_technologies,
            time_series_years,
            CO2_prices,
            representative_days,
            temporal_resolution,
            number_representative_days,
            value_of_lost_load,
            year,
            final_year,
            milestone_year)

            # Results of the simulation in one step 
            vector_gencos = one_run_results[1]
            vector_technologies = one_run_results[2]
            vector_ownerships = one_run_results[3]
            operating_technologies = one_run_results[4]
            dic_electricity_generation = one_run_results[5]
            λmat = one_run_results[6]

            # Store data in dataframe or dictionary 
            # NOTE: TO BE DETERMINED 

        end

    end

    return (vector_gencos, vector_technologies, vector_ownerships, 
    operating_technologies) # NOTE: ADD THE DATAFRAME OR DICTIONARY STORING RESULTS 

end