function gammaHill = noisyExtreme_EVindexHill(thetaSorted, k)
% noisyExtreme_EVindexPWM Implements the Hill (1975) estimator
%
%
% References:
% Hill, B. M. (1975). A Simple General Approach to Inference About the 
% Tail of a Distribution. The Annals of Statistics, 3(5), 1163–1174.

    thetaData = thetaSorted(end-k:end);
    gammaHill = mean(log(thetaData/thetaData(1))); 
end