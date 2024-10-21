# LOADING OTHER FUNCTIONS, SCRIPTS, OR PACKAGES
#-------------------------------------------------------------------------------
using CSV, DataFrames, YAML
using JuMP, Gurobi

# AUXILIARY FUNCTIONS
#-------------------------------------------------------------------------------
# Step 2a: create sets
function define_sets!(m::Model, 
    data::Dict, 
    temporal_resolution::Int64,
    number_representative_days::Int64)

    m.ext[:sets] = Dict()

    # Time steps
    JH = m.ext[:sets][:JH] = 1:temporal_resolution

    # Representative days
    JD = m.ext[:sets][:JD] = 1:number_representative_days

    # Dispatchable generators per type
    # IDtype = m.ext[:sets][:IDtype] = [id for id in keys(data["dispatchableGenerators"])]
    ID = m.ext[:sets][:ID] = [id for id in keys(data["dispatchableGenerators"])]

    # Variable generators
    IV = m.ext[:sets][:IV] = [iv for iv in keys(data["variableGenerators"])]

    # All variable and dispatchable generators, per unit
    I = m.ext[:sets][:I] = union(m.ext[:sets][:IV],m.ext[:sets][:ID])

    # return model
    return m

end

#-------------------------------------------------------------------------------
# Step 2b: add time series
function process_time_series_data!(m::Model, 
    ts::DataFrame,
    temporal_resolution::Int64)
    
    # extract the relevant sets
    IV = m.ext[:sets][:IV] # Variable generators 
    JH = m.ext[:sets][:JH] # Time steps
    JD = m.ext[:sets][:JD] # Days
    
    # create dictionary to store time series
    m.ext[:timeseries] = Dict()
    m.ext[:timeseries][:AF] = Dict()

    # add time series to dictionary
    m.ext[:timeseries][:D] = [ts.Load[jh+temporal_resolution*(jd-1)] for jh in JH, jd in JD]
    
    # Adding capacity factors to wind and solar technologies 
    for IV_type in IV

        if IV_type[1:4] == "Wind"

            # IV_type = "Wind"
            m.ext[:timeseries][:AF][IV_type] = [ts.LFW[jh+temporal_resolution*(jd-1)] for jh in JH, jd in JD]

        elseif IV_type[1:5] == "Solar"

            # IV_type = "Solar"
            m.ext[:timeseries][:AF][IV_type] = [ts.LFS[jh+temporal_resolution*(jd-1)] for jh in JH, jd in JD]

        end

    end
    
    # return model
    return m

end

#-------------------------------------------------------------------------------
# step 2c: process input parameters
function process_parameters!(m::Model, 
    data::Dict, 
    repr_days::DataFrame,
    value_of_lost_load::Float64,
    CO2_price::Float64)
    
    # extract sets
    ID = m.ext[:sets][:ID]
    IV = m.ext[:sets][:IV]
    
    # Create parameter dictonary
    m.ext[:parameters] = Dict()

    # basic parameters
    m.ext[:parameters][:αCO2] = CO2_price # EUR / ton
    m.ext[:parameters][:VOLL] = value_of_lost_load # VOLL
    m.ext[:parameters][:W] = repr_days.Weights
   
    # parameters of dispatchable generators per unit
    d = data["dispatchableGenerators"]
    ϵmax = m.ext[:parameters][:ϵmax] = Dict(i => d[i]["effmax"] for i in ID)
    ϵmin = m.ext[:parameters][:ϵmin] = Dict(i => d[i]["effmin"] for i in ID)
    Gmax = m.ext[:parameters][:GmaxD] = Dict(i => d[i]["maxPowerOutput"] for i in ID)
    Gmin = m.ext[:parameters][:GminD] = Dict(i => d[i]["minStableOperatingPoint"] for i in ID)
    fuelcost = m.ext[:parameters][:fuelcost] = Dict(i => d[i]["fuelcost"] for i in ID)
    carbonintensity = m.ext[:parameters][:carbonintensity] = Dict(i => d[i]["carbonintensity"] for i in ID)

    # compute parameters model:
    m.ext[:parameters][:α] = Dict(i => fuelcost[i]/ϵmin[i]*Gmin[i] for i in ID) #  fuel cost at min stable operating point
    m.ext[:parameters][:β] = Dict(i => (fuelcost[i]/ϵmax[i]*Gmax[i] -  fuelcost[i]/ϵmin[i]*Gmin[i])/(Gmax[i]-Gmin[i]) for i in ID) # Marginal fuel cost €/Mwh
    m.ext[:parameters][:βbar] = Dict(i => fuelcost[i]/ϵmax[i] for i in ID) # average fuel cost  EUR/MWh electricity
    m.ext[:parameters][:γ] = Dict(i => carbonintensity[i]/ϵmin[i]*Gmin[i] for i in ID) #  fuel cost at min stable operating point
    m.ext[:parameters][:δ] = Dict(i => (carbonintensity[i]/ϵmax[i]*Gmax[i] -  carbonintensity[i]/ϵmin[i]*Gmin[i])/(Gmax[i]-Gmin[i]) for i in ID) # Marginal fuel cost €/Mwh
    m.ext[:parameters][:δbar] = Dict(i => carbonintensity[i]/ϵmax[i] for i in ID) # average emissions cost  tCO2/MWh electricity
    
    # parameters of variable generators
    d = data["variableGenerators"]
    m.ext[:parameters][:GmaxV] = Dict(i => d[i]["installedCapacity"] for i in IV)

    # return model
    return m

end

#-------------------------------------------------------------------------------
## Step 3: construct your model
function build_basic_ED_model!(m::Model)
    
    # Clear m.ext entries "variables", "expressions" and "constraints"
    m.ext[:variables] = Dict()
    m.ext[:expressions] = Dict()
    m.ext[:constraints] = Dict()

    # Extract sets
    I = m.ext[:sets][:I]
    ID = m.ext[:sets][:ID]
    IV = m.ext[:sets][:IV]
    JH = m.ext[:sets][:JH]
    JD = m.ext[:sets][:JD]

    # Extract time series data
    D = m.ext[:timeseries][:D]
    AF = m.ext[:timeseries][:AF]

    # Extract parameters
    W = m.ext[:parameters][:W] # Weight of the representative days
    αCO2 = m.ext[:parameters][:αCO2]
    VOLL = m.ext[:parameters][:VOLL]
    βbar = m.ext[:parameters][:βbar]
    δbar = m.ext[:parameters][:δbar]
    GmaxD = m.ext[:parameters][:GmaxD]
    GmaxV = m.ext[:parameters][:GmaxV]

    # create variables
    g = m.ext[:variables][:g] = @variable(m, [i=I,jh=JH, jd=JD], lower_bound=0, base_name="generation")
    ens =  m.ext[:variables][:ens] = @variable(m, [jh=JH, jd=JD], lower_bound=0, base_name="load_shedding")

    # Create affine expressions (= linear combinations of variables)
    # Fuel costs
    fcd = m.ext[:expressions][:fcd] = @expression(m, [i=ID,jh=JH, jd=JD],
        βbar[i] * g[i,jh,jd]
    )
    # CO2 costs
    ccd = m.ext[:expressions][:ccd] = @expression(m, [i=ID,jh=JH, jd=JD],
        αCO2 * δbar[i] * g[i,jh, jd]
    )

    # Objective
    obj = m.ext[:objective] = @objective(m, Min,
        + sum(W[jd] * fcd[i,jh,jd] + ccd[i,jh,jd] for i in ID, jh in JH, jd in JD)
        + sum(W[jd] * ens[jh,jd] * VOLL for jh in JH, jd in JD)
    )

    # Constraints
    # Power balance
    con2a = m.ext[:constraints][:con2a] = @constraint(m, [jh=JH, jd=JD],
        sum(g[i,jh,jd] for i in I) == D[jh,jd] - ens[jh,jd]
    )
    # Load shedding < demand
    con2c = m.ext[:constraints][:con2c] = @constraint(m, [jh=JH, jd=JD],
        ens[jh, jd] <= D[jh,jd]
    )
    # Generation < Installed capacity, thermal generators
    con3a1 = m.ext[:constraints][:con3a1] = @constraint(m, [i=ID,jh=JH,jd=JD],
        g[i,jh,jd] <= GmaxD[i]
    )
    # Generation < Installed capacity, renewable generators
    con3a2 = m.ext[:constraints][:con3a2] = @constraint(m, [i=IV,jh=JH,jd=JD],
        g[i,jh,jd] <= AF[i][jh,jd] * GmaxV[i]
    )

    # return model
    return m

end

################################################################################
#------------------------------MAIN FUNCTION------------------------------------
################################################################################
function economic_dispatch(data::Dict,
    ts::DataFrame,
    repr_days::DataFrame,
    temporal_resolution::Int64,
    number_representative_days::Int64,
    value_of_lost_load::Float64,
    CO2_price::Float64)
    
    """
    
    """

    # Creation of the object model
    m = Model(optimizer_with_attributes(Gurobi.Optimizer))
    
    set_optimizer_attribute(m, "OutputFlag",0)
    
    # call functions
    define_sets!(m, 
    data, 
    temporal_resolution,
    number_representative_days)

    process_time_series_data!(m, 
    ts,
    temporal_resolution)
        
    process_parameters!(m, 
    data,
    repr_days,
    value_of_lost_load,
    CO2_price)
    
    # Build your model
    build_basic_ED_model!(m)
        
    # Solve the model
    optimize!(m)
    
    # check termination status
    print(
    """
    
    Termination status: $(termination_status(m))
    
    """
    )
    
    # Print relevant output
    # Sets
    JD = m.ext[:sets][:JD] # set of representative days
    JH = m.ext[:sets][:JH] # set of hours per day
    I = m.ext[:sets][:I]
    ID = m.ext[:sets][:ID]
    
    # Objective function 
    fobj = value.(m.ext[:objective]) # Objective function

    # Parameters
    Dmat = m.ext[:timeseries][:D]
    W = m.ext[:parameters][:W] # Weight of the representative days
    # Dvec = D[:,1]

    # Extracting values variables/expressions
    fcd = value.(m.ext[:expressions][:fcd])
    ccd = value.(m.ext[:expressions][:ccd])
    g = value.(m.ext[:variables][:g])
    λ = dual.(m.ext[:constraints][:con2a])

    # Calculation fuel costs during the year
    dic_fuel_costs = Dict(i => [W[jd] * fcd[i,jh,jd] for jh in JH, jd in JD] for i in ID)

    # Calculation emission costs during the year 
    dic_emission_costs = Dict(i => [W[jd] * ccd[i,jh,jd] for jh in JH, jd in JD] for i in ID)

    # Electricity generation per technology during the year
    dic_electricity_generation = Dict(i => [W[jd] * g[i,jh,jd] for jh in JH, jd in JD] for i in I)

    # Electricity prices during the year
    λmat = [λ[jh,jd] for jh in JH, jd in JD]

    return (fobj, dic_fuel_costs, dic_emission_costs, dic_electricity_generation, λmat)

end