% ===========================================================
% File: setConfidenceIntervalMethods_CompareIntervals.m
% Description: This script describes the confidence intervals to be
% evaluated in the main simulation.
% Each confidence interval must be an instance of the
% quantileEstimatorConfidenceIntervalArray class. 
% Note: quantileEstimatorConfidenceIntervalArray is a value class.
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
%
% ===========================================================

%% Central: Binomial CI with no correction 

% Fitting function
fitBinomial = @(thetaEsts, targetQuantiles, varEsts, T) ...
    quantileBinomialEstCI(thetaEsts, targetQuantiles, alphaCI, 1);

% Plotting parameters
binomialColor = [46, 230, 46]/255;
binomialLine = '-.+';

% Instantiate
methodArrayCentralBinomial = ...
    quantileEstimatorConfidenceIntervalArray(fitBinomial, ...
    'binomial', 'Central (naive)', ...
    binomialColor, binomialLine); 

%% Central: normal approximation with debiasing (JW 2024)
% Args: data, targetQuantiles, variances, T, bootstrap samples, alpha

% Fitting function
fitJW = @(thetaEsts, targetQuantiles, varEsts, T) ...
    jwCorrectedEstCI(thetaEsts, targetQuantiles, alphaCI, ...
    varEsts, T,  numBootstrapSamples);

% Plotting parameters
jwColor = [ 106, 130, 68]/255;
jwLine = '-..';

% Instantiate
methodArrayCentralJW = ...
    quantileEstimatorConfidenceIntervalArray(fitJW, ...
    'jw', 'Central: analytical correction', ...
    jwColor, jwLine); 

%% Extreme: subsampling with denominator tuning parameter (q) fixed
% Subsample sizes are chosen using the minimum volatility method

% Choose reference value for denominator parameter
subsamplingQ = 2;
% Fitting function
fitExtrFixedQ = @(thetaEsts, targetQuantiles, varEsts, T) ...
    extremeSubsamplingEstCI(thetaEsts, targetQuantiles, alphaCI, ...
    subsamplingQ, 'MV', numSubsamples);
 
% Plotting parameters
subsamplingFixedDenomColor = [222, 7, 7]/255;  
subsamplingFixedDenomLine = '-o';

% Instantiate
methodArrayExtremeSubsampFixedQ = ...
    quantileEstimatorConfidenceIntervalArray(fitExtrFixedQ, ...
    'extrFixedQ', 'Extreme: subsampling, fixed-q', ...
    subsamplingFixedDenomColor, subsamplingFixedDenomLine); 

%% Extreme: subsampling with denominator parameter (q) matching numerator 
% The parameter q in the denominator tracks the corresponding sample
% quantile down to a minimum of q=1 (to prevent division by 0)
%
% Note: excluded as it is dominated by other methods, also partially
% covered by the feasible IVT
%
% % Fitting function
% fitExtrSampleQ = @(thetaEsts, targetQuantiles, varEsts, T) ...
%     extremeSubsamplingEstCI(thetaEsts, targetQuantiles, alphaCI, ...
%     'Sample', 'MV', numSubsamples);
% 
% % Plotting parameters
% subsamplingSampleDenomColor = [0.99, 0.03, 1]; 
% subsamplingSampleDenomLine = '-x';
% 
% % Instantiate
% methodArrayExtremeSubsampSampleQ = ...
%     quantileEstimatorConfidenceIntervalArray(fitExtrSampleQ, ...
%     'fitExtrSampleQ', 'Extreme: subsampling, q=l', ...
%     subsamplingSampleDenomColor, subsamplingSampleDenomLine); 

%% Extreme: simulated critical values with the PWM EV index estimator

% Choose reference value for denominator parameter
simulatedQ = 4;

% Fitting function
fitExtrFixedQSim = @(thetaEsts, targetQuantiles, varEsts, T) ...
    extremeSimulationEstCI(thetaEsts, targetQuantiles, alphaCI, ...
        simulatedQ, numBootstrapSamples);

% Plotting parameters
subsamplingFixedDenomSimColor = [60, 16, 97]/255;
subsamplingFixedDenomSimLine = '-pentagram';

% Instantiate
methodArrayExtremeSimFixedQ = ...
    quantileEstimatorConfidenceIntervalArray(fitExtrFixedQSim, ...
    'extrFixedQSim', 'Extreme: simulated (PWM), fixed-q', ...
    subsamplingFixedDenomSimColor, subsamplingFixedDenomSimLine); 

%% Intermediate: asymptotic normality

% Fitting function
fitIntermediateNormal = @(thetaEsts, targetQuantiles, varEsts, T) ...
    intNormalEstCI(thetaEsts, targetQuantiles, alphaCI);

% Plotting parameters
intermediateNormalColor = [227, 207, 30]/255;
intermediateNormalLine = '--^';

% Instantiate
methodArrayIntermediateNormal = ...
    quantileEstimatorConfidenceIntervalArray(fitIntermediateNormal, ...
    'intNormal', 'Intermediate: normal critical values', ...
    intermediateNormalColor, intermediateNormalLine); 

%% Intermediate: extrapolation-based

% Fitting function
fitIntermediateExtrapolation = @(thetaEsts, targetQuantiles, varEsts, T) ...
    extrapolationEstCI(thetaEsts, targetQuantiles, alphaCI);

% Plotting parameters
intermediateExtrColor = [255, 165,0]/255;
intermediateExtrLine = '--<';

% Instantiate
methodArrayIntermediateExtr = ...
    quantileEstimatorConfidenceIntervalArray(...
    fitIntermediateExtrapolation, ...
    'intExtr', 'Intermediate: extrapolation', ...
    intermediateExtrColor, intermediateExtrLine); 

 
%% Combine the methods into a single cell array

methodsCI = findAndCollect('methodArray');
 