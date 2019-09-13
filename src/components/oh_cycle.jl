
@defcomp oh_cycle begin
    CNOX                = Parameter() #coefficient for NOX
    CCO                 = Parameter() #coefficient for CO
    CNMVOC              = Parameter() #coefficient for NMVOC
    CCH4                = Parameter() #coefficient for CH4
    NOX_emissions       = Parameter(index=[time]) # Global NOx emissions in Mt/yr
    CO_emissions        = Parameter(index=[time]) # Global CO emissions in Mt/yr
    NMVOC_emissions     = Parameter(index=[time]) # Global non-methane VOC emissions in Mt/yr
    CH4                 = Parameter(index=[time]) #Ch4 concentration ppbv in time t
    M0                  = Parameter() #CH4 pre-industrial concentrations, ppbv
    TOH0                = Parameter() #Initial OH lifetime (years)
    TOH                 = Variable(index=[time]) #Lifetime OH sink (years)

    function run_timestep(p, v, d, t)
        if is_first(t)
            v.TOH[t] = p.TOH0
    
        else
            #Ch4 contribution to OH lifetime
            a = p.CCH4 * (-1.0 * log(p.CH4[t-1]) + log(p.M0))
    
            #NOx contribution to OH lifetime
            b = p.CNOX * (-1.0 * p.NOX_emissions[t] + p.NOX_emissions[1])
    
            #CO contribution to OH lifetime
            c = p.CCO * (-1.0 * p.CO_emissions[t] + p.CO_emissions[1])
    
            #NMVOC contribution to OH lifetime
            d = p.CNMVOC * (-1.0 * p.NMVOC_emissions[t] + p.NMVOC_emissions[1])
    
            toh = a + b + c + d
    
            #Calculate lifetime of OH
            v.TOH[t] = p.TOH0 * exp(toh)
    
        end
    end
    
end
