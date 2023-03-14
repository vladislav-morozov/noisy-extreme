function [y, x, thetaS, u] =noisyExtreme_linearModelDrawData(N, T, constantIncluded, numCov, thetaSampler, uSampler, rhoX, rhoTheta, rhoXtheta) 
% noisyExtreme_linearModelDrawData Draw data from linear model y=theta'*x
% Data format -- TxN, rows index time, N indexes units

    % Draw coefficients and data x from a Gaussian copula with covariance
    % matrix of the form [I+rhoTheta, rhoXtheta; I+rhoX 1, rhoXtheta]
    % (constant correlations)
    % Covariates have to be correlated within periods, but not between
    % periods. To ensure correct correlation, we draw each history of x at
    % once.
    
    xSampler = @(u) norminv(u, 0, 1);
    
    % Initialize at no correlation
    Rho = eye(numCov*(T+1)); 
    % First block is theta
    Rho(1:numCov, 1:numCov) =   Rho(1:numCov, 1:numCov) + rhoTheta*(ones(numCov)-eye(numCov));
   
    for t=1:T
        % intra-period block
        Rho(t*numCov+1:(t+1)*(numCov), t*numCov+1:(t+1)*(numCov)) =...
             Rho(t*numCov+1:(t+1)*(numCov), t*numCov+1:(t+1)*(numCov))...
             + rhoX*(ones(numCov)-eye(numCov));
         
         % Correlation with coefficients
        Rho(t*numCov+1:(t+1)*(numCov), 1:numCov) = rhoXtheta*ones(numCov);
        Rho(1:numCov, t*numCov+1:(t+1)*(numCov)) = rhoXtheta*ones(numCov);
    end
    
    
    % Draw x and theta from a Gaussian copula with covariance Rho
    % N rows, each contains full history of X
    uDraw = copularnd('Gaussian',Rho, N);
    
    % Draw coefficients with given thetaSampler
    uCoef = uDraw(:, 1:numCov); % Coefficients
    thetaS = thetaSampler(uCoef);
    
    % Draw x with given xSampler
    x = zeros(T, N, numCov);
    % Draw x
    for t=1:T
        for i=1:N
            x(t, i, :) = xSampler(uDraw(i, t*numCov+1:(t+1)*numCov));
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