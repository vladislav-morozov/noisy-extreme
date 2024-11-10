% ===========================================================
% File: setDGP_CompareIntervals.m
%
% Description: This script implements the data generating processes for the
% unobserved coefficients theta and the unobserved shocks u used in the
% additional simulation study on the impact of tuning parameters in extreme
% approximations
% 
% Notes:
%  1. Each DGP must be an instance of the dataSampler class
%  2. Names of theta distributions must start with thetaSampler; names of
%     shocks distributions must start with uSampler.  
%  3. All of the DGPs with appropriate names will be used for simulations.
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
%
% ===========================================================

%% Clear the environment of samplers
clear thetaSampler* uSampler*

%% Theta: Student with three degrees of freedom (Müller, Wang 2017)

studentQuantiles = @(u, nu) tinv(u, nu);
studentParam = 3; % approximately three finite moments

% Create instance
thetaSamplerStudent = dataSampler(studentQuantiles, ...
    "student", 'Student(3)', ...
    "nu", "\nu", studentParam, ...
    1, false); % infinite right tail
 
%% Shocks: two-sided Frechet (G_beta) distribution

% Set quantile function and parameter value to use
gBetaInverse = @(u, beta) twoSidedPowerInverse(u, beta);
gBetaParam = 8; % 8 finite moments for the noise

% Create instance 
uSamplerGBeta = dataSampler(gBetaInverse, ...
    "GBeta", 'G_{\kappa}', ...
    "beta", "\beta", gBetaParam, ...
    1, false); % infinite right tail  
 

%% Collect distributions into cell arrays

% Collect all defined distributions for theta
thetaDistrsArray = findAndCollect('thetaSampler');

% Collect all defined distributions for u
uDistrsArray = findAndCollect('uSampler');
 