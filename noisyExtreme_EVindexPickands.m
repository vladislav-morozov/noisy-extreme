function gammaPickands = noisyExtreme_EVindexPickands(thetaSorted, k)
% noisyExtreme_EVindexPWM Implements the probability-weighted moment
% estimator of Hosking, Wallis (1987)
%
% References:
% Hosking, J. R. M., & Wallis, J. R. (1987). Parameter and Quantile 
% Estimation for the Generalized Pareto Distribution. Technometrics, 29(3), 
% 339–349. https://doi.org/10.2307/1269343

    gammaPickands = 1/log(2)*log( (thetaSorted(end-k)-thetaSorted(end-2*k) )...
        /(thetaSorted(end-2*k)-thetaSorted(end-4*k))  );


end