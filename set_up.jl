# LOADING OTHER FUNCTIONS, SCRIPTS, OR PACKAGES
#-------------------------------------------------------------------------------
include(joinpath(home_dir, "Definitions", "collective_structure.jl"))
include(joinpath(home_dir, "Procedures", "creation_technology!.jl"))
include(joinpath(home_dir, "Procedures", "update_dic_operating_technologies!.jl"))


# AUXILIARY FUNCTIONS
#-------------------------------------------------------------------------------
function creating_dictionary_initial_technologies(initial_operating_technologies::Dict)

    """
    
    """

    # Initializing dictionary 
    my_dic = Dict{String, Dict{String, Any}}()

    dic_dispatchable = initial_operating_technologies["dispatchableGenerators"]
    for key in keys(dic_dispatchable)

        alternative_name = split(key, "_")[1]
        my_dic[alternative_name] = dic_dispatchable[key]

    end

    dic_variable = initial_operating_technologies["variableGenerators"]
    for key in keys(dic_variable)

        alternative_name = split(key, "_")[1]
        my_dic[alternative_name] = dic_variable[key]

    end

    return my_dic

end

#-------------------------------------------------------------------------------
function creation_generation_companies!(number::Int64,
    vector_generation_companies::Vector{Agent})

    """
    
    """  

    # NOTE: IN THIS VERSION, THESE PROPERTIES ARE ASSUMED TO BE THE SAME FOR
    # ALL GENERATION COMPANIES 
    # Specifying genco's properties
    label = string("genco_", number)
    physical_properties = Dict()
    economic_properties = Dict("discount_rate" => 0.05)
    personal_values = Dict()
    information = Dict()
    technologies = Dict()
    possible_roles = Dict("investor" => true)
    intrinsic_behaviors = Dict()
    decision_making_criteria = Dict("sight" => 5)
    technologies = Array{Technology, 1}(undef, 0)
    in_edges = Array{Edge, 1}(undef,0)
    out_edges = Array{Edge, 1}(undef,0)

    # Creation of a generation company
    this_generation_company = Agent(label,
    physical_properties,
    economic_properties,
    personal_values,
    information,
    technologies,
    possible_roles,
    intrinsic_behaviors,
    decision_making_criteria,
    out_edges,
    in_edges)

    # Update the vector of generation companies 
    push!(vector_generation_companies, this_generation_company)

    return (this_generation_company, vector_generation_companies)

end

################################################################################
#------------------------------MAIN FUNCTION------------------------------------
################################################################################
function set_up(initial_operating_technologies::Dict)

    """
    
    """

    # Initialization
    operating_technologies = Dict()
    operating_technologies["dispatchableGenerators"] = Dict()
    operating_technologies["variableGenerators"] = Dict()
    vector_generation_companies = Array{Agent, 1}(undef, 0)
    vector_technologies = Array{Technology, 1}(undef, 0)
    vector_ownerships = Array{SocialEdge, 1}(undef, 0)
    counter = 0

    # Creating a dictionary with all the initial technologies 
    dic_initial_technologies = creating_dictionary_initial_technologies(initial_operating_technologies)
    
    # Creation of generation companies and technologies 
    for key in keys(dic_initial_technologies)

        # key = "Coal"
  
        # Update the counter 
        counter = counter + 1

        # ASSUMPTION: THE MAPPING BETWEEN GENERATION COMPANIES AND TECHNOLOGIES IS 1:1
        # Creation agents 
        my_list_gencos = creation_generation_companies!(counter,
        vector_generation_companies)

        this_generation_company = my_list_gencos[1]
        vector_generation_companies = my_list_gencos[2]
        
        # Creation of technologies 
        my_list_technologies = creation_technology!(dic_initial_technologies,    
        key,
        0,
        this_generation_company,
        vector_technologies,
        vector_ownerships)

        vector_ownerships = my_list_technologies[3]
        vector_technologies = my_list_technologies[4] 
        label = my_list_technologies[5] 

        # Updating dictionary operating technologies 
        operating_technologies = update_dic_operating_technologies!(operating_technologies,
        dic_initial_technologies,
        label,
        key)

    end

    return (operating_technologies, vector_technologies, vector_ownerships, vector_generation_companies)

end