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
addpath('classes') 
addpath('config') 
addpath('confidenceIntervals')
addpath('distributions')
addpath('simulationScriptsFunctions') 
addpath('utilities') % further useful scripts 

%% Simulation configuration
 
% Set the random number generator
rng(1,'multFibonacci')
 

% Sample sizes
Ns = 200;
Ts = [10, 50];

% Confidence interval parameter
alphaCI = 0.05; 

% Target quantiles
targetQuantiles = [0.9:0.005:0.99, 0.9905:0.0005:1];

% Exporting result
plotQuietly = 0; % if 0, export figures without opening them 
spacingExponent= 1.2; % what does this do?


%% Specifying the data generating distributions
% The model considered is y_{it} = \theta_i'x_{it} + u_{it}

% Number of covariates
constantIncluded = 1; % First x_{it} is set equal to 1
numCov = 3; % Total number of covariates, including the constant

% Generating process for (x, theta)
sigmaSqX = 1; % Variance of x
rhoTheta = 0.5; % Correlation between individual coordinates of theta
rhoXtheta = 0.5; % Correlation between x and theta

% Load in the distributions for theta and u
setDGP


% 


% T is set below when calling the simulation file
Tmult = 1; % the exponent multiplying default T sizes


 
qSubsampling=2; % statistic for feasible EVT 
qSimulation = 3;
sC = 1; % tuning parameter for central variance estimations
numSamples = 100; % number of replication samples
nSubsamples = 1e4; % number of subsamples   
numBootstrapSamples = 1e3        ; % number of bootstrap samples


%  Load in the confidence intervals
 
setConfidenceIntervalMethods

%% Simulate

simulateCoverages



%% OLD CALL 
for j=3:3
    for t=1:3
        % 
        thetaDistrChoice = j;
        uDistrChoice = t;
        if j==1
            T= Tmult*10;
        else
            T = Tmult*15;
        end
        simulateCoverages
    end
end


%% Recompute intermediate intervals


for j=1:3
    for t=1:3
        % 
        thetaDistrChoice = j;
        uDistrChoice = t;
        if j==1
            T= Tmult*10;
        else
            T = Tmult*15;
        end
        noisyExtreme_simulateIntermediate
    end
end


%% Export plots

for j=1:3
    for t=1:3
        thetaDistrChoice = j;
        uDistrChoice = t;
        if j==1
            T= Tmult*10;
        else
            T = Tmult*15;
        end
        noisyExtreme_exportPlots
    end
end
beep


