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

% Thresholds for left and right tails
extremeThresholdHigh = 0.9;                                 % Right
extremeThresholdLow = 0.1;                                  % Left
thresholds = [extremeThresholdLow, extremeThresholdHigh];   % Vectors

% Figure parameters
tickStep = 5;
spacingExponentX = 1.2;
plotH = 300;
plotW = 1200;
extremeRegionColor = 0.93*ones(1, 3);      % Color for extreme region

% Reported confidence intervals
ciIDsToPlot = [1, 3];
 