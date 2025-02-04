% ===========================================================
% File: setPlottingParameters.m
% Description: This script sets parameters related to figure creation
%
% ===========================================================
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
%
% ===========================================================

% Set text interpreters to latex
set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultTextInterpreter', 'latex'); 
  
% Line parameters 
plotLineThickness= 1.6;     % Line thickness 
colorMode = 'color';        % Colormode: 'color' or 'BW'
destination = 'OA';         % Destination: 'OA' or 'main'
markerStep = 4;             % Step size for adding markers

% X-axis parameters
spacingExponent= 1.2;       % Exponent for x-axis logarithmic scaling
spacingStep = 10;           % Step size for x-axis ticks

% Dimension parameters
plotW = 800;
plotH = 270;
plotWsel = 1000;
plotHall = 400;
plotHMae = 700;
plotHallCoverages = 550;
plotRatioAllCoverages = 1.8;
plotWallCoverages= plotRatioAllCoverages*plotHallCoverages;