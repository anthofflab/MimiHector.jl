
@defcomp rfch4h2ohector begin
    M0              = Parameter() #CH4 pre-industrial concentrations, ppbv
    CH4             = Parameter(index=[time]) #Ch4 concentration ppbv in time t
    rf_ch4h2o       = Variable(index=[time]) #Absolute radiative forcing for stratoshperic H2O from CH4 oxidation
    rf_ch4h2o_rel   = Variable(index=[time]) #Make forcing relative to base year
    H₂O_share       = Parameter() # Share of direct CH₄ forcing used to estimate stratospheric water vapor forcing due to CH₄ oxidation. (0.12 for etminan forcing equations)
end

function run_timestep(s::rfch4h2ohector, t::Int)
    v = s.Variables
    p = s.Parameters

    #Stratospheric H2O from CH4 oxidation
    #From Tanaka et al, 2007, but using Joos et al., 2001 value of 0.05

    #Calculate absolute radiative forcing
    v.rf_ch4h2o[t] = p.H₂O_share * (0.036 * (sqrt(p.CH4[t]) - sqrt(p.M0)))

end
