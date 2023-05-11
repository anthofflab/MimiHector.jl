# --------------------------------------------------------
# Tropospheric Ozone Concentration and Radiative Forcing.
# --------------------------------------------------------

@defcomp rf_o3 begin

    O₃_0 = Parameter()             # Pre-industiral atmospheric tropospheric ozone concentration (DU O₃).
    CH₄ = Parameter(index=[time]) # Atmospheric methane concetration for current period (ppb).
    NOx_emissions = Parameter(index=[time]) # Nitrogen oxides emissions (Mt yr⁻¹).
    CO_emissions = Parameter(index=[time]) # Carbon monoxide emissions (Mt yr⁻¹).
    NMVOC_emissions = Parameter(index=[time]) # Non-methane volatile organic compound emissions (Mt yr⁻¹).

    O₃ = Variable(index=[time])  # Atmospheric concentration of tropospheric ozone (DU O₃).
    rf_O₃ = Variable(index=[time])  # Radiative forcing from tropospheric ozone (Wm⁻²).


    function run_timestep(p, v, d, t)

        if is_first(t)
            # Set ozone concentration to pre-indsutrial value.
            v.O₃[t] = p.O₃_0
            # Set initial ozone radiative forcing to 0.0.
            v.rf_O₃[t] = 0.0
        else
            # Calcualte atmospheric tropospheric ozone concentration.
            v.O₃[t] = (5.0 * log(p.CH₄[t])) + (0.125 * p.NOx_emissions[t]) + (0.0011 * p.CO_emissions[t]) + (0.0033 * p.NMVOC_emissions[t])
            # Calculate tropospheric ozone radiative forcing (re-scale forcing this way to make it relative to pre-industrial).
            v.rf_O₃[t] = (0.042 * v.O₃[t]) - (0.042 * v.O₃[TimestepIndex(1)])
        end
    end
end
