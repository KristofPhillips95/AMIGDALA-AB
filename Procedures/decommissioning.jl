# LOADING OTHER FUNCTIONS, SCRIPTS, OR PACKAGES
#-------------------------------------------------------------------------------


# AUXILIARY FUNCTIONS
#-------------------------------------------------------------------------------
function updating_dictionary_technology(operating_technologies::Dict)
    
    """
    
    """

    # Initializing dictionary of operating technologies 
    new_operating_technologies = deepcopy(operating_technologies)

    # Iterate over the outer dictionary and remove entries where "decommissionStatus" is true
    dic_dispatchable = new_operating_technologies["dispatchableGenerators"]
    filtered_dispatchable = Dict(k => v for (k, v) in dic_dispatchable if !v["decommissionStatus"])

    # Updating dictionary of dispatchable technologies 
    new_operating_technologies["dispatchableGenerators"] = filtered_dispatchable 

    # Iterate over the outer dictionary and remove entries where "decommissionStatus" is true
    dic_variable= new_operating_technologies["variableGenerators"]
    filtered_variable = Dict(k => v for (k, v) in dic_variable if !v["decommissionStatus"])

    # Updating dictionary of variable technologies 
    new_operating_technologies["variableGenerators"] = filtered_variable

    return new_operating_technologies

end

#-------------------------------------------------------------------------------
function updating_decommission_status(operating_technologies::Dict,
    label::String,
    alternative_name::String)

    """
    
    """

    # Initializing dictionary of operating technologies 
    new_operating_technologies = deepcopy(operating_technologies)

    if alternative_name == "Nuclear" || alternative_name == "Coal" ||
        alternative_name == "CCGT" || alternative_name == "OCGT"

            my_dic = new_operating_technologies["dispatchableGenerators"]

            my_dic[label]["decommissionStatus"] = true

        elseif alternative_name == "Solar" || alternative_name == "Wind"

            my_dic = new_operating_technologies["variableGenerators"]

            my_dic[label]["decommissionStatus"] = true

        end   

    return new_operating_technologies

end

################################################################################
#------------------------------MAIN FUNCTION------------------------------------
################################################################################
function decommissioning(vector_generation_companies::Vector{Agent},
    operating_technologies::Dict,
    vector_technologies::Vector{Technology},
    year::Int64)

    """
    
    """

    # Initialize dictionaries and vectors 
    new_vector_generation_companies = deepcopy(vector_generation_companies)
    new_operating_technologies = deepcopy(operating_technologies)
    new_vector_technologies = deepcopy(vector_technologies)

    # technology = new_vector_technologies[1]
    # tech_decommission_year = technology.designProperties["decommissionYear"]

    # Define technology's decomission status 
    for technology in new_vector_technologies

        tech_decommission_year = technology.designProperties["decommissionYear"]

        if tech_decommission_year == year 

            technology.designProperties["decommissionStatus"] = true

            # Updating the dictionary containing operating technologies
            label = technology.label 
            alternative_name = split(label, '_')[1]

            new_operating_technologies = updating_decommission_status(new_operating_technologies,
            label,
            alternative_name)
      
        end

    end

    # Removing the technologies to be decommissioned from dictionary 
    new_operating_technologies = updating_dictionary_technology(new_operating_technologies)
    
    # Remove from vector of technologies the items whose decommissionStatus = true
    new_vector_technologies = filter!(tech -> !tech.designProperties["decommissionStatus"], new_vector_technologies)

    # Each generation company removes the technologies whose decommissionStatus = true
    for genco in new_vector_generation_companies

        genco.technologies = filter(tech -> !tech.designProperties["decommissionStatus"], genco.technologies)

    end

    return (new_vector_generation_companies, new_operating_technologies, new_vector_technologies)

end