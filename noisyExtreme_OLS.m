function [thetaHat] = noisyExtreme_OLS(y, x)
    % linearDynamicEstimators Constructs the collection of individual
    % estimators for the linear model from data,
    % Inputs: x is TxNxk array, y is a TxN array
    % Output: Nxk array of estimates thetaHat
    
    [~, N, numCov] = size(x);
    thetaHat = zeros(N, numCov);
    for i=1:N
        thetaHat(i, :) = (squeeze(x(:,i,:))\y(:,i))';
    end
end