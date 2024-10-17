% ===========================================================
% File: setConfidenceIntervalMethods.m
% Description: This script describes the confidence intervals to be
% evaluated. Each confidence interval must be an instance of the
% confidenceIntervalArray class
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
%
% ===========================================================

%% Central approximations
% Central approximation, no corrections

fitBinomial = @(dataVector, targetQuantiles) ...
    quantileBinomialEstCI(dataVector, targetQuantiles, alphaCI, 1);

ciCentralBinomial = quantileEstimatorConfidenceIntervalArray(fitBinomial, 'binomial', 'Central (naive)'); 

%% Extreme-order approximations


%% Intermediate approximations


%% Combine

approachesArray = {ciCentralBinomial};
%% Usage notes
currentApproach = ciCentralBinomial;
% Intervals fitted as 
currentApproach.computeEstimatorsIntervals(noisyThetaSsorted, quantilesConsidered);

% Intervals evaluated as 
currentApproach.computeLengths() % compute lengths
currentApproach.checkCoverage(trueQuantiles) % check coverages
currentApproach.computeEstErrors(trueQuantiles) % compute errors