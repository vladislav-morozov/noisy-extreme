function G = noisyEndpoint_InfiniteEndpointPowerCDF(y, beta )
% noisyEndpoint_FiniteEndpointPowerCDF Evaluate the CDF with finite
% endpoint thetaF which decays as 1-(x-1)^beta close to the
% endpoint

    G =  (1-1/2.*(y+1).^(-beta)).*(y>=0)+ 1/2.*((abs(y)+1)).^(-beta).*(y<0);

end