function [gammaPWM, sigmaPWM] = noisyExtreme_EVindexPWM(thetaSorted, k)
% noisyExtreme_EVindexPWM Implements the probability-weighted moment
% estimator of Hosking, Wallis (1987)
%
% References:
% Hosking, J. R. M., & Wallis, J. R. (1987). Parameter and Quantile 
% Estimation for the Generalized Pareto Distribution. Technometrics, 29(3), 
% 339–349. https://doi.org/10.2307/1269343

    K = length(k);
    gammaPWM = zeros(K, 1);
    sigmaPWM = zeros(K, 1);
    
    for j=1:K
        kLoop = k(j);
        thetaData = thetaSorted(end-kLoop+1:end);      
        Pn =  mean(thetaData-thetaData(1));
        w = (kLoop-1:-1:0)/kLoop;
        Qn = (w*(thetaData-thetaData(1)))/kLoop;
        gammaPWM(j) = (Pn- 4*Qn)./(Pn-2*Qn);
        sigmaPWM(j) = 2*Pn.*Qn./(Pn-2*Qn);
    end
    
 

end