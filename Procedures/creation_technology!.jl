# LOADING OTHER FUNCTIONS, SCRIPTS, OR PACKAGES
#-------------------------------------------------------------------------------
include("creation_technology_and_ownership_links!.jl")

# NOTE: THIS FUNCTION USES JULIA'S MULTIDISPATCH FEATURE

# AUXILIARY FUNCTIONS
#-------------------------------------------------------------------------------
function specifying_properties_technology(alternatives_technology::Dict,
    alternative_name::String,
    number_next_alternative::Int64)

    """
    This function should be used when initializing the simulation
    
    """

    # println("specifying_properties_technology")

    # Specifying properties of the agent: technology 
    label = string(alternative_name, "_$(number_next_alternative)")
    status = Dict("decommission" => false)
    
    if alternative_name == "Nuclear" || alternative_name == "Coal" ||
        alternative_name == "CCGT" || alternative_name == "OCGT"

        # println("alternative_name == Nuclear || alternative_name == Coal
        # alternative_name == CCGT || alternative_name == OCGT")

        my_dic = alternatives_technology[alternative_name]

        # Extract properties from the dictionary
        maxPowerOutput = my_dic["maxPowerOutput"]
        minStableOperatingPoint = my_dic["minStableOperatingPoint"]
        effmin = my_dic["effmin"]
        effmax = my_dic["effmax"]
        fuelcost = my_dic["fuelcost"]
        carbonintensity = my_dic["carbonintensity"]
        lifetime = my_dic["lifetime"]
        decommissionStatus = my_dic["decommissionStatus"]
        decommissionYear= my_dic["decommissionYear"]
        
        design_properties = Dict("maxPowerOutput" => maxPowerOutput, 
        "minStableOperatingPoint" => minStableOperatingPoint,
        "effmin" => effmin,
        "effmax" => effmax,
        "carbonintensity" => carbonintensity,
        "lifetime" => lifetime,
        "decommissionStatus" => decommissionStatus,
        "decommissionYear" => decommissionYear)

        economic_properties = Dict("fuelcost" => fuelcost)

        physical_properties = Dict()        

    elseif alternative_name == "Solar" || alternative_name == "Wind"

        my_dic = alternatives_technology[alternative_name]

        # Extract properties from the dictionary
        installedCapacity = my_dic["installedCapacity"]
        lifetime = my_dic["lifetime"]
        decommissionStatus = my_dic["decommissionStatus"]
        decommissionYear = my_dic["decommissionYear"]
        
        design_properties = Dict("installedCapacity" => installedCapacity, 
        "lifetime" => lifetime,
        "decommissionStatus" => decommissionStatus,
        "decommissionYear" => decommissionYear)

        economic_properties = Dict()

        physical_properties = Dict()

    end

    # Links
    out_edges = Array{PhysicalEdge, 1}(undef, 0)
    in_edges = Array{Ownership, 1}(undef, 0)

    return (label, status, physical_properties, economic_properties, design_properties, 
    out_edges, in_edges)

end

#-------------------------------------------------------------------------------
function specifying_properties_technology(alternatives_technology::Dict,
    alternative_name::String,
    number_next_alternative::Int64,
    year::Int64)

    """
    This function should be used when a new technology is created during the simulation
    
    """

    # println("specifying_properties_technology")

    # Specifying properties of the agent: technology 
    label = string(alternative_name, "_$(number_next_alternative)")
    status = Dict("decommission" => false)
    
    if alternative_name == "Nuclear" || alternative_name == "Coal" ||
        alternative_name == "CCGT" || alternative_name == "OCGT"

        # println("alternative_name == Nuclear || alternative_name == Coal
        # alternative_name == CCGT || alternative_name == OCGT")

        my_dic = alternatives_technology[alternative_name]

        # Extract properties from the dictionary
        maxPowerOutput = my_dic["maxPowerOutput"]
        minStableOperatingPoint = my_dic["minStableOperatingPoint"]
        effmin = my_dic["effmin"]
        effmax = my_dic["effmax"]
        fuelcost = my_dic["fuelcost"]
        carbonintensity = my_dic["carbonintensity"]
        lifetime = my_dic["lifetime"]
        decommissionStatus = my_dic["decommissionStatus"]
        decommissionYear = year + lifetime 
        
        design_properties = Dict("maxPowerOutput" => maxPowerOutput, 
        "minStableOperatingPoint" => minStableOperatingPoint,
        "effmin" => effmin,
        "effmax" => effmax,
        "carbonintensity" => carbonintensity,
        "lifetime" => lifetime,
        "decommissionStatus" => decommissionStatus,
        "decommissionYear" => decommissionYear)

        economic_properties = Dict("fuelcost" => fuelcost)

        physical_properties = Dict()        

    elseif alternative_name == "Solar" || alternative_name == "Wind"

        my_dic = alternatives_technology[alternative_name]

        # Extract properties from the dictionary
        installedCapacity = my_dic["installedCapacity"]
        lifetime = my_dic["lifetime"]
        decommissionStatus = my_dic["decommissionStatus"]
        decommissionYear = year + lifetime 
        
        design_properties = Dict("installedCapacity" => installedCapacity, 
        "lifetime" => lifetime,
        "decommissionStatus" => decommissionStatus,
        "decommissionYear" => decommissionYear)

        economic_properties = Dict()

        physical_properties = Dict()

    end

    # Links
    out_edges = Array{PhysicalEdge, 1}(undef, 0)
    in_edges = Array{Ownership, 1}(undef, 0)

    return (label, status, physical_properties, economic_properties, design_properties, 
    out_edges, in_edges)

end

################################################################################
#------------------------------MAIN FUNCTION------------------------------------
################################################################################
function creation_technology!(alternatives_technology::Dict,    
    alternative_name::String,
    number_next_alternative::Int64,
    owner::Agent,
    vector_technologies::Vector{Technology},
    vector_ownerships::Vector{SocialEdge})

    """
    This function should be used when initializing the simulation
    
    """

    # Specifying technology's properties 
    technology_properties = specifying_properties_technology(alternatives_technology,
    alternative_name,
    number_next_alternative)

    label = technology_properties[1]
    status = technology_properties[2]
    physical_properties = technology_properties[3]
    economic_properties_technology = technology_properties[4]
    design_properties = technology_properties[5]
    out_edges = technology_properties[6]
    in_edges = technology_properties[7]

    # Specifying the properties of the links 
    economic_properties_link = Dict()

    # Create new plant and adding to genco's list of technologies 
    sol = creation_technology_and_ownership_links!(owner,
    label, 
    status,
    vector_technologies,
    vector_ownerships,
    physical_properties,
    economic_properties_technology,
    economic_properties_link,
    design_properties,
    out_edges,
    in_edges) 

    this_technology = sol[1]
    this_ownership_link = sol[2]
    vector_ownerships = sol[3]
    vector_technologies = sol[4]

    return (this_technology, this_ownership_link, vector_ownerships,
    vector_technologies, label)

end

#-------------------------------------------------------------------------------
function creation_technology!(alternatives_technology::Dict,    
    alternative_name::String,
    number_next_alternative::Int64,
    owner::Agent,
    vector_technologies::Vector{Technology},
    vector_ownerships::Vector{SocialEdge},
    year::Int64)

    """
    This function should be used when a new technology is created during the simulation
    
    """

    # Specifying technology's properties 
    technology_properties = specifying_properties_technology(alternatives_technology,
    alternative_name,
    number_next_alternative,
    year)

    label = technology_properties[1]
    status = technology_properties[2]
    physical_properties = technology_properties[3]
    economic_properties_technology = technology_properties[4]
    design_properties = technology_properties[5]
    out_edges = technology_properties[6]
    in_edges = technology_properties[7]

    # Specifying the properties of the links 
    economic_properties_link = Dict()

    # Create new plant and adding to genco's list of technologies 
    sol = creation_technology_and_ownership_links!(owner,
    label, 
    status,
    vector_technologies,
    vector_ownerships,
    physical_properties,
    economic_properties_technology,
    economic_properties_link,
    design_properties,
    out_edges,
    in_edges) 

    this_technology = sol[1]
    this_ownership_link = sol[2]
    vector_ownerships = sol[3]
    vector_technologies = sol[4]

    return (this_technology, this_ownership_link, vector_ownerships,
    vector_technologies, label)

end