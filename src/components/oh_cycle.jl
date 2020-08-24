# --------------------------------------------------
# Tropospheric Methane Sink (OH) Lifetime.
# --------------------------------------------------

@defcomp oh_cycle begin
    CNOX                = Parameter()             # Hydroxyl lifetime coefficient for nitrogen oxides.
    CCO                 = Parameter()             # Hydroxyl lifetime coefficient for carbon monoxide.
    CNMVOC              = Parameter()             # Hydroxyl lifetime coefficient for non-methane volatile organic compounds.
    CCH4                = Parameter()             # Hydroxyl lifetime coefficient for methane.
    M0                  = Parameter()             # Pre-industrial atmospheric methane concentration (ppb).
    TOH0                = Parameter()             # Initial methane trpospheric lifetime due to OH (years).
    NOX_emissions       = Parameter(index=[time]) # Global nitrogen oxides emissions (Mt yr⁻¹).
    CO_emissions        = Parameter(index=[time]) # Global carbon monoxide emissions (Mt yr⁻¹).
    NMVOC_emissions     = Parameter(index=[time]) # Global non-methane volatile organic compound emissions (Mt yr⁻¹).
    CH4                 = Parameter(index=[time]) # Atmospheric methane concetration for current period (ppb).

    TOH                 = Variable(index=[time])  # Methane tropospheric lifetime due to OH (years).


    function run_timestep(p, v, d, t)

        if is_first(t)
            # Set initial lifetime value.
            v.TOH[t] = p.TOH0
        else
            # Methane contribution to OH lifetime.
            a = p.CCH4 * (-1.0 * log(p.CH4[t-1]) + log(p.M0))

            # NOx contribution to OH lifetime.
            b = p.CNOX * (-1.0 * p.NOX_emissions[t] + p.NOX_emissions[TimestepIndex(1)])

            # CO contribution to OH lifetime.
            c = p.CCO * (-1.0 * p.CO_emissions[t] + p.CO_emissions[TimestepIndex(1)])

            # NMVOC contribution to OH lifetime.
            d = p.CNMVOC * (-1.0 * p.NMVOC_emissions[t] + p.NMVOC_emissions[TimestepIndex(1)])

            # Change in tropospheric OH abundance.
            toh = a + b + c + d

            # Calculate tropospheric lifetime of methane conditional on OH abundance.
            v.TOH[t] = p.TOH0 * exp(toh)
        end
    end
end
