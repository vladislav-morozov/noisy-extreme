function [y, x, thetaS, u] =noisyExtreme_linearModelDrawData(N, T, constantIncluded, numCov, thetaSampler, uSampler, sigmaSqX, rhoTheta, rhoXtheta) 
% noisyExtreme_linearModelDrawData Draw data from linear model y=theta'*x
% Data format -- TxN, rows index time, N indexes units

    % Draw coefficients and data x from a Gaussian copula with covariance
    % matrix of the form [I+rhoTheta, rhoXtheta; I+rhoX 1, rhoXtheta]
    % (constant correlations)
    % Covariates have to be correlated within periods, but not between
    % periods. To ensure correct correlation, we draw each history of x at
    % once.
    
%     xSampler = @(u)  norminv(u, 0, 1);
    xSampler = @(u)  0.1+u; % uniform sampler offset by 0.1 to ensure existence of moments
    
    % Covariance matrix of coefficients
    Rho =   eye(numCov) + rhoTheta*(ones(numCov)-eye(numCov));
    % Draw theta from Gaussian copula with covariance Rho
    uCoef = copularnd('Gaussian',Rho, N);
    thetaS = thetaSampler(uCoef);
    
    % Draw x with given xSampler
    x = zeros(T, N, numCov);
    % Draw x
    sigmaSqX = 7;
    for t=1:T
        for i=1:N
            x(t, i, :) = rhoXtheta*thetaS(i,:) + sqrt(sigmaSqX*(1+rhoXtheta*norm(thetaS(i,:))))...
                *xSampler(rand(1, numCov));
        end
    end
    % Included a constant if needed
    if constantIncluded ~=0
        x(:, :, 1) = ones(T, N); % replace first coordinate by constant
    end
    
    % Draw noise independently
    u = uSampler(rand(T, N));

    % Generate y
    y = sum(x.*reshape(thetaS, [1, N , numCov]), 3)+u;
end