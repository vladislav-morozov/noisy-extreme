% ===========================================================
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% File: main.m
% Developed by: Vladislav Morozov
% Contact: Vladislav Morozov (vladislav.morozov (at) barcelonagse.eu)
%
%
% Description:
%   This script runs the main simulation for the project "Project Title".
%   It calls all required functions and scripts to perform the necessary
%   computations and generate the results.
%
%
% Link to paper: https://arxiv.org/abs/2210.14205
% Link to the appendix: 
% https://vladislav-morozov.github.io/files/1_unitAveragingSupplement.pdf
% 
%
% MATLAB Version:
%   Tested with MATLAB R2024b
% 
%
% Instructions:
%   - Ensure that all required data files are located in the 'data' folder.
%   - Ensure that all required functions are located in the 'src' folder.
%   - Run this script to execute the entire simulation.
%
% Outputs:
%   - The results of the simulation are saved in the 'results' folder.
%   - Figures and plots are saved in the 'results/figures' folder.
%
%
%
% Paper URL:
%   https://arxiv.org/abs/2210.08524
% Supplementary appendix:
%
% Project URL:
%   Add a link to your project repository or documentation.


% Last updated: 10.10.2024

%% Initialization

% Clear workspace
clc
clear variables
close all

% Load the required folders
addpath('config') 
addpath('simulationScriptsFunctions') 

%% Simulation configuration
 
% Set the random number generator
rng(1,'multFibonacci')

% Exporting result
plotQuietly = 0; % if 0, export figures without opening them 
spacingExponent= 1.2; % what does this do?

% Load data-generating processes
setDGP

% 
% Sample sizes
N = 200;    
% T is set below when calling the simulation file
Tmult = 1; % the exponent multiplying default T sizes

% Simulation parameters
alphaCI = 0.05; % CI
 
qSubsampling=2; % statistic for feasible EVT 
qSimulation = 3;
sC = 1; % tuning parameter for central variance estimations
nSamples = 100; % number of replication samples
nSubsamples = 1e4; % number of subsamples   
nBootstrap = 1e3        ; % number of bootstrap samples

 

%% Simulate

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


