function Q = noisyExtreme_frechetInverse(y, kappa)
% noisyExtreme_frechetInverse Evaluate the  yth quantile function of CDF with infinite
% endpoint thetaF which decays as 1-(x+1)^(-kappa)

    Q =  (1-y).^(-1/kappa)-1;
end