# ------------------------------------------------------------------
# Straospheric Water Vapor from Methane Oxidation Radiative Forcing.
# ------------------------------------------------------------------

@defcomp rf_ch4h2o begin
    M0 = Parameter()             # Atmospheric methane pre-industrial concentration (ppb).
    H₂O_share = Parameter()             # Share of direct methane radiative forcing that represents stratospheric water vapor forcing from methane oxidation.
    CH4 = Parameter(index=[time]) # Atmospheric methane concetration for current period (ppb).

    rf_ch4h2o = Variable(index=[time])  # Radiative forcing for stratoshperic water vapor from methane oxidation (Wm⁻²)

    function run_timestep(p, v, d, t)

        # Stratospheric water vapor radiative forcing from methane oxidation.
        # "From Tanaka et al, 2007, but using Joos et al., 2001 value of 0.05."
        v.rf_ch4h2o[t] = p.H₂O_share * (0.036 * (sqrt(p.CH4[t]) - sqrt(p.M0)))
    end
end
