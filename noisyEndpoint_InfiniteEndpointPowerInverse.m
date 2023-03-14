function Q = noisyEndpoint_InfiniteEndpointPowerInverse(y, beta )
% noisyEndpoint_FiniteEndpointPowerInverse Evaluate the  yth quantile function of CDF with infinite
% endpoint thetaF which decays as 1-(x+1)^(-beta)

    Q =  ( (2.*(1-y)).^(-1/beta)-1).*(y>=1/2) + ( -(2.*y).^(-1/beta)+1).*(y<1/2)  ;
end