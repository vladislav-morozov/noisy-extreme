% ===========================================================
% File: frechetInverse.m
% Description: the quantile function of the Frechet distribution with
% parameters kappa
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
%
% ===========================================================

function frechetQuantiles = frechetInverse(y, kappa)
%FRECHETINVERSE Evaluate the  yth quantile function of Frechet distribution
% 
% Args:
%   y: vector of quantiles to return
%   kappa: scalar tail parameter, tail decays at rate -(1/kappa)
%
% Returns:
%   frechetQuantiles: vector containing the yth quantiles of Frechet
%                     distribution with parameter kappa

    frechetQuantiles =  (1-y).^(-1/kappa)-1;
end