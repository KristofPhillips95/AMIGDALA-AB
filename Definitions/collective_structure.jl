# LOADING OTHER FUNCTIONS, SCRIPTS, OR PACKAGES
#-------------------------------------------------------------------------------
include("Ontology.jl")
include("physical_structure.jl")

# AUXILIARY FUNCTIONS
#-------------------------------------------------------------------------------

################################################################################
#------------------------------MAIN FUNCTION------------------------------------
################################################################################
# Specification of a houseowner
mutable struct Agent <: SocialNode
    # Properties
    label::String
    physicalProperties::Dict
    economicProperties::Dict
    personalValues::Dict
    information::Dict
    technologies::Array{Technology,1}
    possibleRoles::Dict
    intrinsicBehaviors::Dict
    decisionMakingCriteria::Dict
    outEdges::Array{Edge,1}
    inEdges::Array{Edge, 1}
    
    # Methods
    function Agent(label::String,
        physicalProperties::Dict,
        economicProperties::Dict,
        personalValues::Dict,
        information::Dict,
        technologies::Array{Technology,1},
        possibleRoles::Dict,
        intrinsicBehaviors::Dict,
        decisionMakingCriteria::Dict,
        outEdges::Array{Edge,1},
        inEdges::Array{Edge, 1})
    
        # Constructor
        self = new()
    
        self.label = label
        self.physicalProperties = physicalProperties
        self.economicProperties= economicProperties
        self.personalValues = personalValues
        self.information = information
        self.technologies = technologies
        self.possibleRoles = possibleRoles
        self.intrinsicBehaviors = intrinsicBehaviors
        self.decisionMakingCriteria = decisionMakingCriteria
        self.outEdges = outEdges
        self.inEdges = inEdges
      
        return self
    end
end