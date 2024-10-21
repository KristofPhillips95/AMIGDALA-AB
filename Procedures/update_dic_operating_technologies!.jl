# LOADING OTHER FUNCTIONS, SCRIPTS, OR PACKAGES
#-------------------------------------------------------------------------------


# AUXILIARY FUNCTIONS
#-------------------------------------------------------------------------------


################################################################################
#------------------------------MAIN FUNCTION------------------------------------
################################################################################
function update_dic_operating_technologies!(operating_technologies::Dict,
    alternatives_technology::Dict,
    label::String,
    name_alternative::String)

    """
    
    """

    # Selecting the right dictionary
    if name_alternative == "Nuclear" || name_alternative == "Coal" ||
        name_alternative == "CCGT" || name_alternative == "OCGT"

        operating_technologies["dispatchableGenerators"][label] = alternatives_technology[name_alternative]

    elseif name_alternative == "Wind" || name_alternative == "Solar"

        operating_technologies["variableGenerators"][label] = alternatives_technology[name_alternative]

    end

    return operating_technologies

end