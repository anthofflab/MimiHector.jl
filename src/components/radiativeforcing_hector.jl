
@defcomp radiativeforcing begin
    rf_co2      = Parameter(index=[time])
    rf_aerosol  = Parameter(index=[time])
    rf_CH4      = Parameter(index=[time])
    rf_O3       = Parameter(index=[time])
    rf_ch4h2o   = Parameter(index=[time])
    rf_other    = Parameter(index=[time])
    alpha       = Parameter()
    rf          = Variable(index=[time])
end

function run_timestep(s::radiativeforcing, t::Int)
    v = s.Variables
    p = s.Parameters

    if t == 1
        v.rf[t] = 0.0
    else
        v.rf[t] = p.rf_co2[t]  + p.rf_CH4[t] + p.rf_O3[t] + p.rf_ch4h2o[t] + p.rf_other[t] + (p.alpha * p.rf_aerosol[t])
    end

end
