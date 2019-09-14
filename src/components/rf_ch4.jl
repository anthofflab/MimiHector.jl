# -------------------------------------------------------
# Radiative forcing from methane (Etminan 2016 equations)
# -------------------------------------------------------

# Create a function 'interact' to account for the overlap in methane and nitrous oxide in their radiative absoprtion bands.
function interact(M, N)
    d = 1.0 + (M * N)^0.75 * 2.01E-5 + (M * N)^1.52 * M * 5.31E-15
    return 0.47 * log(d)
end

@defcomp rf_ch4 begin
    N₂O_0     = Parameter()             # Pre-industrial atmospheric nitrous oxide concentration (ppb).
    CH4_0     = Parameter()             # Pre-industrial atmospheric methane concentration (ppb).
    scale_CH₄ = Parameter()             # Scaling factor for uncertainty in methane radiative forcing.
    CH4       = Parameter(index=[time]) # Atmospheric methane concentration (ppb).

    rf_CH4    = Variable(index=[time])  # Direct forcing from atmospheric methane concentrations (Wm⁻²).

    function run_timestep(p, v, d, t)

        # Direct methane radiative forcing.
        v.rf_CH4[t] = (0.036 * (sqrt(p.CH4[t]) - sqrt(p.CH4_0)) - (interact(p.CH4[t], p.N₂O_0) - interact(p.CH4_0, p.N₂O_0))) * p.scale_CH₄
    end
end
