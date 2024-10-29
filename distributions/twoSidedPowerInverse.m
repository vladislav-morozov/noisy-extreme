% ===========================================================
% File: twoSidedPowerInverse.m
% Description: the quantile function of the symmetric two-sided power law
% distribution 
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
% ===========================================================

function Q = twoSidedPowerInverse(y, beta)
% twoSidedPowerInverse Evaluate the yth quantile function of CDF with 
% two infinite tails decay as 1-(x+1)^(-beta).
%
% Args:
%     y: Vector of quantiles to return.
%     beta: Scalar parameter controlling the decay rate.
%
% Returns:
%     Q: Vector containing the yth quantiles of the two-sided power
%        distribution with parameter beta.

    % Evaluate the quantile function based on the value of y
    Q = ((2.*(1-y)).^(-1/beta)-1).*(y>=1/2) + ...
        (-(2.*y).^(-1/beta)+1).*(y<1/2);
end