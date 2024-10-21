# DEFINITION OF THE CLASSES
#-------------------------------------------------------------------------------
# Definition of the main classes
abstract type Node end
abstract type Edge end
# abstract type Property end

# Definition of the subclasses
# Nodes
abstract type SocialNode <: Node end
abstract type PhysicalNode <: Node end

# Edges
abstract type SocialEdge <: Edge end
abstract type PhysicalEdge <: Edge end
