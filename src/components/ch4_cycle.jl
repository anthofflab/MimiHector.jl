
@defcomp ch4_cycle begin
    UC_CH4          = Parameter() #Tg(CH4)/ppb unit conversion between emissions and concentrations Note:(1 Teragram = 1 Megatonne)
    CH4N            = Parameter() #Natural CH4 emissions (Tgrams)
    Tsoil           = Parameter() #Ch4 loss to soil (years)
    Tstrat          = Parameter() #CH4 loss to stratosphere (years)
    M0              = Parameter() #CH4 pre-industrial concentrations, ppbv
    CH4_emissions   = Parameter(index=[time]) # Global anthropogenic CH4 emissions in Mt/yr
    TOH             = Parameter(index=[time]) #CH4 loss to OH (years)
    emisTocon       = Variable(index=[time]) #Emissions to concentrations
    dCH4            = Variable(index=[time]) #Change in CH4 concentrations
    CH4             = Variable(index=[time]) #Atmospheric concetration of CH4

    function run_timestep(p, v, d, t)
        if is_first(t)
            v.emisTocon[t] = 0.
            v.dCH4[t] = 0.
            v.CH4[t] = p.M0
    
        else
            #Calculate total emissions (anthropogenic and natural) as concentrations
            v.emisTocon[t] = (p.CH4_emissions[t] + p.CH4N) / p.UC_CH4
    
            #Calculate change in CH4 concentrations after accounting for strat, soil, and OH sinks.
            v.dCH4[t] = v.emisTocon[t] - (v.CH4[t-1]/p.Tsoil) - (v.CH4[t-1]/p.Tstrat) - (v.CH4[t-1]/p.TOH[t])
    
            #Calculate atmospheric concentration of CH4
            v.CH4[t] = v.CH4[t-1] + v.dCH4[t]
        end
    end
    
end
