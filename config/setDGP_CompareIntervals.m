% ===========================================================
% File: setDGP_CompareIntervals.m
%
% Description: This script implements the data generating processes for the
% unobserved coefficients theta and the unobserved shocks u used in the
% main comparison simulation
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

%% Theta: Frechet distribution

% Set quantile function and parameter value to use
frechetQuantiles = @(u, kappa) frechetInverse(u, kappa);
frechetParam = 4; % approximately four finite moments

% Create instance
thetaSamplerFrechet = dataSampler(frechetQuantiles, ...
    "frechet", 'F_{Fr, \kappa}', ...
    "kappa", "\kappa", frechetParam, ...
    1, false); % infinite right tail

%% Theta: Student with four degrees of freedom (Müller, Wang 2017)

studentQuantiles = @(u, nu) tinv(u, nu);
studentParam = 3; % approximately three finite moments

% Create instance
thetaSamplerStudent = dataSampler(studentQuantiles, ...
    "student", 'Student(3)', ...
    "nu", "\nu", studentParam, ...
    1, false); % infinite right tail

%% Theta: standard exponential

% Set quantile function and parameter value to use
gumbelQuantiles = @(u, lambda) expinv(u, lambda); 
gumbelParam = 1; 

% Create instance
thetaSamplerGumbel = dataSampler(gumbelQuantiles, ...
    "gumbel", 'F_{Gu, \lambda}', ...
    "lambda", "\lambda", gumbelParam, ...
    0, false); % infinite right tail with gamma = 0

%% Theta: Weibull-type
 
% Set quantile function and parameter value to use
weibullQuantiles = @(u, alpha)  ...
    weibullInverse(u, 10, alpha);
weibullParam = 4; 

% Create instance
thetaSamplerWeibull = dataSampler(weibullQuantiles, ...
    "weibull", 'F_{W, \alpha}', ...
    "alpha", "\alpha", weibullParam, ...
    -1, true); % infinite right tail

%% Shocks: two-sided Frechet (G_beta) distribution

% Set quantile function and parameter value to use
gBetaInverse = @(u, beta) twoSidedPowerInverse(u, beta);
gBetaParam = 8; % 8 finite moments for the noise

% Create instance 
uSamplerGBeta = dataSampler(gBetaInverse, ...
    "GBeta", 'G_{\kappa}', ...
    "beta", "\beta", gBetaParam, ...
    1, false); % infinite right tail  

%% Shocks: normal noise

% Set quantile function and parameter value to use
normInverse = @(u, sigma) norminv(u, 0, sigma);
normParam = 1; % irrelevant, will be rescaled to match var of coefs

% Create instance 
uSamplerNormal = dataSampler(normInverse, ...
    "normal", 'N(0, \sigma^2)', ...
    "sigma", "\sigma", normParam, ...
    0, false); % infinite right tail with gamma=0

%% Shocks: noiseless setting

% Set quantile function and parameter value to use
noiselessInverse = @(u, zero) 0;
noiselessParam = 0;  

% Create instance 
uSamplerNoiseless = dataSampler(noiselessInverse, ...
    "noiseless", 'Noiseless', ...
    "no", "", noiselessParam, ...
    -1, false); % finite right tail  

%% Collect distributions into cell arrays

% Collect all defined distributions for theta
thetaDistrsArray = findAndCollect('thetaSampler');

% Collect all defined distributions for u
uDistrsArray = findAndCollect('uSampler');
 