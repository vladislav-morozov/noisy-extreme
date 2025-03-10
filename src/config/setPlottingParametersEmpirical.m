% ===========================================================
% File: setPlottingParametersEmpirical.m
% Description: This script parameters for exporting figures
%              for the empirical application.
% ===========================================================
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Author: Vladislav Morozov
% ===========================================================
  
% Set text interpreters to latex
set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultTextInterpreter', 'latex'); 

% Paths 
empResultFolder = "results/empirical/";                 % Emp result root
figureOutputFolder = "results/figures/";                % Figure output 
sectorLabelsPath = "results/empirical/sectorNames.csv"; % Sector labels
levelsTablePath = "results/empirical/exportCombos.csv"; % Export levels

% Set combinations for plot exports
levelsTable = readtable(levelsTablePath);
levelsTable = convertvars(levelsTable,"p50_ua_dens", 'string'); 
exportCombinations =  unique(levelsTable);

% Variables related to the density measure
densityVarName = "p50_ua_dens";                             % Name
densityLevels = {"Below median experienced density", ...    % Levels
                 "Above median experienced density"};

% Separate unique combinations that do not depend on the density variable
exportCombosNoDens = exportCombinations;
exportCombosNoDens.(densityVarName) = [];
exportCombosNoDens = unique(exportCombosNoDens);
numNonDensCombos = height(exportCombosNoDens);

% Sectors to export
sectorsExported = [7, 12, 13];
yLimsSplit{1} = {[-2.3, 0], [-4, 0], [-6, 0]};               % Left tail
yLimsSplit{2} = {[0, 2], [0, 3], [0, 3]};                    % Right tail

% Thresholds for left and right tails
extremeThresholdHigh = 0.9;                                 % Right
extremeThresholdLow = 0.1;                                  % Left
thresholds = [extremeThresholdLow, extremeThresholdHigh];   % Vectors

% Figure parameters
tickStep = 5;                              % Tick step
spacingExponentX = 1.2;                    % Exponent for x-spacing
plotH = 350;
plotW = 900;                        
plotLineThickness= 1.6;                    % Line thickness  
markerStep = 4;                            % Step size for adding markers
extremeRegionColor = 0.93*ones(1, 3);      % Color for extreme region
rectangleColor = 0.8*ones(1, 3);           % Color for box around regions
boxTitleColor = 0.3*ones(1, 3);            % Color for region text
useRunningYLim = false;                    % y-limits determined dynamically

rectangleFirst{1} = [.02 .02 .475 .8];     % Rectangle coords for first plot
rectangleFirst{2} = [.505  .02 .475 .8];
textCoordFirst{1} = [.014 .82 .4 .05];     % Text coords for first plot
textCoordFirst{2} = [.499  .82 .4 .05];

rectangleAfter{1} = [.02 .02 .475 .85];    % Rectangle coords for other plots
rectangleAfter{2} = [.505  .02 .475 .85];
textCoordAfter{1} = [.014 .87 .4 .05];     % Text coords for other plots
textCoordAfter{2} = [.499  .87 .4 .05];

% Plot suptitles
firstLineNoAdjust = 'Confidence Intervals for Extreme Quantiles';

% Reported confidence intervals
% Main text: Jochmans-Weidner and a single extreme interval
ciSets{1}.ciIDs = [1, 3];                     
ciSets{1}.colorField = 'plottingColorBW';
ciSets{1}.titleTail = '';
ciSets{1}.gaussK = 1;

% OA: one color plot per method 
ciSets{2}.ciIDs = 1;
ciSets{2}.colorField = 'plottingColor';
ciSets{2}.titleTail = '_only_centr-jw';
ciSets{2}.gaussK = 5;

ciSets{3}.ciIDs = 2;
ciSets{3}.colorField = 'plottingColor';
ciSets{3}.titleTail = '_only_centr-binom';
ciSets{3}.gaussK = 5;

ciSets{4}.ciIDs = 3;
ciSets{4}.colorField = 'plottingColor';
ciSets{4}.titleTail = '_only_extr-sim';
ciSets{4}.gaussK = 5;

ciSets{5}.ciIDs = 4;
ciSets{5}.colorField = 'plottingColor';
ciSets{5}.titleTail = '_only_extr-sub';
ciSets{5}.gaussK = 5;

ciSets{6}.ciIDs = 5;
ciSets{6}.colorField = 'plottingColor';
ciSets{6}.titleTail = '_only_interm-extr';
ciSets{6}.gaussK = 5;

ciSets{7}.ciIDs = 6;
ciSets{7}.colorField = 'plottingColor';
ciSets{7}.titleTail = '_only_interm-norm';
ciSets{7}.gaussK = 5;
 

% Confidence interval patch
% Empirical estimation on remote has slightly different styles for 
% confidence intervals. These need to be patched to align with the styles 
% used in the simulation study.
 
% Central: Binomial CI with no correction 
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

% Central: normal approximation with debiasing (JW 2024)
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

% Extreme: subsampling with denominator tuning parameter (q) fixed
% Fitting function
fitExtrFixedQ = @(thetaEsts, targetQuantiles, varEsts, T) ...
    extremeSubsamplingEstCI(thetaEsts, targetQuantiles, alphaCI, ...
    "match", 2, 'MV', numSubsamples); 
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

% Extreme: simulated critical values with the PWM EV index estimator
% Fitting function
fitExtrFixedQSim = @(thetaEsts, targetQuantiles, varEsts, T) ...
    extremeSimulationEstCI(thetaEsts, targetQuantiles, alphaCI, ...
        "match", 4, numBootstrapSamples);
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

% Intermediate: asymptotic normality
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

% Intermediate: extrapolation-based
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

% Combine the methods into a single cell array
patchedCI = {methodArrayCentralJW, methodArrayCentralBinomial, ...
    methodArrayExtremeSimFixedQ, methodArrayExtremeSubsampFixedQ, ...
    methodArrayIntermediateExtr, methodArrayIntermediateNormal};