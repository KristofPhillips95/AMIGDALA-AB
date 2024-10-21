# LOADING OTHER FUNCTIONS, SCRIPTS, OR PACKAGES
#-------------------------------------------------------------------------------
include("ontology.jl")
include("social_edges.jl")

# AUXILIARY FUNCTIONS
#-------------------------------------------------------------------------------

################################################################################
#------------------------------SOLAR PV PANEL-----------------------------------
################################################################################
# Specification of a solar PV panel
mutable struct Technology <: PhysicalNode
    # Properties
    label::String
    status::Dict # I AM NOT SURE IF THIS PROPERTY NEEDS TO BE A DICTIONARY 
    physicalProperties::Dict
    economicProperties::Dict
    designProperties::Dict
    outEdges::Array{PhysicalEdge, 1}
    inEdges::Union{Array{PhysicalEdge, 1}, Array{Ownership, 1}}
        
    # Methods
    # Generic
    #-------------------------------------------------------------------------------
    function Technology(label::String,
        status::Dict,
        physicalProperties::Dict,
        economicProperties::Dict,
        designProperties::Dict,
        outEdges::Array{PhysicalEdge, 1},
        inEdges::Union{Array{PhysicalEdge, 1}, Array{Ownership, 1}})
   
        # Constructor
        self = new()
    
        self.label = label
        self.status = status
        self.physicalProperties = physicalProperties
        self.economicProperties = economicProperties
        self.designProperties = designProperties
        self.outEdges = outEdges
        self.inEdges = inEdges
      
        return self

    end    
 
end

