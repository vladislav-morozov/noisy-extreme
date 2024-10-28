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


%% Extreme: subsampling with denominator tuning parameter (q) fixed
% Subsample sizes are chosen using the minimum volatility method

% Choose reference value for denominator parameter
subsamplingQ = 5;
% Fitting function
fitExtrFixedQ = @(thetaEsts, targetQuantiles, varEsts, T,  numBootstrapSamples) ...
    extremeSubsamplingEstCI(thetaEsts, targetQuantiles, alphaCI, ...
    subsamplingQ, 'MV', numSubsamples);
 

% Plotting parameters
subsamplingFixedDenomColor = [222, 7, 7]/255;  
subsamplingFixedDenomLine = '-o';

% Instantiate
methodExtremeSubsampFixedQ = ...
    quantileEstimatorConfidenceIntervalArray(fitExtrFixedQ, ...
    'extrFixedQ', 'Extreme: subsampling, fixed-q', ...
    subsamplingFixedDenomColor, subsamplingFixedDenomLine); 


%% Extreme: subsampling with denominator parameter (q) matching numerator 
% The parameter q in the denominator tracks the corresponding sample
% quantile down to a minimum of q=1 (to prevent division by 0)

% Fitting function
fitExtrSampleQ = @(thetaEsts, targetQuantiles, varEsts, T,  numBootstrapSamples) ...
    extremeSubsamplingEstCI(thetaEsts, targetQuantiles, alphaCI, ...
    'Sample', 'MV', numSubsamples);
 

% Plotting parameters
subsamplingSampleDenomColor = [0.99, 0.03, 1]; 
subsamplingSampleDenomLine = '-x';

% Instantiate
methodExtremeSubsampSampleQ = ...
    quantileEstimatorConfidenceIntervalArray(fitExtrSampleQ, ...
    'fitExtrSampleQ', 'Extreme: subsampling, q=l', ...
    subsamplingSampleDenomColor, subsamplingSampleDenomLine); 


%% Extreme: simulated critical values with the PWM EV index estimator
% This method uses the same denominatorParam as the subsampling method with
% fixed-q

% Fitting function
fitExtrFixedQSim = @(thetaEsts, targetQuantiles, varEsts, T,  numBootstrapSamples) ...
    extremeSimulationEstCI(thetaVector, targetQuantiles, alphaCI, ...
        subsamplingQ, numBootstrapSamples);

 

% Plotting parameters
subsamplingFixedDenomSimColor = [60, 16, 97]/255;
subsamplingFixedDenomSimLine = ''-pentagram';

% Instantiate
methodExtremeSubsampFixedQ = ...
    quantileEstimatorConfidenceIntervalArray(fitExtrFixedQSim, ...
    'extrFixedQSim', 'Extreme: simulated (PWM), fixed-q', ...
    subsamplingFixedDenomSimColor, subsamplingFixedDenomSimLine); 



%% Intermediate: asymptotic normality

% Fitting function
fitIntermediateNormal = @(thetaEsts, targetQuantiles, varEsts, T,  numBootstrapSamples) ...
    extremeSimulationEstCI(thetaVector, targetQuantiles, alphaCI, ...
        subsamplingQ, numBootstrapSamples);

 

% Plotting parameters
subsamplingFixedDenomSimColor = [60, 16, 97]/255;
subsamplingFixedDenomSimLine = ''-pentagram';

% Instantiate
methodIntermediateNormal = ...
    quantileEstimatorConfidenceIntervalArray(fitIntermediateNormal, ...
    'extrFixedQSim', 'Extreme: simulated (PWM), fixed-q', ...
    subsamplingFixedDenomSimColor, subsamplingFixedDenomSimLine); 

%% Combine the methods into a single cell array

methodsCI = {methodCentralBinomial, methodCentralJW, methodExtremeSubsampFixedQ};
