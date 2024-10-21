# LOADING OTHER FUNCTIONS, SCRIPTS, OR PACKAGES
#-------------------------------------------------------------------------------
include("ontology.jl")

# AUXILIARY FUNCTIONS
#-------------------------------------------------------------------------------

################################################################################
#------------------------------MAIN FUNCTIONS-----------------------------------
################################################################################
# Specification of a ownership link
mutable struct Ownership <: SocialEdge
    # Properties
    label::String  # ["link from to"] as in Netlogo
    fromAgentLabel::String
    toNodeLabel::String
    economicProperties::Dict
    
    # Methods
    # Generic
    #-------------------------------------------------------------------------------
    function Ownership(label::String,
        fromAgentLabel::String,
        toNodeLabel::String,
        economicProperties::Dict)
    
        # Constructor
        self = new()
    
        self.label = label
        self.fromAgentLabel = fromAgentLabel
        self.toNodeLabel= toNodeLabel
        self.economicProperties = economicProperties
        
        return self

    end

end

################################################################################
# Specification of an informal contract link
mutable struct InformalContract <: SocialEdge
    # Properties
    label::String  # ["link from to"] as in Netlogo
    fromAgentLabel::String
    toAgentLabel::String
    economicProperties::Dict
    
    # Methods
    # Generic
    #-------------------------------------------------------------------------------
    function InformalContract(label::String,
        fromAgentLabel::String,
        toAgentLabel::String,
        economicProperties::Dict)
    
        # Constructor
        self = new()
    
        self.label = label
        self.fromAgentLabel = fromAgentLabel
        self.toAgentLabel = toAgentLabel
        self.economicProperties = economicProperties
        
        return self

    end

end

################################################################################
# Specification of an formal contract link
mutable struct FormalContract <: SocialEdge
    # Properties
    label::String  # ["link from to"] as in Netlogo
    fromAgentLabel::String
    toAgentLabel::String
    economicProperties::Dict
    
    # Methods
    # Generic
    #-------------------------------------------------------------------------------
    function FormalContract(label::String,
        fromAgentLabel::String,
        toAgentLabel::String,
        economicProperties::Dict)
    
        # Constructor
        self = new()
    
        self.label = label
        self.fromAgentLabel = fromAgentLabel
        self.toAgentLabel = toAgentLabel
        self.economicProperties = economicProperties
        
        return self

    end

end