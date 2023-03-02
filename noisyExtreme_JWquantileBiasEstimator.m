function tauCorrected=noisyExtreme_JWquantileBiasEstimator(tau, noisyThetaS, Vest, T)
% noisyExtreme_JWquantileBiasEstimator Computes the analytical bias
% correction of Jochmans, Weidner (2019)

    N = length(noisyThetaS);
    x = quantile(noisyThetaS, tau);
    h = T^(-1/2);
    K = noisyExtreme_gaussianKernelDerivative((noisyThetaS-x)/h);
    bf= -(N*h^2)^(-1)*Vest'*K/2;
    tauCorrected= max(min(tau + bf/T, 1), 0);
    
    
end