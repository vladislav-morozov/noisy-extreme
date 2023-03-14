function varN = noisyEndpoint_InfiniteEndpointVariance(beta )
% noisyEndpoint_FiniteEndpointPowerInverse Computes the variance of an RV
% from two-sided power tail CDF

    varN =  2./(beta.^2-3.*beta+2);
end