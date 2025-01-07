# LOADING OTHER FUNCTIONS, SCRIPTS, OR PACKAGES
#-------------------------------------------------------------------------------
using XLSX
using DataFrames
using Random 

include("data_wrangling.jl")
include("economic_dispatch.jl")
include("NPV_calculation.jl")
include("creation_technology_and_ownership_links!.jl")
include("creation_technology!.jl")
include("update_dic_operating_technologies!.jl")

# AUXILIARY FUNCTIONS
#-------------------------------------------------------------------------------
function function_calculation_profits(dic_fuel_cost_gen_elec::Dict,
    dic_emission_cost_gen_elec::Dict,
    dic_gen_elec::Dict,
    λ_mat::Matrix,
    name_alternative::String,
    alternative::String)

    """
    
    """

    # println("function_calculation_profits")

    total_revenues = 0.0
    total_cost = 0.0

    if alternative == "Nuclear" || alternative == "Coal" ||
        alternative == "CCGT" || alternative == "OCGT"

        # println("dispatchable")

        # Extracting the fuel cost by technology from the dictionary and add it up over the year
        fuel_cost_gen_elec = sum(dic_fuel_cost_gen_elec[name_alternative])         # [€]
        emission_cost_gen_elec = sum(dic_emission_cost_gen_elec[name_alternative]) # [€]
        total_cost = fuel_cost_gen_elec + emission_cost_gen_elec                   # [€]

        # Extracting the electricity generation by technology from the dictionary 
        gen_elec = dic_gen_elec[name_alternative]

        # Calculating the revenues of selling the electricity generated over the year
        total_revenues = sum(gen_elec .* λ_mat) # [€]        

    elseif alternative == "Wind" || alternative == "Solar"

        # println("variable")

        # Calculating total generation costs
        fuel_cost_gen_elec = 0.0                                 # [€]
        emission_cost_gen_elec = 0.0                             # [€]
        total_cost = fuel_cost_gen_elec + emission_cost_gen_elec # [€]

        # Extracting the electricity generation by technology from the dictionary 
        gen_elec = dic_gen_elec[name_alternative]

        # Calculating the revenues of selling the electricity generated over the year
        total_revenues = sum(gen_elec .* λ_mat) # [€]

    end

    # Calculate profits
    profits = total_revenues - total_cost  # [€]

    return profits 

end

#-------------------------------------------------------------------------------
function calculation_profits(year::Int64,
    time_series_years::XLSX.XLSXFile,
    CO2_prices::DataFrame,
    operating_technologies::Dict,
    representative_days::DataFrame,
    temporal_resolution::Int64, 
    number_representative_days::Int64,
    value_of_lost_load::Float64,
    name_alternative::String,
    alternative::String)

    """
    
    """
    
    # Defining input data 
    (ts, CO2_price) = data_wrangling(time_series_years,
    CO2_prices, # EUR / ton
    year)

    # Run economic dispatch
    sol = economic_dispatch(operating_technologies,
    ts,
    representative_days,
    temporal_resolution, 
    number_representative_days,
    value_of_lost_load,
    CO2_price)

    dic_fuel_cost_gen_elec = sol[2]
    dic_emission_cost_gen_elec = sol[3]
    dic_gen_elec = sol[4]
    λ_mat = sol[5]    

    # Calculation of the profits in the year = year
    profit = function_calculation_profits(dic_fuel_cost_gen_elec,
    dic_emission_cost_gen_elec,
    dic_gen_elec,
    λ_mat,
    name_alternative,
    alternative)

    return profit

end

#-------------------------------------------------------------------------------
function extraction_investment_costs(name_alternative::String,
    dataframe::DataFrame,
    year::Int64)

    """
    
    """

    # Extracting investment costs 
    if name_alternative == "Nuclear"

        df = select(dataframe, [:Year, :OC_Nuclear])
        investment_cost = df.OC_Nuclear[df.Year .== year][1] # €/MW

    elseif name_alternative == "Coal"

        df = select(dataframe, [:Year, :OC_Coal])
        investment_cost = df.OC_Coal[df.Year .== year][1] # €/MW

    elseif name_alternative == "CCGT"

        df = select(dataframe, [:Year, :OC_CCGT])
        investment_cost = df.OC_CCGT[df.Year .== year][1] # €/MW

    elseif name_alternative == "OCGT"

        df = select(dataframe, [:Year, :OC_OCGT])
        investment_cost = df.OC_OCGT[df.Year .== year][1] # €/MW

    elseif name_alternative == "Wind"

        df = select(dataframe, [:Year, :OC_Wind])
        investment_cost = df.OC_Wind[df.Year .== year][1] # €/MW

    elseif name_alternative == "Solar"

        df = select(dataframe, [:Year, :OC_Solar])
        investment_cost = df.OC_Solar[df.Year .== year][1] # €/MW

    end

    return investment_cost 

end

#-------------------------------------------------------------------------------
function calculation_salvage_values(final_year::Int64,
    current_year::Int64,
    lifetime::Int64)

    """
    
    """
    
    salvage_value = maximum([0, 1 - (final_year - current_year + 1)/lifetime])

    return salvage_value

end

#-------------------------------------------------------------------------------
function find_technology_highest_NPV(dict_technologies::Dict)

    """
    
    """

    # Initialize variables to store the best technology information
    max_npv = -Inf
    best_technology = nothing

    # Iterate over the dictionary to find the maximum NPV
    for (key, value) in dict_technologies

        if value > max_npv

            max_npv = value
            best_technology = key

        end

    end

    return best_technology

end

#-------------------------------------------------------------------------------
function find_max_label_technology(operating_technologies::Dict,
    name_alternative::String)

    """
    
    """
    
    # Initialize the dictionary 
    my_dic = Dict()

    # Selecting the right dictionary
    if name_alternative == "Nuclear" || name_alternative == "Coal" ||
        name_alternative == "CCGT" || name_alternative == "OCGT"

        # println("dispatchable")

        my_dic = operating_technologies["dispatchableGenerators"]

    elseif name_alternative == "Wind" || name_alternative == "Solar"

        # println("variable")

        my_dic = operating_technologies["variableGenerators"]

    end
    
    # Initialize variables to store the nuclear key with the highest number
    max_key = ""
    max_value = -Inf

    # Loop through the keys in my_dic dictionary
    for key in keys(my_dic)

        if startswith(key, name_alternative)

            # Extract the number after 'name_alternative_'
            number = parse(Int, split(key, '_')[2])

            if number > max_value

                max_value = number
                max_key = key

            end

        end

    end

    return max_value

end

################################################################################
#------------------------------MAIN FUNCTION------------------------------------
################################################################################
function investment_process!(vector_gencos::Vector{Agent},
    vector_technologies::Vector{Technology},
    vector_ownerships::Vector{SocialEdge},
    alternatives_technology::Dict,
    operating_technologies::Dict,
    time_series_years::XLSX.XLSXFile,
    temporal_resolution::Int64,
    representative_days::DataFrame,
    number_representative_days::Int64,
    value_of_lost_load::Float64,
    CO2_prices::DataFrame, # EUR / ton
    current_year::Int64,
    final_year::Int64)

    """
    
    """
  
    # Defensive programming: ensure gencos are willing to invest 
    gencos = vector_gencos 
    for genco in gencos
        genco.possibleRoles["investor"] = true
    end

    # Initialize external loop
    stop_condition = true    
    while stop_condition

        # Shuffle the order of generation companies to avoid first mover advantage
        gencos = shuffle(gencos)

        print("Number of gencos: ", length(gencos))

        # Iterate over the list of gencos
        for genco in gencos 
            print("Next genco gets to decide on investments now")          

            # Retrieving genco's properties 
            sight = genco.decisionMakingCriteria["sight"]            
            discount_rate = genco.economicProperties["discount_rate"]

            # Initializing dictionary to store the npv of the technologies 
            dic_NPV_technology = Dict{String, Float64}()

            # Initializing dictionary to store alternatives and their names 
            dic_alternative_names = Dict{String, String}()

            d = alternatives_technology 
            # iterate over the list of alternatives 
            for alternative in keys(d)
                print("Genco calculates profits for alternative $d now")  

                # Initalizing a dictionary containing the existing technologies and the new 
                # set of technologies 
                new_operating_technologies = deepcopy(operating_technologies) 

                # NOTE: TO BE REMOVED AFTER VERIFICATION
                #############################################
                # alternative = "Nuclear"                
                #############################################
                # println(alternative)
                # println(typeof(alternative))

                max_number_alternative = find_max_label_technology(operating_technologies,
                alternative)

                counter = max_number_alternative + 1
                
                name_alternative = string(alternative, "_$(counter)")

                # Update dictionary alternative names 
                dic_alternative_names[alternative] = name_alternative
                
                # Adds alternative to existing dictionary of technologies
                if alternative == "Nuclear" || alternative == "Coal" ||  
                   alternative == "CCGT" || alternative == "OCGT"

                   # new_operating_technologies["dispatchableGenerators"][name_alternative] = deepcopy(d[alternative])
                   new_operating_technologies["dispatchableGenerators"][name_alternative] = d[alternative]

                else # name_alternative == "Wind" || name_alternative = "Solar"

                   # new_operating_technologies["variableGenerators"][name_alternative] = deepcopy(d[alternative])
                   new_operating_technologies["variableGenerators"][name_alternative] = d[alternative]

                end

                # operating_technologies["dispatchableGenerators"][name_alternative]

                vector_cash_flows = Vector{Float64}() 
                year_difference = final_year - current_year  
                lifetime = d[alternative]["lifetime"]                          

                if year_difference >= sight

                    # Iterate over the number of years the genco see ahead
                    for year_sight in 1:sight

                        # NOTE: TO BE REMOVED AFTER VERIFICATION
                        #############################################
                        # year = 2020
                        #############################################
                        year = (current_year - 1) + year_sight
                        # println("YEAR")
                        # println(year)

                        cash_flow = calculation_profits(year, # [€]
                        time_series_years,
                        CO2_prices,
                        new_operating_technologies,
                        representative_days,
                        temporal_resolution, 
                        number_representative_days,
                        value_of_lost_load,
                        name_alternative,
                        alternative)      
                        
                        # println("CASH FLOW")
                        # println(cash_flow)

                        # Add the cash-flow to the vector of cash-flows
                        push!(vector_cash_flows, cash_flow)

                    end

                    # Calculate profits for the rest of the time horizon                    
                    if year_difference >= lifetime
                        
                        for i in (sight + 1):lifetime
        
                            # ASSUMPTION: it is assumed that the rest of cash flows are equal 
                            # to the last one calculated using genco's foresight
                            last_cash_flow = vector_cash_flows[end] # [€]

                            # println("LAST CASH FLOW")
                            # println(last_cash_flow)
        
                            # Add the cash-flow to the vector of cash-flows
                            push!(vector_cash_flows, last_cash_flow)                
        
                        end

                    else # year_difference < lifetime

                        for i in (sight + 1):year_difference
        
                            # ASSUMPTION: it is assumed that the rest of cash flows are equal 
                            # to the last one calculated using genco's foresight
                            last_cash_flow = vector_cash_flows[end] # [€]

                            # println("LAST CASH FLOW")
                            # println(last_cash_flow )
        
                            # Add the cash-flow to the vector of cash-flows
                            push!(vector_cash_flows, last_cash_flow)                
        
                        end

                    end
                    
                else # year_difference < sight

                    for year_sight in 1:year_difference

                        # NOTE: TO BE REMOVED AFTER VERIFICATION
                        #############################################
                        # year = 2020
                        #############################################
                        year = current_year + year_sight

                        cash_flow = calculation_profits(year, # [€]
                        time_series_years,
                        CO2_prices,
                        new_operating_technologies,
                        representative_days,
                        temporal_resolution, 
                        number_representative_days,
                        value_of_lost_load,
                        name_alternative,
                        alternative)

                        # println("CASH FLOW")
                        # println(cash_flow)
                        
                        # Add the cash-flow to the vector of cash-flows
                        push!(vector_cash_flows, cash_flow)

                    end

                end    

                # Extracting the investment cost of the alternative technology 
                investment_cost = extraction_investment_costs(alternative, # [€/MW]
                economic_drivers,
                current_year)
                
                # Calculating the total investment cost 
                if alternative == "Nuclear" || alternative == "Coal" ||  
                    alternative == "CCGT" || alternative == "OCGT"
 
                    max_cap = d[alternative]["maxPowerOutput"]    # [MW]
 
                else # name_alternative == "Wind" || name_alternative = "Solar"
 
                    max_cap = d[alternative]["installedCapacity"] # [MW]
 
                end

                total_investment_cost = investment_cost * max_cap # [€]
                
                # Calculation salvage value
                SV = calculation_salvage_values(final_year,
                current_year,
                lifetime)

                # Correcting the investment cost due to depreciation
                corrected_tot_inv_cost = (1 - SV) * total_investment_cost 
                
                # Calculate NPV 
                NPV_alternative = NPV_calculation(corrected_tot_inv_cost,
                vector_cash_flows, 
                discount_rate)

                # Storing the NPV calculation 
                dic_NPV_technology[alternative] = NPV_alternative
                
            end

            # Check that at least one technology exhibits NPV > 0 
            profitable_alternatives = filter(alternative -> dic_NPV_technology[alternative] > 0, keys(d))

            if length(profitable_alternatives) > 0

                # Select the alternative with highest NPV 
                best_technology = find_technology_highest_NPV(dic_NPV_technology)

                max_number_alternative = find_max_label_technology(operating_technologies,
                best_technology)

                number_next_alternative = max_number_alternative + 1

                # Creation new technology 
                my_list = creation_technology!(alternatives_technology,
                best_technology,
                number_next_alternative,
                genco,
                vector_technologies,
                vector_ownerships,
                current_year)
                
                vector_ownerships = my_list[3]
                vector_technologies = my_list[4]
                label = my_list[5]
                
                # Add plant to list of operating technologies
                operating_technologies = update_dic_operating_technologies!(operating_technologies,
                alternatives_technology,
                label,
                best_technology)

            # Finish the while loop 
            else # length(profitable_alternatives) <= 0

                # Update status of the investor 
                genco.possibleRoles["investor"] = false 
     
            end 

        end

        # gencos = vector_generation_companies
        # Determine if there are still investors with status = true 
        gencos = filter(genco -> genco.possibleRoles["investor"], gencos)

        if length(gencos) > 0

            stop_condition = true

        else

            stop_condition = false 

        end

    end

    return (vector_gencos, vector_technologies, vector_ownerships, 
    operating_technologies)

end 