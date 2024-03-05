# Monte Carlo simulations:
"""
    analyze(Problem::ReliabilityProblem, AnalysisMethod::MCS)

The function solves the provided reliability problem using Monte Carlo simulations.
"""
function analyze(Problem::ReliabilityProblem, AnalysisMethod::MCS)
    # Extract the analysis details:
    NumSamples          = AnalysisMethod.NumSamples
    SamplingTechnique   = AnalysisMethod.SamplingTechnique

    # Extract data:
    g   = Problem.g
    X   = Problem.X
    ρˣ  = Problem.ρˣ

    # If the marginal distrbutions are correlated, define a Nataf object:
    NatafObject = NatafTransformation(X, ρˣ)

    # Generate samples:
    if !isa(SamplingTechnique, ITS) && !isa(SamplingTechnique, LHS)
        error("Invalid sampling technique.")
    else
        XSamples, _, _ = samplerv(NatafObject, NumSamples, SamplingTechnique)
    end

    # Clean up the generated samples:
    XSamplesClean = eachrow(XSamples)
    XSamplesClean = Vector.(XSamplesClean)

    # Evaluate the limit state function at the generate samples:
    gSamples = g.(XSamplesClean)

    # Compute the probability of failure:
    PoF = count(x -> x ≤ 0, gSamples) / NumSamples

    # Return results:
    return MCSCache(XSamples, PoF)
end