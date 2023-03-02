


%% Main loop


% Select generating processes and insert all parameters
thetaSampler = thetaDistribution{thetaDistrChoice};
thetaSampler = @(u) thetaSampler(thetaDistributionParam{thetaDistrChoice}, u);   

% Other parameters
quantilesConsidered = quantilesConsideredArray{thetaDistrChoice};
gammaSignChosen = gammaSign{thetaDistrChoice};

%% Simulation loop and plotting


% Prepare vectors fo recording coverage
containsSimulatedMax = zeros(nSamples, length(quantilesConsidered));
containsSimulatedQ = zeros(nSamples, length(quantilesConsidered));
containsSimulatedMixed= zeros(nSamples, length(quantilesConsidered));
containsSimulatedMaxT = zeros(nSamples, length(quantilesConsidered));
containsSimulatedQT = zeros(nSamples, length(quantilesConsidered));
containsSimulatedMixedT= zeros(nSamples, length(quantilesConsidered));
containsTRUEssMax = zeros(nSamples, length(quantilesConsidered));
containsTRUEssMixed= zeros(nSamples, length(quantilesConsidered));

containsSubsampledMax = zeros(nSamples, length(quantilesConsidered));
containsSubsampledq = zeros(nSamples, length(quantilesConsidered));
containsSubsampledMixed = zeros(nSamples, length(quantilesConsidered));
containsIntermediateNormal = zeros(nSamples, length(quantilesConsidered));
containsIntermediateSS = zeros(nSamples, length(quantilesConsidered));
containsNaive = zeros(nSamples, length(quantilesConsidered));
containsDebiased = zeros(nSamples, length(quantilesConsidered));
    
lengthSimulatedMax =  zeros(nSamples, length(quantilesConsidered));
lengthSimulatedQ =  zeros(nSamples, length(quantilesConsidered));
lengthSimulatedMixed=  zeros(nSamples, length(quantilesConsidered));
lengthSimulatedMaxT =  zeros(nSamples, length(quantilesConsidered));
lengthSimulatedQT =  zeros(nSamples, length(quantilesConsidered));
lengthSimulatedMixedT =  zeros(nSamples, length(quantilesConsidered));
lengthSubsampledMax = zeros(nSamples, length(quantilesConsidered));
lengthSubsampledMixed = zeros(nSamples, length(quantilesConsidered));
lengthSubsampledq = zeros(nSamples, length(quantilesConsidered));
lengthIntermediateNormal = zeros(nSamples, length(quantilesConsidered));
lengthIntermediateSS= zeros(nSamples, length(quantilesConsidered));
lengthNaive = zeros(nSamples, length(quantilesConsidered));
lengthDebiased = zeros(nSamples, length(quantilesConsidered));

% Errors
errorSimple = zeros(nSamples, length(quantilesConsidered));
errorCorrectedMax = zeros(nSamples, length(quantilesConsidered));
errorCorrectedq = zeros(nSamples, length(quantilesConsidered));
errorCorrectedMixed = zeros(nSamples, length(quantilesConsidered));
errorCorrectedSIMMax = zeros(nSamples, length(quantilesConsidered));
errorCorrectedSIMq = zeros(nSamples, length(quantilesConsidered));
errorCorrectedSIMMixed = zeros(nSamples, length(quantilesConsidered));
errorCorrectedSIMMaxT = zeros(nSamples, length(quantilesConsidered));
errorCorrectedSIMqT = zeros(nSamples, length(quantilesConsidered));
errorCorrectedSIMMixedT = zeros(nSamples, length(quantilesConsidered));
errorCorrectedJW = zeros(nSamples, length(quantilesConsidered));

% True quantiles
trueQuantiles = thetaSampler(quantilesConsidered);

% Main loop
parfor s=1:nSamples % loop over samples
        
        % Draw coefficients and data in a potentially correlated
        % manner
         Rho =   eye(numCov) + rhoTheta*(ones(numCov)-eye(numCov));
    % Draw theta from Gaussian copula with covariance Rho
        uCoef = copularnd('Gaussian',Rho, N);
        thetaS = thetaSampler(uCoef);
        thetaS = thetaS(:, 2); % second coordinate
        thetaSorted =sort(thetaS);
        maxS = thetaSorted(end);
        maxQS = thetaSorted(end-qSubsampling);   
        maxLS = thetaSorted(ceil(N*quantilesConsidered));
        
        % Estimate variances for the JW correction
        Vest = zeros(1, 1, N); %T*noisyExtreme_OLSvarianceEstimator(y, x, noisyBetaS');
        Vest = squeeze(Vest(1, 1, :));
       
        l = (1-quantilesConsidered)*N; % approximating centering l
        
        
            
        % Critical values by subsampling
        b = (N)^(3/4);
        [critValueSSmax, critValueSSq, critValueSSmixed] = ...
            noisyExtreme_subsamplingCriticalValues(alphaCI, thetaSorted, ...
            qSubsampling, b, nSubsamples, quantilesConsidered);   % subsampled quantiles    
        % Max-based approximation
        ciSubsampledMax =  [maxS - critValueSSmax(1, :)*(maxQS-maxS); ...
             maxS - critValueSSmax(2, :)*(maxQS-maxS)];% fEVT subsampled    
        % Approximation with shifting order statistic 
        ciSubsampledq =  [maxLS' - critValueSSq(1, :).*(maxLS'-maxS); ...
             maxLS' - critValueSSq(2, :).*(maxLS'-maxS)];% fEVT subsampled    
        % Approximation with shifting order statistic in the numerator only
        ciSubsampledMixed =  [maxLS' - critValueSSmixed(1, :).*(maxQS-maxS); ...
             maxLS' - critValueSSmixed(2, :).*(maxQS-maxS)];% fEVT subsampled    
   
        % Quantiles by simulation
        % Select intermediate order for k
        kGamma = floor((N )^(1/3));
        % Computer gamma estimator
        gammaPickands = 1/log(2)*log( (thetaSorted(end-kGamma)-thetaSorted(end-2*kGamma) )...
             /(thetaSorted(end-2*kGamma)-thetaSorted(end-4*kGamma))  );
        gammaTruncated = (sign(gammaPickands)*gammaSignChosen>=0)*gammaPickands;

        % Critical values for Pickands estimator
        [critValueSIMmax, critValueSIMq, critValueSSIMmixed] = ...
            noisyExtreme_GammaRatioLimitQuantiles(gammaPickands, ...
            qSimulation, l, [alphaCI/2, 1-alphaCI/2, 1/2]); % quantiles

                % Max-based approximation
        ciSimulatedMax =  [maxS - critValueSIMmax(1, :)*(maxQS-maxS); ...
             maxS - critValueSIMmax(2, :)*(maxQS-maxS)];%    
        % Approximation with shifting order statistic 
        ciSimulatedQ =  [maxLS' - critValueSIMq(1, :).*(maxLS'-maxS); ...
             maxLS' - critValueSIMq(2, :).*(maxLS'-maxS)];%   
        % Approximation with shifting order statistic in the numerator only
        ciSimulatedMixed =  [maxLS' - critValueSSIMmixed(1, :).*(maxQS-maxS); ...
             maxLS' - critValueSSIMmixed(2, :).*(maxQS-maxS)];    
   
        % Critical values for truncated Pickands  
        [critValueSIMmaxT, critValueSIMqT, critValueSSIMmixedT] = ...
            noisyExtreme_GammaRatioLimitQuantiles(gammaTruncated, ...
            qSimulation, l, [alphaCI/2, 1-alphaCI/2, 1/2]); % quantiles

                % Max-based approximation
        ciSimulatedMaxT =  [maxS - critValueSIMmaxT(1, :)*(maxQS-maxS); ...
             maxS - critValueSIMmaxT(2, :)*(maxQS-maxS)];%    
        % Approximation with shifting order statistic 
        ciSimulatedQT =  [maxLS' - critValueSIMqT(1, :).*(maxLS'-maxS); ...
             maxLS' - critValueSIMqT(2, :).*(maxLS'-maxS)];%   
        % Approximation with shifting order statistic in the numerator only
        ciSimulatedMixedT =  [maxLS' - critValueSSIMmixedT(1, :).*(maxQS-maxS); ...
             maxLS' - critValueSSIMmixedT(2, :).*(maxQS-maxS)];
         
         
        % CIs based on true data 
        [TRUEcritValueSSmax, ~, TRUEcritValueSSmixed] = ...
            noisyExtreme_subsamplingCriticalValues(alphaCI, thetaSorted, ...
            qSubsampling, b, nSubsamples, quantilesConsidered);   % subsampled quantiles    
        % Max-based approximation
        TRUEciSubsampledMax =  [maxS - TRUEcritValueSSmax(1, :)*(maxQS-maxS); ...
             maxS - TRUEcritValueSSmax(2, :)*(maxQS-maxS)];% fEVT subsampled    
         % Approximation with shifting order statistic in the numerator only
        TRUEciSubsampledMixed = [maxLS' - TRUEcritValueSSmixed(1, :).*(maxQS-maxS); 
             maxLS' - TRUEcritValueSSmixed(2, :).*(maxQS-maxS)];% fEVT subsampled    
        
         
        % Median-unbiased estimators 
        correctedEstimatorSSmax =  maxS - critValueSSmax(3, :)*(maxQS-maxS);
        correctedEstimatorSSq =  maxLS' - critValueSSq(3, :).*(maxLS'-maxS);
        correctedEsimatorSSmixed=  maxLS' - critValueSSmixed(3, :).*(maxQS-maxS);
        
        correctedEstimatorSIMmax =  maxS - critValueSIMmax(3, :)*(maxQS-maxS);
        correctedEstimatorSIMq =  maxLS' - critValueSIMq(3, :).*(maxLS'-maxS);
        correctedEsimatorSIMmixed=  maxLS' - critValueSSIMmixed(3, :).*(maxQS-maxS);
        
        correctedEstimatorSIMmaxT =  maxS - critValueSIMmaxT(3, :)*(maxQS-maxS);
        correctedEstimatorSIMqT =  maxLS' - critValueSIMqT(3, :).*(maxLS'-maxS);
        correctedEsimatorSIMmixedT=  maxLS' - critValueSSIMmixedT(3, :).*(maxQS-maxS);
                
        % Save the errors made
        errorSimple(s, :) = trueQuantiles-maxLS';
        errorCorrectedMax(s, :) = trueQuantiles-correctedEstimatorSSmax;
        errorCorrectedq(s, :) = trueQuantiles-correctedEstimatorSSq;
        errorCorrectedMixed(s, :) = trueQuantiles-correctedEsimatorSSmixed;
        
        errorCorrectedSIMMax(s, :) = trueQuantiles-correctedEstimatorSIMmax;
        errorCorrectedSIMq(s, :) = trueQuantiles-correctedEstimatorSIMq;
        errorCorrectedSIMMixed(s, :) = trueQuantiles-correctedEsimatorSIMmixed;
 
        errorCorrectedSIMMaxT(s, :) = trueQuantiles-correctedEstimatorSIMmaxT;
        errorCorrectedSIMqT(s, :) = trueQuantiles-correctedEstimatorSIMqT;
        errorCorrectedSIMMixedT(s, :) = trueQuantiles-correctedEsimatorSIMmixedT;
        % Feasible IVT  approximation
        kIVT = floor((1-quantilesConsidered)*N); % Solve for k
        sIIVT = floor(sqrt(kIVT)); % Take square root
        % Extract statistics for the numerator
        noisyThetaIVT  = thetaSorted(N-kIVT); 
        noisyThetaIVTS =  thetaSorted(N-kIVT-sIIVT);
        % IVT Confidence interval with limit quantiles
        ciIntermediateNormal =    [(noisyThetaIVT   - norminv(1-alphaCI/2)*(noisyThetaIVT-noisyThetaIVTS ))';...
                           (noisyThetaIVT   - norminv(alphaCI/2)*(noisyThetaIVT-noisyThetaIVTS ))' ]; 
        % IVT Confidence interval with bootstrap
        critValueIVT  = noisyExtreme_subsamplingIntermediateQuantiles(alphaCI, thetaSorted, ...
            b, nSubsamples, quantilesConsidered);
        ciIntermediateSS =    [(noisyThetaIVT'   - critValueIVT(2, :).*(noisyThetaIVT'-noisyThetaIVTS' ));...
                           (noisyThetaIVT'   -  critValueIVT(1, :).*(noisyThetaIVT'-noisyThetaIVTS' )) ]; 
        
        
         % Central: naive
        [naiveThetaQ, naiveCL, naiveCU] = quantileBinomialCI(thetaSorted,...
                                quantilesConsidered, alphaCI, 1) ;
         
        % Central: analytical debiasing (based on Jochmans, Weidner (2019))
        jwCorrectedQuantiles = noisyExtreme_JWquantileBiasEstimator(quantilesConsidered, thetaS, Vest, T); 
        debiasedJWqQ = quantile(thetaS, jwCorrectedQuantiles);
        
        ciDebiased = noisyExtreme_jwQuantileBootstrap(thetaS, Vest, T, quantilesConsidered, alphaCI, nBootstrap);
    
        
        % JW corrected estimator
        correctedEstimatorJW = jwCorrectedQuantiles;
        errorCorrectedJW(s, :) = trueQuantiles-jwCorrectedQuantiles;          
        
        % Central: true data
        [trueThetaQ, trueCL, trueCU] = quantileBinomialCI(thetaS,...
                                quantilesConsidered, alphaCI, 0) ;
         
         

            
    
                % naive
        ciNaive = [   naiveCL'; naiveCU'];
            % debiased
            % true
        ciTrue = [   trueCL'; trueCU'];

        % Check if the interval actually contains the parameter
%         debiasedJWqQ(:, s) = debiasedJWq;
 
        % Subsampled
        containsSubsampledMax(s, :) = (trueQuantiles>=ciSubsampledMax(1, :)).* (trueQuantiles<= ciSubsampledMax(2, :));
        containsSubsampledq(s, :) = (trueQuantiles>=ciSubsampledq(1, :)).* (trueQuantiles<= ciSubsampledq(2, :));
        containsSubsampledMixed(s, :) = (trueQuantiles>=ciSubsampledMixed(1, :)).* (trueQuantiles<= ciSubsampledMixed(2, :));
        % Simulated (Pickands)
        containsSimulatedMax(s, :) = (trueQuantiles>=ciSimulatedMax(1, :)).* (trueQuantiles<= ciSimulatedMax(2, :));
        containsSimulatedQ(s, :) = (trueQuantiles>=ciSimulatedQ(1, :)).* (trueQuantiles<= ciSimulatedQ(2, :));
        containsSimulatedMixed(s, :) = (trueQuantiles>=ciSimulatedMixed(1, :)).* (trueQuantiles<= ciSimulatedMixed(2, :));
        % Simulated (Truncated)
        containsSimulatedMaxT(s, :) = (trueQuantiles>=ciSimulatedMaxT(1, :)).* (trueQuantiles<= ciSimulatedMaxT(2, :));
        containsSimulatedQT(s, :) = (trueQuantiles>=ciSimulatedQT(1, :)).* (trueQuantiles<= ciSimulatedQT(2, :));
        containsSimulatedMixedT(s, :) = (trueQuantiles>=ciSimulatedMixedT(1, :)).* (trueQuantiles<= ciSimulatedMixedT(2, :));
        % True
        
        containsTRUEssMax(s, :) = (trueQuantiles>=TRUEciSubsampledMax(1, :)).* (trueQuantiles<= TRUEciSubsampledMax(2, :));
        containsTRUEssMixed(s, :) = (trueQuantiles>=TRUEciSubsampledMixed(1, :)).* (trueQuantiles<= TRUEciSubsampledMixed(2, :));
       
        
        % Intermediate
        containsIntermediateNormal(s, :) = (trueQuantiles>=ciIntermediateNormal(1, :)).* (trueQuantiles<= ciIntermediateNormal(2, :));
        containsIntermediateSS(s, :) = (trueQuantiles>=ciIntermediateSS(1, :)).* (trueQuantiles<= ciIntermediateSS(2, :));
        
        containsNaive(s, :) = (trueQuantiles>=ciNaive(1, :)).* (trueQuantiles<= ciNaive(2, :));
        containsDebiased(s, :) = (trueQuantiles>=ciDebiased(1, :)).* (trueQuantiles<= ciDebiased(2, :));
%         containsTrue(s, :) = (trueQuantiles>=ciTrue(1, :)).* (trueQuantiles<= ciTrue(2, :));
        
        
        lengthSimulatedMax(s, :) = ciSimulatedMax(2, :)- ciSimulatedMax(1, :);
        lengthSimulatedQ(s, :) = ciSimulatedQ(2, :)- ciSimulatedQ(1, :);
        lengthSimulatedMixed(s, :) = ciSimulatedMixed(2, :)- ciSimulatedMixed(1, :);
        lengthSimulatedMaxT(s, :) = ciSimulatedMax(2, :)- ciSimulatedMax(1, :);
        lengthSimulatedQT(s, :) = ciSimulatedQT(2, :)- ciSimulatedQT(1, :);
        lengthSimulatedMixedT(s, :) = ciSimulatedMixed(2, :)- ciSimulatedMixed(1, :);
        lengthSubsampledMax(s, :) = ciSubsampledMax(2, :)- ciSubsampledMax(1, :);
        lengthSubsampledq(s, :) = ciSubsampledq(2, :)- ciSubsampledq(1, :);
        lengthSubsampledMixed(s, :) = ciSubsampledMixed(2, :)- ciSubsampledMixed(1, :);
        lengthIntermediateNormal(s, :) = ciIntermediateNormal(2, :)- ciIntermediateNormal(1, :);
        lengthIntermediateSS(s, :) = ciIntermediateSS(2, :)- ciIntermediateSS(1, :);
        lengthNaive(s, :) = ciNaive(2, :)- ciNaive(1, :);
        lengthDebiased(s, :) = ciDebiased(2, :)- ciDebiased(1, :);
        s
end
 
%% save

if saveResults == 1
    fileName = ['Outputs/',num2str(nSamples),'N', num2str(N),'F', thetaNameSave{thetaDistrChoice},...
        thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
       'Noiseless.mat' ];
    save(fileName)
end