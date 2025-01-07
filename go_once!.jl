# LOADING OTHER FUNCTIONS, SCRIPTS, OR PACKAGES
#-------------------------------------------------------------------------------

include(joinpath(home_dir, "Definitions", "collective_structure.jl"))
include(joinpath(home_dir, "Procedures", "data_wrangling.jl"))
include(joinpath(home_dir, "Procedures", "economic_dispatch.jl"))
include(joinpath(home_dir, "Procedures", "decommissioning.jl"))
include(joinpath(home_dir, "Procedures", "investment_process.jl"))


# AUXILIARY FUNCTIONS
#-------------------------------------------------------------------------------



################################################################################
#------------------------------MAIN FUNCTION------------------------------------
################################################################################
function go_once!(vector_gencos::Vector{Agent},
    vector_technologies::Vector{Technology},
    vector_ownerships::Vector{SocialEdge},
    alternatives_technology::Dict,
    operating_technologies::Dict,
    time_series_years::XLSX.XLSXFile,
    CO2_prices::DataFrame,
    representative_days::DataFrame,
    temporal_resolution::Int64,
    number_representative_days::Int64,
    value_of_lost_load::Float64,
    year::Int64,
    final_year::Int64,
    milestone_year::Int64)

    """
    
    """

    # Initializing dictionaries and vectors 
    new_vector_gencos = deepcopy(vector_gencos)
    new_vector_technologies = deepcopy(vector_technologies)
    new_vector_ownerships = deepcopy(vector_ownerships)
    new_operating_technologies = deepcopy(operating_technologies)
    
    # Defining input data 
    (time_series, CO2_price) = data_wrangling(time_series_years,
    CO2_prices, # EUR / ton
    year)
    print(
        """
            
        Year is currently: $(year)
            
        """
        )
    if year == 2030
        print("It will go wrong now")
    end
    # Running economic dispatch model
    my_economic_dispatch = economic_dispatch(new_operating_technologies,
    time_series,
    representative_days,
    temporal_resolution,
    number_representative_days,
    value_of_lost_load,
    CO2_price)

    # Electricity generation per technology
    dic_electricity_generation = my_economic_dispatch[4]

    # Energy price
    λmat = my_economic_dispatch[5]

    # Check if the current year is a multiple of 'milestone_year'
    if year % milestone_year == 0

        # Decommission of generators 
        # my_decommission = decommissioning(new_vector_gencos,
        # new_operating_technologies,
        # new_vector_technologies,
        # year)

        # new_vector_gencos = my_decommission[1]
        # new_operating_technologies = my_decommission[2]
        # new_vector_technologies = my_decommission[3]

        # Investment in new power plants 
        my_investment = investment_process!(new_vector_gencos,
        new_vector_technologies,
        new_vector_ownerships,
        alternatives_technology,
        new_operating_technologies,
        time_series_years,
        temporal_resolution,
        representative_days,
        number_representative_days,
        value_of_lost_load,
        CO2_prices, # EUR / ton
        year,
        final_year)
        
        new_vector_gencos = my_investment[1]
        new_vector_technologies = my_investment[2]
        new_vector_ownerships = my_investment[3]
        new_operating_technologies = my_investment[4]

    else # year % milestone_year != 0

        new_vector_gencos = new_vector_gencos
        new_vector_technologies = new_vector_technologies
        new_vector_ownerships = new_vector_ownerships
        new_operating_technologies = new_operating_technologies

    end

    return (new_vector_gencos, new_vector_technologies, new_vector_ownerships, 
    new_operating_technologies, dic_electricity_generation, λmat)

end