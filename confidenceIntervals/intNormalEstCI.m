function [intNormalEst, intNormalCI] = ...
    intNormalEstCI(thetaVector, targetQuantiles, alphaCI)
% intNormalEstCI Computes confidence intervals and estimators based on the
% feasible intermediate order theorem
%
% Args:
%     thetaVector (vector, double): Estimates of individual effects.
%     targetQuantiles (row vector, double): Quantiles of interest.
%     alphaCI (double): Confidence interval parameter.
%
% Returns:
%     intNormalEst (vector, double): Corresponding sample quantiles
%     intNormalCI (matrix, double): Confidence intervals for target 
%         quantiles, each column corresponds to a different quantile; the
%         first row is the lower bound, and the second row is the upper 
%         bound.

    % Compute cross-sectional sample size
    N = length(thetaVector);

    % Compute the indices appearing in the numerator and the denominator
    kIVT = floor((1 - targetQuantiles) * N);  % Indices for the numerator
    sIVT = floor(sqrt(kIVT));  % Indices for the denominator  

    % Extract order statistics for the ratio
    thetaNumerator = thetaVector(N - kIVT);
    thetaDenominator = thetaVector(N - kIVT - sIVT);

    % Set the estimators
    intNormalEst = thetaNumerator;

    % Set the confidence intervals
    intNormalCI = [ ...
        (thetaNumerator - norminv(1 - alphaCI/2) * ...
            (thetaNumerator - thetaDenominator))'; ...
        (thetaNumerator - norminv(alphaCI/2) * ...
            (thetaNumerator - thetaDenominator))' ...
    ];
end
