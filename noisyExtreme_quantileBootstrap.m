function jwQ = noisyExtreme_quantileBootstrap(noisyThetaS, vEst, T, tau, alpha, B)

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