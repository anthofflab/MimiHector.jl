using Test
using CSVFiles
using DataFrames
using Mimi

include("../src/MimiHECTOR.jl")
@testset "Hector" begin

#------------------------------------------------------------------------------
#   1. Carry out test to check the model runs.
#------------------------------------------------------------------------------

    @testset "Hector-model" begin

    m = MimiHECTOR.get_hectorch4()
    run(m)

    end # FAIR model run test.

#------------------------------------------------------------------------------
#   2. Carry out tests to make sure Mimi-HectorCH4 matches the C++ version.
#------------------------------------------------------------------------------

    @testset "Hector-C++" begin

    # The Hector output file has rounded values (nearest decimal for values < 1000, and nearest integer for values > 1000).
    # It also runs for a different time period (1746-2300). Both issues affect the degree of precision for comparing results.

    # Load comparison data from Hector.
    hector_data = DataFrame(load(joinpath(@__DIR__, "..", "data", "validation_data", "hector_sample_outputstream_rcp85.csv"), skiplines_begin=1))

    # Crop data to default Mimi-HectorCH4 period (1765-2300).
    hector_data = hector_data[hector_data.year .>= 1765, :]

    # Isolate results for atmospheric methane concentration and tropospheric lifetime (due to hydroxyl radical).
    hector_CH₄ = hector_data[hector_data.variable .== "CH4", :value]
    hector_τ   = hector_data[hector_data.variable .== "TAU_OH", :value]

    # Set precision levels for atmospheric carbon dioxide (ppb) and methane's tropospheric lifetime (years).
    Precision_CH₄ = 0.6
    Precision_τ = 0.006

    # Get an instance of Mimi-HectorCH4
    m = MimiHECTOR.get_hectorch4(rcp_scenario = "RCP85", start_year = 1765, end_year = 2300)

    # The Hector validation data corresponds to different time periods, so need to change some parameters for Mimi-Hector to match up.
    # These reprsent the 1765 results from the Hector output data (these differ from default Hector parameter settings).
    set_param!(m, :oh_cycle,  :TOH0, 6.586)
    set_param!(m, :oh_cycle,  :M0, 648.7)
    set_param!(m, :ch4_cycle, :M0, 648.7)

    run(m)

    # Run tests for global temperature anomaly and atmospheric CO₂ concentrations.
    @test maximum(abs, m[:ch4_cycle, :CH4] .- hector_CH₄) ≈ 0.0 atol = Precision_CH₄
    @test maximum(abs, m[:oh_cycle, :TOH]  .- hector_τ)   ≈ 0.0 atol = Precision_τ

    end # Hector C++ comparison test.
end # All Hector tests.
