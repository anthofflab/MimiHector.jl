
@defcomp rfo3hector begin
    O3          = Parameter(index=[time]) # Concentration tropospheric ozone
    rf_O3_base       = Variable(index=[time]) # unnormalized radiative forcing for tropospheric ozone
    rf_O3       = Variable(index=[time]) # radiative forcing for tropospheric ozone

    function run_timestep(p, v, d, t)
        #Calculate  radiative forcing
        v.rf_O3_base[t] = 0.042 * p.O3[t]
    
        # Need to re-scale this set-up to be relative to pre-industiral
        v.rf_O3[t] = v.rf_O3_base[t] - v.rf_O3_base[1]
    end
    
end
