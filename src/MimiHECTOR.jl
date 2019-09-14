module MimiHECTOR

using Mimi
using DataFrames
using CSVFiles

include("components/ch4_cycle.jl")
include("components/oh_cycle.jl")
include("components/rf_ch4h2o.jl")
include("components/rf_ch4.jl")
include("components/rf_o3.jl")


export get_hectorch4

function get_hectorch4(;rcp_scenario::String="RCP85", start_year::Int64=1765, end_year::Int64=2300)

    # ---------------------------------------------
    # Load and clean up necessary data.
    # ---------------------------------------------

    # Load RCP emissions and concentration scenario values (RCP options = "RCP26", "RCP45", "RCP60", and "RCP85").
    rcp_emissions      = DataFrame(load(joinpath(@__DIR__, "..", "data", "model_data", rcp_scenario*"_EMISSIONS.csv"), skiplines_begin=36))
    rcp_concentrations = DataFrame(load(joinpath(@__DIR__, "..", "data", "model_data", rcp_scenario*"_CONCENTRATIONS.csv"), skiplines_begin=37))

    # Set initial CH₄ and N₂O concentrations to RCP 1765 values.
    CH₄_0 = rcp_concentrations[1, :CH4]
    N₂O_0 = rcp_concentrations[1, :N2O]

    # Find indices for start and end years to crop emissions scenario to correct time frame.
    start_index, end_index = findall((in)([start_year, end_year]), rcp_emissions.YEARS)
    rcp_emissions = rcp_emissions[start_index:end_index, :]

	# ---------------------------------------------
    # Initialize Mimi model.
    # ---------------------------------------------

    # Create a Mimi model.
    m = Model()

    # Set time index.
    set_dimension!(m, :time, start_year:end_year)

    # ---------------------------------------------
    # Add components to model.
    # ---------------------------------------------
    add_comp!(m, oh_cycle)
    add_comp!(m, ch4_cycle)
    add_comp!(m, rf_ch4)
    add_comp!(m, rf_ch4h2o)
    add_comp!(m, rf_o3)

    # ---------------------------------------------
    # Set component parameters.
    # ---------------------------------------------

    # ---- Tropospheric Sink (OH) Lifetime ---- #
    set_param!(m, :oh_cycle, :CNOX, 0.0042)
    set_param!(m, :oh_cycle, :CCO, -0.000105)
    set_param!(m, :oh_cycle, :CNMVOC, -0.000315)
    set_param!(m, :oh_cycle, :CCH4, -0.32)
    set_param!(m, :oh_cycle, :NOX_emissions, rcp_emissions.NOx)
    set_param!(m, :oh_cycle, :CO_emissions, rcp_emissions.CO)
    set_param!(m, :oh_cycle, :NMVOC_emissions, rcp_emissions.NMVOC)
    set_param!(m, :oh_cycle, :TOH0, 6.586)
    set_param!(m, :oh_cycle, :M0, CH₄_0)

    # ---- Methane Cycle ---- #
    set_param!(m, :ch4_cycle, :UC_CH4, 2.78)
    set_param!(m, :ch4_cycle, :CH4N, 300.)
    set_param!(m, :ch4_cycle, :Tsoil, 160.)
    set_param!(m, :ch4_cycle, :Tstrat, 120.)
    set_param!(m, :ch4_cycle, :M0, CH₄_0)
    set_param!(m, :ch4_cycle, :CH4_emissions, rcp_emissions.CH4)

    # ---- Methane Radiative Forcing ---- #
    set_param!(m, :rf_ch4, :N₂O_0, N₂O_0)
    set_param!(m, :rf_ch4, :CH4_0, CH₄_0)
    set_param!(m, :rf_ch4, :scale_CH₄, 1.0)

    # ---- Straospheric Water Vapor From Methane Radiative Forcing ---- #
    set_param!(m, :rf_ch4h2o, :M0, CH₄_0)
    set_param!(m, :rf_ch4h2o, :H₂O_share, 0.05)

    # ---- Tropospheric Ozone Radiative Forcing ---- #
    set_param!(m, :rf_o3, :O₃_0, 32.38)
    set_param!(m, :rf_o3, :NOx_emissions, rcp_emissions.NOx)
    set_param!(m, :rf_o3, :CO_emissions, rcp_emissions.CO)
    set_param!(m, :rf_o3, :NMVOC_emissions, rcp_emissions.NMVOC)

    # ---------------------------------------------
    # Create connections between Mimi components.
    # ---------------------------------------------
    connect_param!(m, :oh_cycle, :CH4, :ch4_cycle, :CH4)
    connect_param!(m, :ch4_cycle, :TOH, :oh_cycle, :TOH)
    connect_param!(m, :rf_o3, :CH₄, :ch4_cycle, :CH4)
    connect_param!(m, :rf_ch4h2o, :CH4, :ch4_cycle, :CH4)
    connect_param!(m, :rf_ch4, :CH4, :ch4_cycle, :CH4)

    return m
end

end #module
