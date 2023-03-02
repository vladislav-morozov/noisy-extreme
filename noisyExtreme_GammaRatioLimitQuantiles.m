function [Qmax, Qq, Qmixed] = noisyExtreme_GammaRatioLimitQuantiles(gammaEst, qSimulation, l,  quantiles)
% noisyExtreme_GammaRatioLimitQuantiles Simulates sample of size sampleSize from a
% gamma ratio limit for feasibly normalized maximum 

        
        % Simulate from the limit distribution
        sampleSize = 2e4;
        
        gammas = exprnd(1, [sampleSize, max(floor(l))+1] );
        gammas1 = gammas(:, 1); % Simulate the Gamma_1 term
        gammasAll = zeros(sampleSize, length(l));
        for k=1:length(l)
           gammasAll(:, k) = gammas1+sum(gammas(:, 2:floor(l(k))+1),2);
        end
        % Simulate gammas q
        gammasQ = sum(gammas(:, 1:qSimulation+1), 2); 
        l  = reshape(l, [1, length(l)]); % ensure l is a row  vector
        if gammaEst~=0
              % Max based approximation
              Zmax =    (gammas1.^(-gammaEst)-l.^(-gammaEst))./(gammasQ.^(-gammaEst)-gammas1.^(-gammaEst) ) ;
              % Changing order in both numerator and denominator
              Zq = (gammasAll.^(-gammaEst)-l.^(-gammaEst))./(gammasAll.^(-gammaEst)-gammas1.^(-gammaEst) ) ;
              % Changing order only in the numerator
              Zmixed =(gammasAll.^(-gammaEst)-l.^(-gammaEst))./(gammasQ.^(-gammaEst)-gammas1.^(-gammaEst) ) ;
          else
              Zmax = (-log(gammas1)  - log(l))./(-log(gammasQ)   + log(gammas1) ) ; 
              Zq = (-log(gammasAll)  - log(l))./(-log(gammasAll)   + log(gammas1) ) ;
              Zmixed = (-log(gammasAll)  - log(l))./(-log(gammasQ)   + log(gammas1) ) ;
        end
        
        % Return quantiles
        Qmax = quantile(Zmax, quantiles);
        Qq  = quantile(Zq, quantiles);
        Qmixed = quantile(Zmixed, quantiles);

end