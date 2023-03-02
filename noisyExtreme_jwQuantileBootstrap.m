function jwQ = noisyExtreme_jwQuantileBootstrap(noisyThetaS, Vest, T, tau, alphaCI, B)
% noisyExtreme_jwQuantileBootstrap Returns 1-alpha boostrap confidence
% interval for the JW estimator.
% Inputs: 1. noisyThetaS -- estimates of individual effects
%         2. vEst -- estimates of variance of thetas, same order
%         3. T -- size of individual samples
%         4. tau -- row vector of quantiles of interest
%         5. alpha -- CI parameter
%         6. B -- number of bootstrap samples to draw
% Ouputs: 1 jwQ -- 2x|tau| matrix of (alpha) and (1-alpha)th bootstrap
%           quantiles

    N = length(noisyThetaS);
    jwB = zeros(B, length(tau));
    for b=1:B
        
        % draw boostrap sample
        bSampleInd = randi(N, N, 1);
        bSample = noisyThetaS(bSampleInd);
        vB = Vest(bSampleInd);
        % obtain JW estimator
        jwCorrectedQuantiles = noisyExtreme_JWquantileBiasEstimator(tau, bSample, vB, T);
        jwB(b, :) = quantile(bSample, jwCorrectedQuantiles);
    end
    
    % Report quantiles
    jwQ = quantile(jwB, [alphaCI, 1-alphaCI/2]);
    
    
end