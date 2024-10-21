% ===========================================================
% File: setConfidenceIntervalMethods.m
% Description: This script describes the confidence intervals to be
% evaluated. Each confidence interval must be an instance of the
% quantileEstimatorConfidenceIntervalArray class. 
% Note: quantileEstimatorConfidenceIntervalArray is a value class.
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
% ===========================================================

%% Central: Binomial CI with no correction 

% Fitting function
fitBinomial = @(dataVector, targetQuantiles) ...
    quantileBinomialEstCI(dataVector, targetQuantiles, alphaCI, 1);

% Plotting parameters
binomialColor = [46, 230, 46]/255;
binomialLine = '-.+';

% Instantiate
methodCentralBinomial = ...
    quantileEstimatorConfidenceIntervalArray(fitBinomial, ...
    'binomial', 'Central (naive)', ...
    binomialColor, binomialLine); 

%% Central: normal approximation with debiasing (JW 2024)
% Args: data, targetQuantiles, variances, T, bootstrap samples, alpha

% Fitting function
fitJW = @(thetaEsts, targetQuantiles, varEsts, T,  numBootstrapSamples) ...
    jwCorrectedEstCI(thetaEsts, targetQuantiles, alphaCI, varEsts, T,  numBootstrapSamples);

% Plotting parameters
jwColor = [ 106, 130, 68]/255;
jwLine = '-..';

% Instantiate
methodCentralJW = ...
    quantileEstimatorConfidenceIntervalArray(fitJW, ...
    'jw', 'Central: analytical correction', ...
    jwColor, jwLine); 


%% Extreme: subsampling with denominator tuning parameter q fixed
% number subsamples, numerator and denominator tuning parametesr

% Fitting function
fixExtrFixedQ
extremeSubsamplingEstCI(alphaCI, thetaEsts, 'sample', 60, ...
            100, targetQuantiles)

% Plotting parameters
subsamplingFixedDenomColor = [222, 7, 7]/255;  
subsamplingFixedDenomLine = '-o';

% Instantiate
methodExtremeSubsampling = ...
    quantileEstimatorConfidenceIntervalArray(fitJW, ...
    'extrFixedQ', 'Extreme: subsampling, fixed-q', ...
    subsamplingFixedDenom, subsamplingFixedDenomLine); 


%% Extreme: subsampling with denominator tuning parameter matching numerator 

%% Extreme: simulation with PWM estimator

%% Intermediate approximations


%% Combine the methods into a single cell array

methodsCI = {methodCentralBinomial};
