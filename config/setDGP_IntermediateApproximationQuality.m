
% ===========================================================
% File: setDGP_IntermediateApproximationQuality.m
%
% Description: This script implements the data generating processes for the
% unobserved coefficients theta and the unobserved shocks u used in the
% additional simulation study about the approximation quality in the
% feasible intermediate extreme order theorem
% 
% Notes:
%  1. Each DGP must be an instance of the dataSampler class
%  2. Names of theta distributions must start with thetaSampler; names of
%     shocks distributions must start with uSampler.  
%  3. All of the DGPs with appropriate names will be used for simulations.
%  4. All specified sample sizes will be used
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
%
% ===========================================================

%% Clear the environment of samplers
clear thetaSampler* uSampler*

%% Sample sizes

Ns = [200, 2000, 8000, 16000, 32000];
% Any value larger than 4 will yield the same results
Ts = 10;

%% Theta: Student with three degrees of freedom (Müller, Wang 2017)

studentQuantiles = @(u, nu) tinv(u, nu);
studentParam = 3; % approximately three finite moments

% Create instance
thetaSamplerStudent = dataSampler(studentQuantiles, ...
    "student", 'Student(3)', ...
    "nu", "\nu", studentParam, ...
    1, false); % infinite right tail
 
%% Shocks: noiseless

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
 