# LOADING OTHER FUNCTIONS, SCRIPTS, OR PACKAGES
#-------------------------------------------------------------------------------
using XLSX
using DataFrames

# AUXILIARY FUNCTIONS
#-------------------------------------------------------------------------------



################################################################################
#------------------------------MAIN FUNCTION------------------------------------
################################################################################
function data_wrangling(time_series_years::XLSX.XLSXFile,
    CO2_prices::DataFrame, # EUR / ton
    year::Int64)

    """
    
    """

    # Specify the sheet name
    sheet_name = string(year)

    # Extract the data from the sheet and convert it into a DataTable 
    sheet = XLSX.gettable(time_series_years[sheet_name])
       
    # Convert the DataTable to a DataFrame
    time_series = DataFrame(sheet)     
       
    # Selecting the CO2 price based on the year 
    df = CO2_prices
    CO2_price = df.CO2_Price[df.Year .== year][1]

    return (time_series, CO2_price) 

end