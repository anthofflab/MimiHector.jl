
@defcomp rfch4hector begin
    N₂O_0              = Parameter() #preindustrial nitrous oxide, ppbv
    CH4_0              = Parameter() #CH4 pre-industrial concentrations, ppbv
    CH4             = Parameter(index=[time]) #Ch4 concentration ppbv in time t
    scale_CH₄ = Parameter() #Scaling factor for uncertainty in RF (following FAIR 1.3 approach)
    rf_CH4          = Variable(index=[time]) #direct radiative forcing for methane
end

#The function 'interact' accounts for the overlap in CH4 and N2O in their absoprtion bands
function interact(M, N)
    d = 1.0 + (M * N)^0.75 * 2.01E-5 + (M * N)^1.52 * M * 5.31E-15
    return 0.47 * log(d)
end

function run_timestep(s::rfch4hector, t::Int)
    v = s.Variables
    p = s.Parameters

    #Calculate direct radiative forcing
    v.rf_CH4[t] = (0.036 * (sqrt(p.CH4[t]) - sqrt(p.CH4_0)) - (interact(p.CH4[t], p.N₂O_0) - interact(p.CH4_0, p.N₂O_0))) * p.scale_CH₄
end
