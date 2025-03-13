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
legendJoint = {"Below median experienced density (BMD)", ...% Legend labels
                 "Above median experienced density (AMD)"};

% Separate unique combinations that do not depend on the density variable
exportCombosNoDens = exportCombinations;
exportCombosNoDens.(densityVarName) = [];
exportCombosNoDens = unique(exportCombosNoDens);
numNonDensCombos = height(exportCombosNoDens);

% Sectors to export
sectorsExported = [7, 12, 13];
yLimsSplit{1} = {[-3, 0], [-5.4, 0], [-7.5, 0]};               % Left tail
yLimsSplit{2} = {[0, 3], [-.55, 3], [0, 3]};                    % Right tail

% Mean-variance adjustments for the joint plot
adjustMeanVar = [true, false];

% Thresholds for left and right tails
extremeThresholdHigh = 0.9;                                 % Right
extremeThresholdLow = 0.1;                                  % Left
thresholds = [extremeThresholdLow, extremeThresholdHigh];   % Vectors

% Global figure settings
markerStep = 3;                            % Step size for adding markers 
tickStep = 6;                              % Tick step
spacingExponentX = 1.2;                    % Exponent for x-spacing
plotH = 350;                               % Height in pixels
plotW = 900;                               % Width in pixels
plotLineThicknessSplit= 1.6;               % Line thickness (split plot)
plotLineThicknessJoint = 1.3;              % Line thickness (joint plot)
jointMarkerSize = 4;                       % Marker size (join plot
useRunningYLim = false;                    % y-limits determined dynamically

% Regions drawn on the split plot
extremeRegionColor = 0.93*ones(1, 3);      % Color for extreme region
rectangleColor = 0.8*ones(1, 3);           % Color for box around regions
boxTitleColor = 0.3*ones(1, 3);            % Color for region text
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
suptitle{1} = 'Standardized mean and variance';    % joint plot 
suptitle{2} = 'No mean-variance standardization';  % joint plot

% Styles for joint plots
lineStyleJoint{1} = "-.";                            % Line: BMD
lineStyleJoint{2} = "-";                             % Line: AMD
markerStyleJoint{1} = "square";                      % Marker: BMD
markerStyleJoint{2} = "hexagram";                    % Color: AMD
bwJoint{1} = [0.35*ones(1, 3), 0.4];                 % BW: BMD
bwJoint{2} = [0.6*ones(1, 3), 0.4];                  % BW: AMD
colorJoint{1} = [1, 0.65, 0, 0.2];                   % Color: BMD
colorJoint{2} = [0.09, 0.69, 1, 0.2];                % Color: AMD
yLimsJoint{1} = {{[-11.5, 0], [-21, 0], [-26, 0]},...% ylim: adjustment
    {[0, 10], [0, 18.5], [0, 12]}   };
yLimsJoint{2} = yLimsSplit;                          % ylim: no adjustment

%% Confidence interval Setts
% Plots split by AME/BME: setup
% Main text: Jochmans-Weidner and a single extreme interval
ciSetsSplit{1}.ciIDs = [1, 3];                     
ciSetsSplit{1}.colorField = 'plottingColorBW';
ciSetsSplit{1}.titleTail = '';
ciSetsSplit{1}.gaussK = 1;

% OA: one color plot per method 
ciSetsSplit{2}.ciIDs = 1;
ciSetsSplit{2}.colorField = 'plottingColor';
ciSetsSplit{2}.titleTail = '_only_centr-jw';
ciSetsSplit{2}.gaussK = 5;

ciSetsSplit{3}.ciIDs = 2;
ciSetsSplit{3}.colorField = 'plottingColor';
ciSetsSplit{3}.titleTail = '_only_centr-binom';
ciSetsSplit{3}.gaussK = 5;

ciSetsSplit{4}.ciIDs = 3;
ciSetsSplit{4}.colorField = 'plottingColor';
ciSetsSplit{4}.titleTail = '_only_extr-sim';
ciSetsSplit{4}.gaussK = 5;

ciSetsSplit{5}.ciIDs = 4;
ciSetsSplit{5}.colorField = 'plottingColor';
ciSetsSplit{5}.titleTail = '_only_extr-sub';
ciSetsSplit{5}.gaussK = 5;

ciSetsSplit{6}.ciIDs = 5;
ciSetsSplit{6}.colorField = 'plottingColor';
ciSetsSplit{6}.titleTail = '_only_interm-extr';
ciSetsSplit{6}.gaussK = 5;

ciSetsSplit{7}.ciIDs = 6;
ciSetsSplit{7}.colorField = 'plottingColor';
ciSetsSplit{7}.titleTail = '_only_interm-norm';
ciSetsSplit{7}.gaussK = 5;
 
% Plots with joint AME/BME: setup
% Main text: Jochmans-Weidner and a single extreme interval
ciSetsJoint{1}.ciID = 3;                     
ciSetsJoint{1}.colorField = 'plottingColorBW';
ciSetsJoint{1}.titleTail = '';
ciSetsJoint{1}.gaussK = 3;

% OA: one color plot per method 
ciSetsJoint{2}.ciID = 1;
ciSetsJoint{2}.colorField = 'plottingColor';
ciSetsJoint{2}.titleTail = '_only_centr-jw_';
ciSetsJoint{2}.gaussK = 5;

ciSetsJoint{3}.ciID = 2;
ciSetsJoint{3}.colorField = 'plottingColor';
ciSetsJoint{3}.titleTail = '_only_centr-binom_';
ciSetsJoint{3}.gaussK = 5;

ciSetsJoint{4}.ciID = 3;
ciSetsJoint{4}.colorField = 'plottingColor';
ciSetsJoint{4}.titleTail = '_only_extr-sim_';
ciSetsJoint{4}.gaussK = 5;

ciSetsJoint{5}.ciID = 4;
ciSetsJoint{5}.colorField = 'plottingColor';
ciSetsJoint{5}.titleTail = '_only_extr-sub_';
ciSetsJoint{5}.gaussK = 5;

ciSetsJoint{6}.ciID = 5;
ciSetsJoint{6}.colorField = 'plottingColor';
ciSetsJoint{6}.titleTail = '_only_interm-extr_';
ciSetsJoint{6}.gaussK = 5;

ciSetsJoint{7}.ciID = 6;
ciSetsJoint{7}.colorField = 'plottingColor';
ciSetsJoint{7}.titleTail = '_only_interm-norm_';
ciSetsJoint{7}.gaussK = 5;

%% Split plots: confidence interval patch
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
subsamplingFixedDenomSimMarkerSize = 5;
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