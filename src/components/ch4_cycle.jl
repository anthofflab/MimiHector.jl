# --------------------------------------------------
# Methane cycle.
# --------------------------------------------------

@defcomp ch4_cycle begin

    UC_CH4 = Parameter()             # Tg of methane to ppb unit conversion between emissions and concentrations (1 Teragram = 1 Megatonne).
    CH4N = Parameter()             # Natural methane emissions (Tgrams).
    Tsoil = Parameter()             # Methane loss to soil (years).
    Tstrat = Parameter()             # Methane loss to stratosphere (years).
    M0 = Parameter()             # Atmospheric methane pre-industrial concentration (ppb).
    CH4_emissions = Parameter(index=[time]) # Global anthropogenic methane emissions (Mt yr⁻¹).
    TOH = Parameter(index=[time]) # Methane loss to hydroxyl radical in troposphere (years).

    emisTocon = Variable(index=[time])  # Emissions to concentrations conversion result.
    dCH4 = Variable(index=[time])  # Change in atmospheric methane concentrations (ppb).
    CH4 = Variable(index=[time])  # Atmospheric methane concetration for current period (ppb).


    function run_timestep(p, v, d, t)

        # Set initial conditions.
        if is_first(t)
            v.emisTocon[t] = 0.
            v.dCH4[t] = 0.
            v.CH4[t] = p.M0
        else
            # Convert total emissions (anthropogenic and natural) to concentrations.
            v.emisTocon[t] = (p.CH4_emissions[t] + p.CH4N) / p.UC_CH4

            # Calculate change in CH₄ concentrations after accounting for stratospheric, soil, and tropospheric (OH) sinks.
            v.dCH4[t] = v.emisTocon[t] - (v.CH4[t-1] / p.Tsoil) - (v.CH4[t-1] / p.Tstrat) - (v.CH4[t-1] / p.TOH[t])

            # Calculate atmospheric concentration of CH₄.
            v.CH4[t] = v.CH4[t-1] + v.dCH4[t]
        end
    end

end
