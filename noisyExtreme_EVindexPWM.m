function gammaPWM = noisyExtreme_EVindexPWM(thetaSorted, k)
% noisyExtreme_EVindexPWM Implements the probability-weighted moment
% estimator of Hosking, Wallis (1987)
%
% References:
% Hosking, J. R. M., & Wallis, J. R. (1987). Parameter and Quantile 
% Estimation for the Generalized Pareto Distribution. Technometrics, 29(3), 
% 339–349. https://doi.org/10.2307/1269343

    thetaData = thetaSorted(end-k+1:end);
    Pn =  mean(thetaData-thetaData(1)); 
    w = (k-1:-1:0)/k;
    Qn = (w*(thetaData-thetaData(1)))/k;
    gammaPWM = (Pn- 4*Qn)/(Pn-2*Qn);
 

end