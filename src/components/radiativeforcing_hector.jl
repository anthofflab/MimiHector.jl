
@defcomp radiativeforcing begin
    rf_co2      = Parameter(index=[time])
    rf_aerosol  = Parameter(index=[time])
    rf_CH4      = Parameter(index=[time])
    rf_O3       = Parameter(index=[time])
    rf_ch4h2o   = Parameter(index=[time])
    rf_other    = Parameter(index=[time])
    alpha       = Parameter()
    rf          = Variable(index=[time])

    function run_timestep(p, v, d, t)
        if is_first(t)
            v.rf[t] = 0.0
        else
            v.rf[t] = p.rf_co2[t]  + p.rf_CH4[t] + p.rf_O3[t] + p.rf_ch4h2o[t] + p.rf_other[t] + (p.alpha * p.rf_aerosol[t])
        end
    
    end
    
end
