function [extrapolationEst, extrapolationInt, possibleConstruction] = ...
    noisyExtreme_extrapolationEstimator(thetaSorted, quantilesConsidered,...
    alphaCI, k)
% noisyExtreme_extrapolationEstimator Computes the extrapolation estimator for tail
% quantiles and CIs. Follows description in theorem 4.3.1 with the PWM estimators
% of section 3.6.1 in De Haan and Ferreira (2007). Variance is computed
% using problem 4.7 in in De Haan and Ferreira (2007).


    k = floor(k); % ensure that k is an integer
    N = length(thetaSorted);
    Q=  length(quantilesConsidered);
    % Compute the PWM estimator
    [gammaHat, sigmaHat] = noisyExtreme_EVindexPWM(thetaSorted, k);
    
    
    
    %  Construct the estimator
    pn = (1-quantilesConsidered);
    extrapolationEst = thetaSorted(N-k)+sigmaHat*( (k./(N.*pn)).^(gammaHat) -1)./(gammaHat) ; 
    
    
    % Variance
    if gammaHat >= 0
       varHat = abs((1-gammaHat)*(2-gammaHat)^2*(1-gammaHat+ 2*gammaHat^2)/...
           ((1-2*gammaHat)*(3-2*gammaHat)));
    else
        varHat = 2*( 2-2*gammaHat+ 12*gammaHat^2 - 38*gammaHat^3+47*gammaHat^4 ...
        -66*gammaHat^5+ 74*gammaHat^6- 40*gammaHat^7+ 8*gammaHat^8)/...
        ((1-2*gammaHat)*(3-2*gammaHat));
    end
    
    dn = k./(N*pn);
    dgamma = @(s) s.^(gammaHat).*log(s);
    zAlpha = norminv(1-alphaCI/2);
    
    qGamma = 0;
    extrapolationInt = zeros(2, Q);
    possibleConstruction = zeros(1, Q);
    for j=1:Q
        if dn(j)<=1
            extrapolationInt(1, j)= -Inf;
            extrapolationInt(2, j) = Inf;
            possibleConstruction(j) =0;
        elseif pn(j)==0 %check for the first quantile
            extrapolationInt(1, j)= -Inf;
            extrapolationInt(2, j) = Inf;
            possibleConstruction(j) =0;
        else
            if j==1
                qGamma = qGamma+integral(dgamma, 1, dn(j));
            else
                 qGamma = qGamma+integral(dgamma, max(dn(j-1), 1), dn(j));
            end
            extrapolationInt(1, j) = extrapolationEst(j) - zAlpha*sigmaHat*...
                qGamma*sqrt(varHat/k);
            extrapolationInt(2, j) = extrapolationEst(j) + zAlpha*sigmaHat*...
                qGamma*sqrt(varHat/k);
            possibleConstruction(j) =1;
           
        end
        
    end
end