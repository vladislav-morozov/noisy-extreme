% ===========================================================
% File: setConfidenceIntervalMethods_CompareIntervals.m
% Description: This script describes the confidence intervals to be
%              evaluated in the main simulation.
%
% ===========================================================
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
%
% Each confidence interval must be an instance of the
% quantileEstimatorConfidenceIntervalArray class. 
%
% Note: quantileEstimatorConfidenceIntervalArray is a value class.
%
% ===========================================================

%% Central: Binomial CI with no correction 

% Fitting function
fitBinomial = @(thetaEsts, targetQuantiles, varEsts, T) ...
    quantileBinomialEstCI(thetaEsts, targetQuantiles, alphaCI, 1);

% Plotting parameters
binomialColor = [200, 200, 200]/255;
binomialColorBW = binomialColor;
binomialLine = '-.';
binomialMarker = 'none';
binomialMarkerSize = 4;

% Instantiate
methodArrayCentralBinomial = ...
    quantileEstimatorConfidenceIntervalArray(fitBinomial, ...
    'binomial', 'Central: binomial', ...
    binomialColor, binomialColorBW, binomialLine, ...
    binomialMarker, binomialMarkerSize); 

%% Central: normal approximation with debiasing (JW 2024)
% Args: data, targetQuantiles, variances, T, bootstrap samples, alpha

% Fitting function
fitJW = @(thetaEsts, targetQuantiles, varEsts, T) ...
    jwCorrectedEstCI(thetaEsts, targetQuantiles, alphaCI, ...
    varEsts, T,  numBootstrapSamples);

% Plotting parameters
jwColor = [140, 140, 140]/255;
jwColorBW = [140, 140, 140]/255;
jwLine = '-.';
jwMarker = '|';
jwMarkerSize = 4;

% Instantiate
methodArrayCentralJW = ...
    quantileEstimatorConfidenceIntervalArray(fitJW, ...
    'jw', 'Central: analytical correction', ...
    jwColor, jwColorBW, jwLine, ...
    jwMarker, jwMarkerSize); 

%% Extreme: subsampling with denominator tuning parameter (q) fixed
% Subsample sizes are chosen using the minimum volatility method

% Choose reference value for denominator parameter
subsamplingQ = 2;
% Fitting function
fitExtrFixedQ = @(thetaEsts, targetQuantiles, varEsts, T) ...
    extremeSubsamplingEstCI(thetaEsts, targetQuantiles, alphaCI, ...
    subsamplingQ, 'MV', numSubsamples);
 
% Plotting parameters
subsamplingFixedDenomColor = [0, 0, 255]/255;  
subsamplingFixedDenomColorBW = [50, 50, 50]/255;  
subsamplingFixedDenomLine = '-';
subsamplingFixedDenomMarker = 'x';
subsamplingFixedDenomMarkerSize = 7;

% Instantiate
methodArrayExtremeSubsampFixedQ = ...
    quantileEstimatorConfidenceIntervalArray(fitExtrFixedQ, ...
    'extrFixedQ', 'Extreme: subsampling, fixed-q', ...
    subsamplingFixedDenomColor, subsamplingFixedDenomColorBW, ...
    subsamplingFixedDenomLine, ...
    subsamplingFixedDenomMarker, subsamplingFixedDenomMarkerSize); 

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
subsamplingFixedDenomSimColor = [1, 135, 232]/255; 
subsamplingFixedDenomSimColorBW = [1, 1, 1]/255; 
subsamplingFixedDenomSimLine = '-';
subsamplingFixedDenomSimMarker = 'o';
subsamplingFixedDenomSimMarkerSize = 7;

% Instantiate
methodArrayExtremeSimFixedQ = ...
    quantileEstimatorConfidenceIntervalArray(fitExtrFixedQSim, ...
    'extrFixedQSim', 'Extreme: simulated (PWM), fixed-q', ...
    subsamplingFixedDenomSimColor, subsamplingFixedDenomSimColorBW, ...
    subsamplingFixedDenomSimLine, ...
    subsamplingFixedDenomSimMarker, subsamplingFixedDenomSimMarkerSize); 

%% Intermediate: asymptotic normality

% Fitting function
fitIntermediateNormal = @(thetaEsts, targetQuantiles, varEsts, T) ...
    intNormalEstCI(thetaEsts, targetQuantiles, alphaCI);

% Plotting parameters
intermediateNormalColor = [168, 100, 0]/255;  
intermediateNormalColorBW = [110, 110, 110]/255;  
intermediateNormalLine = '--';
intermediateNormalMarker = '^';
intermediateNormalMarkerSize = 3;

% Instantiate
methodArrayIntermediateNormal = ...
    quantileEstimatorConfidenceIntervalArray(fitIntermediateNormal, ...
    'intNormal', 'Intermediate: normal critical values', ...
    intermediateNormalColor, intermediateNormalColorBW,...
    intermediateNormalLine, ...
    intermediateNormalMarker, intermediateNormalMarkerSize); 

%% Intermediate: extrapolation-based

% Fitting function
fitIntermediateExtrapolation = @(thetaEsts, targetQuantiles, varEsts, T) ...
    extrapolationEstCI(thetaEsts, targetQuantiles, alphaCI);

% Plotting parameters
intermediateExtrColor = [214, 190, 0]/255;  %  yellowish
intermediateExtrColorBW = [180, 180, 180]/255;  %  yellowish
intermediateExtrLine = '--';
intermediateExtrMarker = 'v';
intermediateExtrMarkerSize = 3;

% Instantiate
methodArrayIntermediateExtr = ...
    quantileEstimatorConfidenceIntervalArray(...
    fitIntermediateExtrapolation, ...
    'intExtr', 'Intermediate: extrapolation', ...
    intermediateExtrColor, intermediateExtrColorBW, ...
    intermediateExtrLine, ...
    intermediateExtrMarker, intermediateExtrMarkerSize); 

 
%% Combine the methods into a single cell array

methodsCI = findAndCollect('methodArray');
 