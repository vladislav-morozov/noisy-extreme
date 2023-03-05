function gammaHat = noisyExtreme_EVindexGeneralizedPickands(thetaSorted, k)
% noisyExtreme_EVindedGeneralizedPickands Implements the generalized
% Pickands estimator of Segers (2005) with optimaltwo-step weighting scheme

    c = 0.75;
    logc = @(x) log(x)/log(c);
    k = floor(k);
    deltaHat= abs(noisyExtreme_EVindexPickands(thetaSorted, k))-1/2 ; 
    gammaHat =0;
    
    for s=1:k
        jS = floor(logc(s/k));
        jSm = floor(logc((s-1)/k));
        
        if deltaHat ==0
            if s==1 
                % in this case jSm= inf, but t = 0
                gammaHat = gammaHat + (1-c^(1+deltaHat))*jS*s/k*...
                    log(thetaSorted(end-floor(c*s)) - thetaSorted(end-s));
            else
                gammaHat = gammaHat  + (1-c^(1+deltaHat))*(jS*s/k-jSm*(s-1)/k)*...
                log(thetaSorted(end-floor(c*s)) - thetaSorted(end-s));
            end
        else
            if s==1
                % in this case jSm= inf, but t = 0
                gammaHat = gammaHat + (1-c^(1+deltaHat))/(1-c^(deltaHat))*...
                    (1-c^(deltaHat*jS))*s/k*...
                    log(thetaSorted(end-floor(c*s)) - thetaSorted(end-s));
            else
                gammaHat = gammaHat + ((1-c^(1+deltaHat))/(1-c^(deltaHat))*...
                    ((1-c^(deltaHat*jS))*s/k- (1-c^(deltaHat*jSm))*(s-1)/k  ) )*...
                    log(thetaSorted(end-floor(c*s)) - thetaSorted(end-s));
            end
            
        end
        
        
    end
end