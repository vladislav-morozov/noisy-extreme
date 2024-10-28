function [simExtremeEst, simExtremeInt] = ...
    extremeSimulationEstCI(thetaVector, targetQuantiles, alphaCI, ...
        denominatorParam, numBootstrapSamples)
    % extremeSimulationEstCI Computes quantile estimators and confidence 
    % intervals for quantiles using the feasible extreme value theorem with 
    % simulated critical values.
    %
    % Critical values are simulated from the limit gamma ratio distribution 
    % with the tail index estimated using the PWM estimator. The tuning 
    % parameter for the PWM estimator is chosen automatically using the 
    % semiparametric bootstrap.
    %
    % Args:
    %     thetaVector (vector): A presorted vector of data.
    %     targetQuantiles (vector): A vector of target quantiles.
    %     alphaCI (float): Significance level for the confidence intervals.
    %     denominatorParam (string or int): If "sample", the denominator 
    %         uses the corresponding sample quantile. If a positive 
    %         integer, the corresponding order statistic is used.
    %     numBootstrapSamples (int): Number of bootstrap samples to draw.
    %
    % Returns:
    %     simExtremeEst (vector): Quantile estimators.
    %     simExtremeInt (matrix): Confidence intervals for quantiles.
    %
    % TUNING PARAMETERS: The choice of k requires selecting a range of
    % values to select from. We select 25 values between N^(1/4) and
    % 4*N^(1/2) (which covers the heuristic choice of Drees and Kaufman).
    %
    % References:
    %     1. Caers, J., Beirlant, J., & Maes, M. A. (1999). Statistics for
    %        Modeling Heavy Tailed Distributions in Geology: Part I.
    %        Methodology. Mathematical Geology, 31(4), 391–410.
    %     2. Algorithm 4.3 in Caeiro, F., & Gomes, M. I. (2016). Threshold
    %        Selection in Extreme Value Analysis. In Extreme Value Modeling
    %        and Risk Analysis (pp. 69–85). Chapman and Hall/CRC.

    % Set values for the k vector
    N = length(thetaVector);
    kVector = unique(floor(linspace(N^(1/4), 4 * N^(1/2), 25)));
    
    % Choose optimal k using semiparametric bootstrap
    kOpt = bootstrapChooseK(thetaVector, kVector, numBootstrapSamples);
    
    % Compute estimator for gamma
    gammaEst = pwmEstimator(thetaVector, kOpt);
    
    % Compute critical values by simulations
    critValues = ...
        gammaRatioLimitQuantiles(gammaEst, denominatorParam, ...
        (1 - targetQuantiles) * N, [alphaCI / 2, 1 - alphaCI / 2, 1 / 2]);
    
    % Compute estimators and intervals
    numerator = thetaVector(ceil(length(thetaVector) * targetQuantiles));
    
    if isnumeric(denominatorParam)
        % Use the presupplied q
        denominator = thetaVector(end - denominatorParam);
    else
        % Set q to match the corresponding sample quantile
        denominator = numerator;
    end
    
    % Form the estimator
    simExtremeEst = ...
        numerator' - critValues(3, :) .* (denominator' - thetaVector(end));
    
    % Form the confidence interval
    simExtremeInt = ...
      [numerator' - critValues(1, :) .* (denominator' - thetaVector(end));
       numerator' - critValues(2, :) .* (denominator' - thetaVector(end))];
end


function limitRatioQuantiles = ...
    gammaRatioLimitQuantiles(gammaEst, denominatorParam, l, quantiles)
    % gammaRatioLimitQuantiles Simulates samples from a gamma ratio limit 
    % for feasibly normalized top order statistics.
    %
    % Args:
    %     gammaEst (scalar): Estimated value of gamma to use for 
    %         simulations.
    %     l (vector): Vector of positive values that characterizes the
    %         target quantiles as in F^{-1}(1-l/N).
    %     quantiles (vector): Vector of required quantiles 
    %         (between 0 and 1).
    %     denominatorParam (string or int): If "sample", the denominator 
    %         uses the corresponding sample quantile. If a positive 
    %         integer, the corresponding order statistic is used.
    %
    % Returns:
    %     limitRatioQuantiles (vector): Quantiles of the gamma ratio limit.
 
    % Set the number of samples to draw from the limit distribution
    sampleSize = 2e4;
    
    % Ensure l is a row vector
    l = reshape(l, [1, length(l)]);
    
    % Draw enough IID standard exponential variables
    expSample = exprnd(1, [sampleSize, max(floor(l)) + 1]);
    gammas1 = expSample(:, 1); % Extract the Gamma_1 term
    
    % Create sums of exponentials. Columns index quantiles of interest.
    % Sum is taken up to l(k) terms
    gammaSumL = zeros(sampleSize, length(l));
    for targetQuantileID = 1:length(l)
        gammaSumL(:, targetQuantileID) = ...
            sum(expSample(:, 1:floor(l(targetQuantileID)) + 1), 2);
    end
    
    % Split depending on value passed for the denominatorParam
    if isnumeric(denominatorParam)
        % Use the presupplied q
        denominatorSum = ...
            sum(expSample(:, 1:min(2, denominatorParam + 1)), 2);
    else
        % Set q to match the corresponding sample quantile
        denominatorSum = gammaSumL;
    end
    
    % Compute a sample from the limit gamma ratio distribution. The
    % expression changes depending on the supplied value of gamma
    if gammaEst ~= 0
        sampleLimitRatio = ...
            (gammaSumL .^ (-gammaEst) - l .^ (-gammaEst)) ./ ...
            (denominatorSum .^ (-gammaEst) - gammas1 .^ (-gammaEst));
    else
        sampleLimitRatio = (-log(gammaSumL) - log(l)) ./ ...
            (-log(denominatorSum) + log(gammas1));
    end
    
    % Return quantiles
    limitRatioQuantiles = quantile(sampleLimitRatio, quantiles);
end
