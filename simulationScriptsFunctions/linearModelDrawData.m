% ===========================================================
% File: linearModelDrawData.m
% Description: draws data for a heterogeneous linear model
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
% ===========================================================
function [y, x, trueTheta, u] = ...
    linearModelDrawData(N, T, constantIncluded, ...
    numCov, thetaSampler, uSampler, sigmaSqX, rhoTheta, rhoXtheta)
% LINEARMODELDRAWDATA Draws data from a linear model y = theta' * x.
%
% Data format -- TxN, rows index time, N indexes units.
%
% Args:
%     N (int): Number of units.
%     T (int): Number of time periods.
%     constantIncluded (logical): Whether to include a constant term.
%     numCov (int): Number of covariates.
%     thetaSampler (dataSampler): dataSampler describing theta distribution
%     uSampler (dataSampler): dataSampler describing shock distribution
%     sigmaSqX (float): Variance of the covariates.
%     rhoTheta (float): Correlation coefficient for theta.
%     rhoXtheta (float): Correlation coefficient between x and theta.
%
% Returns:
%     y (matrix): Generated dependent variable.
%     x (3D array): Generated covariates.
%     trueTheta (matrix): Sampled theta coefficients.
%     u (matrix): Sampled noise.

    % Uniform sampler offset by 0.1 to ensure existence of moments
    xSampler = @(u) 0.1 + u;

    % Covariance matrix of coefficients
    Rho = eye(numCov) + rhoTheta * (ones(numCov) - eye(numCov));

    % Draw coefficients using a Gaussian copula with covariance Rho
    uCoef = copularnd('Gaussian', Rho, N);
    trueTheta = thetaSampler.distrInverse(uCoef, thetaSampler.paramValue);

    % Initialize x
    x = zeros(T, N, numCov);

    % Draw x for each time period and unit
    for t = 1:T
        for i = 1:N
            x(t, i, :) = rhoXtheta * trueTheta(i, :) + 10 *...
                sqrt(sigmaSqX * (1 + rhoXtheta * norm(trueTheta(i, :)))) * ...
                xSampler(rand(1, numCov));
        end
    end

    % Include a constant if needed
    if constantIncluded ~= 0
        x(:, :, 1) = ones(T, N); % Replace first coordinate with constant
    end

    % Draw noise independently
    u = uSampler.sample([T, N]);

    % Generate y
    y = sum(x .* reshape(trueTheta, [1, N, numCov]), 3) + u;
end
