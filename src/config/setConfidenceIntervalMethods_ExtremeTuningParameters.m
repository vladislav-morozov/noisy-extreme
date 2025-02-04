% ===========================================================
% File: setConfidenceIntervalMethods_ExtremeTuningParameters.m
% Description: This script creates instances of extreme confidence 
%              interval methods with different tuning parameters (q values)
%              Each method is either subsampling-based or simulation-based, 
%              with unique visual characteristics for plotting.
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
% ===========================================================

%% Define Tuning Parameter Candidates and Initialize Method Array

% Define the range of q values (denominator parameters) to test
qCandidates = [2:2:9, 10:6:30]; 

% Initialize an array to store confidence interval (CI) methods
% Each q value will have two associated methods (subsampling and simulated)
methodsCI = cell(2 * length(qCandidates), 1);

%% Instantiate Confidence Interval Methods

% Loop over each q value to create subsampling-based and simulation-based
% CI methods
for qID = 1:length(qCandidates)
    % Extract current q value from candidates
    qCandidate = qCandidates(qID);

    % ------------------
    % Subsampling-Based Method
    % ------------------
    
    % Define subsampling CI function using fixed q value
    fitExtrFixedQ = @(thetaEsts, targetQuantiles, varEsts, T) ...
        extremeSubsamplingEstCI(thetaEsts, targetQuantiles, alphaCI, ...
        qCandidate, 'MV', numSubsamples);

    % Compute interpolation fraction to adjust color smoothly
    qProgressFraction = (qID - 1) / (length(qCandidates) - 1);

    % Define color by interpolating between shades of blue
    subsamplingColor = (qProgressFraction * [119, 155, 255] + ...
                       (1 - qProgressFraction) * [0, 68, 254])/255;
    subsamplingColorBW = (qProgressFraction * [0, 0, 0] + ...
                       (1 - qProgressFraction) * [200, 200, 200])/255;
    subsamplingLine = '-';
    subsamplingMarker = 'none';
    subsamplingMarkerSize = 1;

    % Instantiate the subsampling-based CI method with defined parameters
    methodsCI{qID} = quantileEstimatorConfidenceIntervalArray(fitExtrFixedQ, ...
        "extrSubsamp" + num2str(qCandidate), ...
        "Extreme: subsampling, q=" + num2str(qCandidate), ...
        subsamplingColor, subsamplingColorBW,  subsamplingLine, ...
        subsamplingMarker, subsamplingMarkerSize);

    % ------------------
    % Simulation-Based Method
    % ------------------

    % Define simulation-based CI function using fixed q value
    fitExtrFixedQSim = @(thetaEsts, targetQuantiles, varEsts, T) ...
        extremeSimulationEstCI(thetaEsts, targetQuantiles, alphaCI, ...
            qCandidate, numBootstrapSamples);

    % Define color by interpolating between darker and lighter shades of
    % orange
    simColor = (qProgressFraction * [190, 166, 96] + ...
               (1 - qProgressFraction) * [244, 184, 11])/255;
    simColorBW = (qProgressFraction * [0, 0, 0] + ...
                       (1 - qProgressFraction) * [200, 200, 200])/255;
    simLine = '--';
    simMarker = 'none';
    simMarkerSize = 1;

    % Instantiate the simulation-based CI method with defined parameters
    methodsCI{qID + length(qCandidates)} = ...
        quantileEstimatorConfidenceIntervalArray(fitExtrFixedQSim, ...
        "extrSim" + num2str(qCandidate), ...
        "Extreme: simulated (PWM), q=" + num2str(qCandidate), ...
        simColor, simColorBW, simLine, ...
        simMarker, simMarkerSize);
end