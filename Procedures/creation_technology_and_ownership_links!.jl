# LOADING OTHER FUNCTIONS, SCRIPTS, OR PACKAGES
#-------------------------------------------------------------------------------



# AUXILIARY FUNCTIONS
#-------------------------------------------------------------------------------


################################################################################
#------------------------------MAIN FUNCTION------------------------------------
################################################################################
function creation_technology_and_ownership_links!(agent::Agent,
    label::String, 
    status::Dict,
    vector_technologies::Vector{Technology},
    vector_ownerships::Vector{SocialEdge},
    physical_properties::Dict,
    economic_properties_technology::Dict,
    economic_properties_link::Dict,
    design_properties::Dict,
    out_edges::Array{PhysicalEdge, 1},
    in_edges::Array{Ownership, 1})  

    
    """
    
    """


    # Creation of technology
    # n = length(vector_technologies) + 1
    # label = string(label, n)
    this_technology = Technology(label,
    status,
    physical_properties,
    economic_properties_technology,
    design_properties,
    out_edges,
    in_edges)

    # creation of ownership links between the agent and the technology
    n = length(vector_ownerships) + 1
    label = string("Ownership_", n)
    this_ownership_link = Ownership(label,
    agent.label,
    this_technology.label,
    economic_properties_link)
 
    # technology updates the ownership Links
    this_technology.inEdges = push!(this_technology.inEdges, this_ownership_link)

    # agent updates the ownership links
    agent.outEdges = push!(agent.outEdges, this_ownership_link)

    # Agent update the vector of technologies
    agent.technologies = push!(agent.technologies, this_technology)

    # update ownership links for the observer
    vector_ownerships = push!(vector_ownerships, this_ownership_link)

    # Update the vector of technologies for the observer
    vector_technologies = push!(vector_technologies, this_technology)

    return (this_technology, this_ownership_link, vector_ownerships, vector_technologies)

end