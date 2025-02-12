% ===========================================================
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% File: main.m
% Developed by: Vladislav Morozov
% Contact: Vladislav Morozov (morozov (at) uni-bonn.de)
% ===========================================================
%
% Description:
%   This script runs the simulations on confidence intervals for extreme
%   quantiles. 
%
% Usage: 
%   To reproduce the full set of simulation results, execute this script 
%   directly. The script will generate all necessary outputs, including 
%   figures and tables, which are automatically saved to the 'results' 
%   folder.
%
% Output: 
%   - The results of the simulation are saved in the 'results/simulation' 
%     folder.
%   - Figures and plots are saved in the 'results/figures' folder.
%
% For simulation design and overall background on unit averaging:
%  - Link to paper: 
%     arxiv.org/abs/2210.08524 
%  - Link to the appendix: 
%     vladislav-morozov.github.io/assets/files/2_noisyExtremeSupplement.pdf
% 
% Software Requirements:
%   - MATLAB (tested on R2024b). 
%   - Toolboxes: 
%       - Parallel Computing Toolbox (used for simulation speed-up). 
%   - Additional File Exchange Dependencies:
%       - `table2latex` (for LaTeX table generation). 
%       - `tight_subplot` (for subplot layout optimization). 
%         Both dependencies are provided in the replication package.
%
% ===========================================================

%% Initialization

% Clear workspace
clc
clear variables
close all

% Load the required folders
addpath(genpath('src')) % implemented classes
addpath(genpath('scripts')) % implemented classes

%% Simulation configuration
 
% Set the random number generator
rng(1,'multFibonacci')
 
% Sample sizes
Ns = [200, 2000, 10000];
Ts = [10, 20, 50];

% Confidence interval parameter
alphaCI = 0.05; 

% Target quantiles
targetQuantiles = [0.9:0.005:0.99, 0.9905:0.0005:1]; 

%% Specifying the data generating distributions
% The model considered is y_{it} = \theta_i'x_{it} + u_{it}

% Number of covariates
constantIncluded = 1;  % First x_{it} is set equal to 1
numCov = 3;            % Total number of covariates, including the constant

% Generating process for (x, theta)
sigmaSqX = 1;          % Variance of x
rhoTheta = 0.5;        % Correlation between coordinates of theta
rhoXtheta = 0.5;       % Correlation between x and theta

numSamples = 3334;           % number of replication samples
numSubsamples = 5e3;          % number of subsamples   
numBootstrapSamples = 1e3;    % number of bootstrap samples

%% Block 1: comparison of extreme, intermediate, central methods

% Load in the distributions for theta and u
setDGP_CompareIntervals

% Load in methods
setConfidenceIntervalMethods_CompareIntervals
 
% Run the simulation
simContext = "methods";
plotContext = simContext; 

simulateCoverages

% Export plots
exportComparisonPlots

%% Block 2: impact of choice of the tuning parameter in the denominator

% Load in DGPs
setDGP_ExtremeTuningParameters

% Load in confidence intervals (extreme approximations)
setConfidenceIntervalMethods_ExtremeTuningParameters
simContext = "tuningParameter";
plotContext = simContext; 
simulateCoverages

% Export figures
exportComparisonPlots

%% Block 3: impact of choice of the tuning parameter in the numerator

% Load in DGPs
setDGP_ExtremeTuningParameters

% Load in confidence intervals (extreme approximations)
setConfidenceIntervalMethods_ExtremeNumeratorParameter
simContext = "numeratorTuningParameter";
plotContext = simContext;
simulateCoverages

%% Block 4: quality of approximation in the feasible IVT 

% Load in DGPs
setDGP_IntermediateApproximationQuality

% Set simulation name
simContext = "intermediateQuality";
plotContext = simContext;

% Run simulation
simulateIVTNormality

% Export figures
exportIntermediateFitPlots