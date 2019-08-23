
@defcomp o3cyclehector begin
    CH4             = Parameter(index=[time])   #Ch4 concentration ppbv in time t
    NOX_emissions   = Parameter(index=[time])   #Global NOx emissions in Mt/yr
    CO_emissions    = Parameter(index=[time])   #Global CO emissions in Mt/yr
    NMVOC_emissions = Parameter(index=[time])   #Global non-methane VOC emissions in Mt/yr
    PO3             = Parameter()               #Pre-industiral Ozone
    O3              = Variable(index=[time])    #Concentration tropospheric ozone

end

function run_timestep(s::o3cyclehector, t::Int)
    v = s.Variables
    p = s.Parameters

    if t==1
        v.O3[t] = p.PO3
    else
        v.O3[t] = (5.0 * log(p.CH4[t])) + (0.125 * p.NOX_emissions[t]) + (0.0011 * p.CO_emissions[t]) + (0.0033 * p.NMVOC_emissions[t])
    end
end
