function ivtStatistics = ...
    computeIVTRatios(thetaVector, targetQuantiles, trueQuantiles)
% computeIVTRatios Computes the ratio that appears in the feasible
% intermediate extreme order theorem
%
% Args:
%     thetaVector (vector, double): Estimates of individual effects.
%     targetQuantiles (row vector, double): Quantiles of interest.
%     trueQuantiles (row vector, double): Values of quantiles of interest
%
% Returns:
%     ivtStatistics (vector, double): Ratio statics, one for each quantile

    % Compute cross-sectional sample size
    N = length(thetaVector);

    % Ensure that vectors of data and quantiles are row vectors
    thetaVector = reshape(thetaVector, 1, []);
    trueQuantiles = reshape(trueQuantiles, 1, []);

    % Compute the indices appearing in the numerator and the denominator
    kIVT = floor((1 - targetQuantiles) * N);  % Indices for the numerator
    sIVT = floor(sqrt(kIVT));  % Indices for the denominator  

    % Extract order statistics for the ratio
    thetaNumerator = thetaVector(N - kIVT);
    thetaDenominator = thetaVector(N - kIVT - sIVT);

    % Compute the ratios
    ivtStatistics = ((thetaNumerator-trueQuantiles) ./ ...
                    (thetaNumerator - thetaDenominator));
 
 
end
