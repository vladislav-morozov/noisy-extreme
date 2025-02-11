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
numQCandidates = length(qCandidates);

% Initialize an array to store confidence interval (CI) methods
% Each q value will have two associated methods (subsampling and simulated)
methodsCI = cell(2 * length(qCandidates), 1);

% Create a matrix of colors to plot
colorMat1 = [linspace(1, 0.54, numQCandidates/2); ...
             linspace(0.64, 0.35, numQCandidates/2); ...
             linspace(0, 0, numQCandidates/2);   ]';
colorMat2 = [linspace(0.09, 0, numQCandidates/2); ...
             linspace(0.69, 0.25, numQCandidates/2); ...
             linspace(1, 0.8, numQCandidates/2);   ]';
% First half of colors is drawn from colorMat1, second from colorMat2
colorMat = flipud([colorMat1; colorMat2]);

%% Instantiate Confidence Interval Methods

% Loop over each q value to create subsampling-based and simulation-based
% CI methods
for qID = 1:length(qCandidates)
    % Extract current q value from candidates
    qCandidate = qCandidates(qID);

    currentColor = colorMat(qID,:);
    % ------------------
    % Subsampling-Based Method
    % ------------------
    
    % Define subsampling CI function using fixed q value
    fitExtrFixedQ = @(thetaEsts, targetQuantiles, varEsts, T) ...
        extremeSubsamplingEstCI(thetaEsts, targetQuantiles, alphaCI, ...
        "match", qCandidate, 'MV', numSubsamples);

    % Compute interpolation fraction to adjust color smoothly
    qProgressFraction = (qID - 1) / (length(qCandidates) - 1);

    % Set formating aspects
    subsamplingColorBW = (qProgressFraction * [0, 0, 0] + ...
                       (1 - qProgressFraction) * [200, 200, 200])/255;
    subsamplingLine = '-';
    subsamplingMarker = 'none';
    subsamplingMarkerSize = 1;

    % Instantiate the subsampling-based CI method with defined parameters
    methodsCI{qID} = quantileEstimatorConfidenceIntervalArray(fitExtrFixedQ, ...
        "extrSubsamp" + num2str(qCandidate), ...
        "Extreme: subsampling, q=" + num2str(qCandidate), ...
        currentColor, subsamplingColorBW,  subsamplingLine, ...
        subsamplingMarker, subsamplingMarkerSize);

    % ------------------
    % Simulation-Based Method
    % ------------------

    % Define simulation-based CI function using fixed q value
    fitExtrFixedQSim = @(thetaEsts, targetQuantiles, varEsts, T) ...
        extremeSimulationEstCI(thetaEsts, targetQuantiles, alphaCI, ...
            "match", qCandidate, numBootstrapSamples);

    % Set formatting aspects
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
        currentColor, simColorBW, simLine, ...
        simMarker, simMarkerSize);
end