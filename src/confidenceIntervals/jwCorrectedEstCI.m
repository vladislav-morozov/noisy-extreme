function [jwEst, jwInt] = ...
    jwCorrectedEstCI(thetaEsts, targetQuantiles, alphaCI, varEsts, ...
    T, numBootstrapSamples)
% JWCORRECTEDESTCI Computes the Jochmans, Weidner (2024) corrected
% estimator for target quantiles and returns a (1-alphaCI) bootstrap
% confidence interval.
%
% Args:
%     thetaEsts (vector, double): Estimates of individual effects.
%     varEsts (vector, double): Estimates of variances of thetaEsts as
%         estimators of underlying true thetas.
%     T (int): Size of individual samples.
%     targetQuantiles (row vector, double): Quantiles of interest.
%     alphaCI (double): Confidence interval parameter.
%     numBootstrapSamples (int): Number of bootstrap samples to draw.
%
% Returns:
%     jwEst (vector, double): Bias-corrected quantiles.
%     jwInt (matrix, double): Confidence intervals for target quantiles,
%         each column corresponds to a different quantile; the first row
%         is the lower bound, and the second row is the upper bound.

    % Compute cross-sectional sample size
    N = length(thetaEsts);

    % Compute the bias-corrected estimators
    correctedQuantiles = ...
        jwQuantileCorrection(thetaEsts, targetQuantiles, varEsts, T);
    jwEst = quantile(thetaEsts, correctedQuantiles);

    % Compute confidence intervals using the bootstrap
    
    % Allocate space for bootstrap draws
    jwB = zeros(numBootstrapSamples, length(targetQuantiles));

    % Loop over bootstrap samples
    for bootstrapSampleID = 1:numBootstrapSamples
        % Draw bootstrap sample and extract corresponding variances
        bootstrapSampleIndices = randi(N, N, 1);
        bootstrapSample = thetaEsts(bootstrapSampleIndices);
        bootstrapSampleVarEsts = varEsts(bootstrapSampleIndices);
        
        % Compute the JW estimator in the bootstrap sample
        correctedQuantiles = ...
            jwQuantileCorrection(bootstrapSample, targetQuantiles, ...
                bootstrapSampleVarEsts, T);
        jwB(bootstrapSampleID, :) = ...
            quantile(bootstrapSample, correctedQuantiles);
    end

    % Compute the CI using the quantiles of the bootstrap draws
    jwInt = quantile(jwB, [alphaCI, 1 - alphaCI / 2]);
end


function quantileCorrrected = ...
    jwQuantileCorrection(thetaEsts, targetQuantiles, varEsts, T)
% JWQUANTILECORRECTION Computes the analytically corrected quantiles of
% Jochmans, Weidner (2024).
%
% Returns corrected quantile level quantileCorrrected (tau^* in the
% notation of their paper).
%
% Args:
%     thetaEsts (vector, double): Estimates of individual effects.
%     targetQuantiles (vector, double): Row vector of quantiles of interest.
%     varEsts (vector, double): Estimates of variances of thetaEsts as 
%         estimators of underlying true thetas.
%     T (int): Size of individual samples.
%
% Returns:
%     quantileCorrrected (vector): Corrected quantile levels.

    % Cross-sectional sample size
    N = length(thetaEsts);
    
    % Obtain sample quantiles
    sampleQuantiles = quantile(thetaEsts, targetQuantiles);
    
    % Compute the analytical first-order bias correction
    h = T^(-1/2);
    K = gaussianKernelDerivative((thetaEsts-sampleQuantiles)/h);
    bf = -(N*h^2)^(-1) * varEsts' * K / 2;
    
    % Include the bias correction into the sample quantile
    quantileCorrrected = max(min(targetQuantiles + bf/T, 1), 0);
end


function a = gaussianKernelDerivative(x)
% GAUSSIANKERNELDERIVATIVE Computes the derivative of the standard 
% Gaussian kernel.
%
% Args:
%     x (vector, double): Input vector for which to compute the derivative.
%
% Returns:
%     a (vector, double): Derivative of the standard Gaussian kernel.
    
    a = (1 / sqrt(2 * pi)) * (-x) .* exp(-0.5 * x.^2);
end