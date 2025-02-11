% ===========================================================
% File: setConfidenceIntervalMethods_ExtremeNumeratorParameter.m
% Description: This script creates instances of extreme confidence 
%              interval methods with different tuning parameters (r values)
%              Each method is either subsampling-based or simulation-based, 
%              with unique visual characteristics for plotting.
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
% ===========================================================

% Set values of tuning parameters (r, q) to test
qCandidates = [2, 4];           % denominator values
rCandidates = {"match", 0};     % numerator values

% Initialize an array to store confidence interval (CI) methods
% Each q value will have two associated methods (subsampling and simulated)
methodsCI = cell(2*length(rCandidates) * length(qCandidates), 1);

% Create list of 4 colors used as CI line colors
colorMat = [255,165,0;...
            140, 91, 0; ...
            25, 178, 255; ...
            0, 68, 204]/255;
 
%% Instantiate Confidence Interval Methods

% Loop over each (r, q) parir to create subsampling-based and 
% simulation-based CI methods
for qID = 1 : length(qCandidates)
    for rID = 1 : length(rCandidates)


        % Extract current (r, q) value from candidates
        qCandidate = qCandidates(qID);
        rCandidate = rCandidates{rID};

        % ------------------
        % Subsampling-Based Method
        % ------------------

        % Define subsampling CI function using fixed q value
        fitExtrFixedQ = @(thetaEsts, targetQuantiles, varEsts, T) ...
            extremeSubsamplingEstCI(thetaEsts, targetQuantiles, alphaCI, ...
            rCandidate, qCandidate, 'MV', numSubsamples);

        % Compute interpolation fraction to adjust color smoothly
        qProgressFraction = (qID -1 +  (rID-1)*length(qCandidates) ) /  ...
            (length(qCandidates)*length(rCandidates));

        % Define color by picking corresponding color from colormat
        subsamplingColor = colorMat(qID + (rID-1)*(length(qCandidates)),:);
        subsamplingColorBW = (qProgressFraction * [0, 0, 0] + ...
            (1 - qProgressFraction) * [200, 200, 200])/255;
        subsamplingLine = '-';
        subsamplingMarker = 'none';
        subsamplingMarkerSize = 1;

        % Instantiate the subsampling-based CI method with defined parameters
        methodsCI{qID + (rID-1)*(length(qCandidates))} = ...
            quantileEstimatorConfidenceIntervalArray(fitExtrFixedQ, ...
            "extrSubsamp" + num2str(qCandidate), ...
            "Extreme: subsampling, q=" + num2str(qCandidate) + ...
            ", r = " + num2str(rCandidate), ...
            subsamplingColor, subsamplingColorBW,  subsamplingLine, ...
            subsamplingMarker, subsamplingMarkerSize);

        % ------------------
        % Simulation-Based Method
        % ------------------

        % Define simulation-based CI function using fixed q value
        fitExtrFixedQSim = @(thetaEsts, targetQuantiles, varEsts, T) ...
            extremeSimulationEstCI(thetaEsts, targetQuantiles, alphaCI, ...
            rCandidate, qCandidate, numBootstrapSamples);
 
        simColorBW = (qProgressFraction * [0, 0, 0] + ...
            (1 - qProgressFraction) * [200, 200, 200])/255;
        simLine = '--';
        simMarker = 'none';
        simMarkerSize = 1;

        % Instantiate the simulation-based CI method with defined parameters
        methodsCI{length(rCandidates) * length(qCandidates) + ...
            qID + (rID-1)*(length(qCandidates))} = ...
            quantileEstimatorConfidenceIntervalArray(fitExtrFixedQSim, ...
            "extrSim" + num2str(qCandidate), ...
            "Extreme: simulated (PWM), q=" + num2str(qCandidate) + ...
            ", r = " + num2str(rCandidate), ...
            subsamplingColor, simColorBW, simLine, ...
            simMarker, simMarkerSize);
    end
end