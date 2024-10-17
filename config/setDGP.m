% ===========================================================
% File: setDGP.m
% Description: This script implements the data generating processes for the
% unobserved coefficients theta and the unobserved shocks u. It also
%
% Model:
%
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
%
% Implemented DGPs: "unimodal", "bimodal", "bimodal_close"
% If a list of DGPs is supplied, all of them will be ran in turn.
% ===========================================================


%%  Distributions for thetas
% All parameters have to be specified first

% Marginals for theta
thetaDistribution{1} = @(kappa, u) noisyExtreme_frechetInverse(u, kappa) ; % Frechet
thetaDistribution{2} = @(lambda, u) expinv(u, lambda);  % Gumbel
thetaDistribution{3} = @(alpha, u) noisyExtreme_weibullExampleInverse(u, 10, alpha);  % Gumbel   % Weibull

% Parameter values used, must follow the same order as specified in the
% distribution array
thetaDistributionParam{1} = 4; % kappa, parameter for power law tail
thetaDistributionParam{2} = 1; % lambda, parameter of exponential distr
thetaDistributionParam{3} = 4; % alpha, parameter for finite tail
   

% Marginals for u_{it}
uDistribution{1} = @(sigma, u) norminv(u, 0, sigma); % Normal
uDistribution{2} = @(beta, u) noisyEndpoint_InfiniteEndpointPowerInverse(u, beta); % Normal
uDistribution{3} = @(zero, u) 0; % Noiseless data

uDistributionParam{1} = 1; % does not matter, variance is rescaled to match the coefficients in the simulation
uDistributionParam{2} = 8;
uDistributionParam{3} = 0; % Dummy parameter for convenience of coding

% Save sign of gamma
gammaSign{1} = 1;
gammaSign{2}=0;
gammaSign{3}=-1;


%% Quantiles considered
quantilesConsideredArray{1} = [0.9:0.005:0.99, 0.9905:0.0005:0.999]; % this kills the 0.85 quantile
quantilesConsideredArray{2} = [0.9, 0.9:0.005:0.99, 0.9905:0.0005:0.999];
quantilesConsideredArray{3} = [0.9, 0.9:0.005:0.99, 0.9905:0.0005:1]; % Finite endpoint


% Names to construct the title
thetaName{1} = 'F_{Fr, \kappa}';
thetaName{2} = 'F_{Gu, \lambda}';
thetaName{3} = 'F_{W, \alpha}';
thetaParamName{1} = '\kappa';
thetaParamName{2}= '\lambda';
thetaParamName{3}= '\alpha';


uName{1} = 'N(0, \sigma^2)';
uName{2} = 'G_{\beta}';
uName{3} = '0';

uParamName{1} = '\sigma^2';
uParamName{2} = '\beta';
uParamName{3} = '';

% Names to save
thetaNameSave{1} = 'Fr';
thetaNameSave{2} = 'Gu';
thetaNameSave{3} = 'W';
thetaParamNameSave{1} = 'kappa';
thetaParamNameSave{2}= 'lambda';
thetaParamNameSave{3}= 'alpha';
uNameSave{1} = 'Normal';
uNameSave{2} = 'Gbeta';
uNameSave{3} = 'Noiseless';
uParamNameSave{1} = 'sigmaSq';
uParamNameSave{2} = 'beta';
uParamNameSave{3} = '';


%% X
% Number of covariates
constantIncluded = 1;
numCov = 3;

% Generating process for (x, theta)
sigmaSqX = 1; % variance of x
rhoTheta = 0.5; % correlation between coordinates of theta
rhoXtheta = 0.5; % x is generated as rhoXtheta*theta+(1+rhoXtheta*||theta||)*sigmaSqX*Distr of X
