# LOADING OTHER FUNCTIONS, SCRIPTS, OR PACKAGES
#-------------------------------------------------------------------------------


# AUXILIARY FUNCTIONS
#-------------------------------------------------------------------------------


################################################################################
#------------------------------MAIN FUNCTION------------------------------------
################################################################################
function NPV_calculation(investment_cost::Float64,
    cash_flows::Vector{Float64},
    discount_rate::Float64)

    """
    
    """

    #EAC = (investment_cost*discount_rate)/(1-(1+discount_rate)^lifetime)
    npv = -investment_cost
    for t in 1:(length(cash_flows))
        #npv += (cash_flows[t] -EAC) / (1 + discount_rate)^(t)
        npv += cash_flows[t] / (1 + discount_rate)^(t)
    end

    return npv

end

# Example 
# function calculate_npv(cash_flows, discount_rate)
#     npv = 0.0
#     for (t, cash_flow) in enumerate(cash_flows)

#         println("t")
#         println(t)
#         println("cash_flow")
#         println(cash_flow)

#         npv += cash_flow / (1 + discount_rate)^(t - 1)

#     end

#     return npv

# end

# # Example data
# cash_flows = [-1000, 300, 400, 500]  # Initial investment and future cash flows
# discount_rate = 0.10

# # Calculate NPV
# npv = calculate_npv(cash_flows, discount_rate)
# println("NPV: \$$(round(npv, digits=2))")
