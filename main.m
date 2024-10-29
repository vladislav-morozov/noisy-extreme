% ===========================================================
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% File: main.m
% Developed by: Vladislav Morozov
% Contact: Vladislav Morozov (vladislav.morozov (at) barcelonagse.eu)
%
%
% Description:
%   This script runs the simulations on confidence intervals for extreme
%   quantiles. 
%
%
% Link to paper:  
% Link to the appendix: 
% 
%
% MATLAB Version:
%   Tested with MATLAB R2024b
% 
%
% Instructions:
%   - Ensure that
%   - Run this script to execute the entire simulation.
%
% Outputs:
%   - The results of the simulation are saved in the 'results' folder.
%   - Figures and plots are saved in the 'results/figures' folder.
% ===========================================================
%% Initialization

% Clear workspace
clc
clear variables
close all

% Load the required folders
addpath('classes') % implemented classes
addpath('config') % setting simulation parameters
addpath('confidenceIntervals') % implemented CI and estimator methods
addpath('distributions') % Data generating processes
addpath('simulationScriptsFunctions') % Scripts for running simulations
addpath('plotting') % Scripts for generating figures
addpath('utilities') % further useful scripts and functions

%% Simulation configuration
 
% Set the random number generator
rng(1,'multFibonacci')
 

% Sample sizes
Ns = [200, 2000];
Ts = [10, 20, 50];

% Confidence interval parameter
alphaCI = 0.05; 

% Target quantiles
targetQuantiles = [0.9:0.005:0.99, 0.9905:0.0005:1];

% Exporting result
plotQuietly = 0; % if 0, export figures without opening them 



%% Specifying the data generating distributions
% The model considered is y_{it} = \theta_i'x_{it} + u_{it}

% Number of covariates
constantIncluded = 1; % First x_{it} is set equal to 1
numCov = 3; % Total number of covariates, including the constant

% Generating process for (x, theta)
sigmaSqX = 1; % Variance of x
rhoTheta = 0.5; % Correlation between individual coordinates of theta
rhoXtheta = 0.5; % Correlation between x and theta

numSamples = 5000; % number of replication samples
numSubsamples = 5e3; % number of subsamples   
numBootstrapSamples = 1e3        ; % number of bootstrap samples





 
   

%% Block 1: comparison of extreme, intermediate, central methods

% Load in the distributions for theta and u
setDGP

% Load in methods
setConfidenceIntervalMethods
 
% Run the simulation
simulateCoverages

% Export plots


%% Block 2: impact of choice of the tuning parameter in the denominator
 

%% Block 3: quality of approximation in the feasible IVT 