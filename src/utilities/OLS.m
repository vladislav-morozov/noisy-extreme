function [thetaHat, varianceEstimates] = OLS(y, x)
    % OLS Constructs the collection of individual estimators for the 
    % linear model from data. Data: columns index units, rows index
    % individual observations. Third dimension of x indexes different
    % covariates. 
    % 
    % Note: third dimension of varianceEstimates indexes units.
    %
    % Args:
    %   y (TxN matrix): response variable
    %   x (TxNxk matrix): predictor variables
    %
    % Returns:
    %   thetaHat (Nxk matrix): matrix of estimates
    %   varianceEstimates (kxkxN array) estimated variances of thetaHat

    % Obtain data sizes
    [T, N, numCov] = size(x);

    % Allocate space for coefficient estimates
    thetaHat = zeros(N, numCov);

    % Run OLS unit-by-unit
    for i = 1:N
        thetaHat(i, :) = (squeeze(x(:, i, :)) \ y(:, i))';
    end

    % Allocate space for variance estimates
    varianceEstimates = zeros(numCov, numCov, N);
    sigmaHatSq = zeros(N, 1);

    % Construct estimates using cross-sectional homoskedasticity
    for i = 1:N
        H = squeeze(x(:, i, :));
        errorsVectorI = y(:, i) - H * thetaHat(i, :)';
        sigmaHatSq(i) = errorsVectorI' * errorsVectorI / (T - numCov);
        varianceEstimates(:, :, i) = (H' * H) \ eye(numCov) * sigmaHatSq(i);
    end
end
