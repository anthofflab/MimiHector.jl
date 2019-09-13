# --------------------------------------------------
# Ozone concentration and radiative forcing.
# --------------------------------------------------

@defcomp rf_o3 begin

    CH₄             = Parameter(index=[time])   # Atmosperhic methane concentration (ppb).
    NOx_emissions   = Parameter(index=[time])   #Global NOx emissions in Mt/yr
    CO_emissions    = Parameter(index=[time])   #Global CO emissions in Mt/yr
    NMVOC_emissions = Parameter(index=[time])   #Global non-methane VOC emissions in Mt/yr
    PO3             = Parameter()               #Pre-industiral Ozone
    O₃              = Variable(index=[time])    #Concentration tropospheric ozone
    rf_O₃       = Variable(index=[time]) # radiative forcing for tropospheric ozone


    function run_timestep(p, v, d, t)

    	if is_first(t)
    		# Set Ozone concentration to pre-indsutrial value.
    		v.O₃[t] = p.O₃_0
    		# Set O₃ radiative forcing relative to pre-industrial.
    		v.rf_O₃ = 0.0
    	else
    		# Calcualte tropospheric O₃ concentration.
    		v.O₃[t] = (5.0 * log(p.CH₄[t])) + (0.125 * p.NOx_emissions[t]) + (0.0011 * p.CO_emissions[t]) + (0.0033 * p.NMVOC_emissions[t])
    		#Calculate O₃ radiative forcing, scaled to be relative to pre-indsutrial (i.e. period 1)
	        v.rf_O₃[t] = (0.042 * p.O₃[t]) - (0.042 * p.O₃[1])
        end
    end
end
