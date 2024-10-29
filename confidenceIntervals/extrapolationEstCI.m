function [extrapolationEst, extrapolationInt] = ...
        extrapolationEstCI(thetaVector, targetQuantiles, alphaCI)
% extrapolationEstCI Computes the intermediate order extrapolation-based
% estimators and confidence intervals for extreme quantiles.
%
% The construction follows the description in theorem 4.3.1 in De Haan and
% Ferreira (2007) (DHF07).
% Extreme value index and scale a(N/n) are estimated using the PWM
%   estimator (3.6.1 in DHF).
% The location parameter b(N/k) is estimated using the corresponding sample
%   order statistic (see after corollary 4.3.9 in DHF07).
% Variance is computed using problem 4.7 in DHF07.
%
% Reference: de Haan, L., & Ferreira, A. (2006). Extreme Value Theory.
% Springer. https://doi.org/10.1007/0-387-34471-3
%
% Args:
%     thetaVector (vector): A presorted vector of data.
%     targetQuantiles (vector): A vector of target quantiles.
%     alphaCI (float): Significance level for the confidence intervals.
%
% Returns:
%     extrapolationEst (vector): Quantile estimators.
%     extrapolationInt (matrix): Confidence intervals for quantiles.

    % Choose optimal k
    kOpt = bootstrapChooseK(thetaVector, 1000);

    % Extract sizes of relevant vectors
    N = length(thetaVector);
    numQuantiles = length(targetQuantiles);

    % Compute the PWM estimator with the optimal k
    [gammaHat, sigmaHat] = pwmEstimator(thetaVector, kOpt);

    % Flip quantiles to the notation in DHF07
    pn = (1 - targetQuantiles);

    % Construct the quantile estimator
    extrapolationEst = ...
        thetaVector(N - kOpt) + ...
        sigmaHat * ((kOpt ./ (N .* pn)) .^ gammaHat - 1) ./ gammaHat;

    % Compute the variance of the estimator
    if gammaHat >= 0
        varHat = ...
            abs((1 - gammaHat) * (2 - gammaHat)^2 * ...
            (1 - gammaHat + 2 * gammaHat^2) / ...
            ((1 - 2 * gammaHat) * (3 - 2 * gammaHat)));
    else
        varHat = ...
            2 * (2 - 2 * gammaHat + 12 * gammaHat^2 - 38 * gammaHat^3 + ...
            47 * gammaHat^4 - 66 * gammaHat^5 + 74 * gammaHat^6 - ...
            40 * gammaHat^7 + 8 * gammaHat^8) / ...
            ((1 - 2 * gammaHat) * (3 - 2 * gammaHat));
    end

    % Create the effective extrapolation quantile measure
    dn = kOpt ./ (N * pn);

    % Construction of confidence intervals may only be possible for some
    % quantiles. It is only possible if dn is greater than 1.
    
    % Create the function that appears in the normalization factor
    qGamma = @(s) s .^ gammaHat .* log(s);
    
    % Normal critical value
    normalCritValue = norminv(1 - alphaCI / 2);

    % The function qGamma will be integrated by piece starting dn = 1, the
    % value is tracked in qGammaCurrent
    qGammaCurrent = 0;

    % Allocate space for intervals
    extrapolationInt = zeros(2, numQuantiles);

    % Create intervals for each quantile in turn
    for j = 1:numQuantiles
        % If current dn <= 1, no construction is possible
        if dn(j) <= 1 || pn(j) == 0
            extrapolationInt(1, j) = NaN;
            extrapolationInt(2, j) = NaN;
        else
            % Compute current value of the integral of qGamma
            if j == 1
                qGammaCurrent = qGammaCurrent + ...
                    integral(qGamma, 1, dn(j));
            else
                qGammaCurrent = qGammaCurrent + ...
                    integral(qGamma, max(dn(j-1), 1), dn(j));
            end

            % Set the integral
            extrapolationInt(1, j) = extrapolationEst(j) - ...
                normalCritValue * sigmaHat * ...
                qGammaCurrent * sqrt(varHat / kOpt);
            extrapolationInt(2, j) = extrapolationEst(j) + ...
                normalCritValue * sigmaHat * ...
                qGammaCurrent * sqrt(varHat / kOpt);
        end
    end
end