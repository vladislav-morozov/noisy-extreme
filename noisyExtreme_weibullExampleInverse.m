function Q = noisyExtreme_weibullExampleInverse(y, thetaF, alpha )
% noisyExtreme_weibullExampleInverse Evaluate the  yth quantile function of CDF with finite
% endpoint thetaF which decays as (theta-thetaF)^alpha close to the endpoint

    Q =  thetaF-thetaF.*(1-y).^(1/alpha);

end