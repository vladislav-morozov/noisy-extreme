% ===========================================================
% File: weibullInverse.m
% Description: the quantile function of a Weibull-like distribution with
% finite endpoint and given polynomial decay rate
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
% ===========================================================

function weibullQuantiles = weibullInverse(y, thetaF, alpha)
% weibullInverse Evaluate the  yth quantile of a CDF with finite
% endpoint thetaF which decays as (theta-thetaF)^alpha close to the
% endpoint
%
% Args:
%   y: vector of quantiles to return
%   thetaF: scalar parameter, right endpoint of the distribution
%   kappa: scalar tail parameter, tail decays at rate (1/alpha)
%
% Returns:
%   frechetQuantiles: vector containing the yth quantiles of Frechet
%                     distribution with parameter kappa

    weibullQuantiles =  thetaF-thetaF.*(1-y).^(1/alpha);
end