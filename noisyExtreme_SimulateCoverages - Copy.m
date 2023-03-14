


%% Main loop


% Select generating processes and insert all parameters
thetaSampler = thetaDistribution{thetaDistrChoice};
thetaSampler = @(u) thetaSampler(thetaDistributionParam{thetaDistrChoice}, u);   
uSampler = uDistribution{uDistrChoice};
uSampler = @(u) uSampler(uDistributionParam{uDistrChoice}, u) ;

% Compute variance adjustment
% Use automatic computation, no need for explicit functional codes
varTheta = var(thetaSampler(rand(100000, 1)));
varU = var(uSampler(rand(100000, 1)));
% Adjust
uSampler = @(u) sqrt(varTheta/varU)*uSampler(u);

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
containsTrue = zeros(nSamples, length(quantilesConsidered));
        
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


% True quantiles
trueQuantiles = thetaSampler(quantilesConsidered);

% Main loop
parfor s=1:nSamples % loop over samples
        
        % Draw coefficients and data in a potentially correlated
        % manner
        [y, x, betaS, ~] = ...
            noisyExtreme_linearModelDrawData(N, T, constantIncluded, numCov, ...
            thetaSampler, uSampler, sigmaSqX, rhoTheta, rhoXtheta);
        thetaS = betaS(:, 2); % second coordinate
        thetaSorted =sort(thetaS);
        maxS = thetaSorted(end);
        maxQS = thetaSorted(end-qSubsampling);   
        maxLS = thetaSorted(ceil(N*quantilesConsidered));
        
        % Create noisy estimates
        noisyBetaS = noisyExtreme_OLS(y, x);
        noisyThetaS = noisyBetaS(:, 2);
        
        % Estimate variances for the JW correction
        Vest = noisyExtreme_OLSvarianceEstimator(y, x, noisyBetaS');
        Vest = squeeze(Vest(2, 2, :));
       
        % Sort estimates
        noisyThetaSsorted = sort(noisyThetaS); 

        l = (1-quantilesConsidered)*N; % approximating centering l
        % Compute estimators, variances, ...
            % EV approximation
        maxNoisyS = noisyThetaSsorted(end); 
        maxQnoisyS = noisyThetaSsorted(end-qSubsampling);   
        maxLNoisyS = noisyThetaSsorted(ceil(N*quantilesConsidered));
        
            
        % Critical values by subsampling
        b = (N)^(3/4);
        [critValueSSmax, critValueSSq, critValueSSmixed] = ...
            noisyExtreme_subsamplingCriticalValues(alphaCI, noisyThetaSsorted, ...
            qSubsampling, b, nSubsamples, quantilesConsidered);   % subsampled quantiles    
        % Max-based approximation
        ciSubsampledMax =  [maxNoisyS - critValueSSmax(1, :)*(maxQnoisyS-maxNoisyS); ...
             maxNoisyS - critValueSSmax(2, :)*(maxQnoisyS-maxNoisyS)];% fEVT subsampled    
        % Approximation with shifting order statistic 
        ciSubsampledq =  [maxLNoisyS' - critValueSSq(1, :).*(maxLNoisyS'-maxNoisyS); ...
             maxLNoisyS' - critValueSSq(2, :).*(maxLNoisyS'-maxNoisyS)];% fEVT subsampled    
        % Approximation with shifting order statistic in the numerator only
        ciSubsampledMixed =  [maxLNoisyS' - critValueSSmixed(1, :).*(maxQnoisyS-maxNoisyS); ...
             maxLNoisyS' - critValueSSmixed(2, :).*(maxQnoisyS-maxNoisyS)];% fEVT subsampled    
   
        % Quantiles by simulation
        % Select intermediate order for k
        kGamma = floor((N )^(1/3));
        % Computer gamma estimator
        gammaPickands = 1/log(2)*log( (noisyThetaSsorted(end-kGamma)-noisyThetaSsorted(end-2*kGamma) )...
             /(noisyThetaSsorted(end-2*kGamma)-noisyThetaSsorted(end-4*kGamma))  );
        gammaTruncated = (sign(gammaPickands)*gammaSignChosen>=0)*gammaPickands;

        % Critical values for Pickands estimator
        [critValueSIMmax, critValueSIMq, critValueSSIMmixed] = ...
            noisyExtreme_GammaRatioLimitQuantiles(gammaPickands, ...
            qSimulation, l, [alphaCI/2, 1-alphaCI/2, 1/2]); % quantiles

                % Max-based approximation
        ciSimulatedMax =  [maxNoisyS - critValueSIMmax(1, :)*(maxQnoisyS-maxNoisyS); ...
             maxNoisyS - critValueSIMmax(2, :)*(maxQnoisyS-maxNoisyS)];%    
        % Approximation with shifting order statistic 
        ciSimulatedQ =  [maxLNoisyS' - critValueSIMq(1, :).*(maxLNoisyS'-maxNoisyS); ...
             maxLNoisyS' - critValueSIMq(2, :).*(maxLNoisyS'-maxNoisyS)];%   
        % Approximation with shifting order statistic in the numerator only
        ciSimulatedMixed =  [maxLNoisyS' - critValueSSIMmixed(1, :).*(maxQnoisyS-maxNoisyS); ...
             maxLNoisyS' - critValueSSIMmixed(2, :).*(maxQnoisyS-maxNoisyS)];    
   
        % Critical values for truncated Pickands  
        [critValueSIMmaxT, critValueSIMqT, critValueSSIMmixedT] = ...
            noisyExtreme_GammaRatioLimitQuantiles(gammaTruncated, ...
            qSimulation, l, [alphaCI/2, 1-alphaCI/2, 1/2]); % quantiles

                % Max-based approximation
        ciSimulatedMaxT =  [maxNoisyS - critValueSIMmaxT(1, :)*(maxQnoisyS-maxNoisyS); ...
             maxNoisyS - critValueSIMmaxT(2, :)*(maxQnoisyS-maxNoisyS)];%    
        % Approximation with shifting order statistic 
        ciSimulatedQT =  [maxLNoisyS' - critValueSIMqT(1, :).*(maxLNoisyS'-maxNoisyS); ...
             maxLNoisyS' - critValueSIMqT(2, :).*(maxLNoisyS'-maxNoisyS)];%   
        % Approximation with shifting order statistic in the numerator only
        ciSimulatedMixedT =  [maxLNoisyS' - critValueSSIMmixedT(1, :).*(maxQnoisyS-maxNoisyS); ...
             maxLNoisyS' - critValueSSIMmixedT(2, :).*(maxQnoisyS-maxNoisyS)];
         
         
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
        correctedEstimatorSSmax =  maxNoisyS - critValueSSmax(3, :)*(maxQnoisyS-maxNoisyS);
        correctedEstimatorSSq =  maxLNoisyS' - critValueSSq(3, :).*(maxLNoisyS'-maxNoisyS);
        correctedEsimatorSSmixed=  maxLNoisyS' - critValueSSmixed(3, :).*(maxQnoisyS-maxNoisyS);
        
        correctedEstimatorSIMmax =  maxNoisyS - critValueSIMmax(3, :)*(maxQnoisyS-maxNoisyS);
        correctedEstimatorSIMq =  maxLNoisyS' - critValueSIMq(3, :).*(maxLNoisyS'-maxNoisyS);
        correctedEsimatorSIMmixed=  maxLNoisyS' - critValueSSIMmixed(3, :).*(maxQnoisyS-maxNoisyS);
        
        correctedEstimatorSIMmaxT =  maxNoisyS - critValueSIMmaxT(3, :)*(maxQnoisyS-maxNoisyS);
        correctedEstimatorSIMqT =  maxLNoisyS' - critValueSIMqT(3, :).*(maxLNoisyS'-maxNoisyS);
        correctedEsimatorSIMmixedT=  maxLNoisyS' - critValueSSIMmixedT(3, :).*(maxQnoisyS-maxNoisyS);
                
        % Save the errors made
        errorSimple(s, :) = trueQuantiles-maxLNoisyS';
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
        noisyThetaIVT  = noisyThetaSsorted(N-kIVT); 
        noisyThetaIVTS =  noisyThetaSsorted(N-kIVT-sIIVT);
        % IVT Confidence interval with limit quantiles
        ciIntermediateNormal =    [(noisyThetaIVT   - norminv(1-alphaCI/2)*(noisyThetaIVT-noisyThetaIVTS ))';...
                           (noisyThetaIVT   - norminv(alphaCI/2)*(noisyThetaIVT-noisyThetaIVTS ))' ]; 
        % IVT Confidence interval with bootstrap
        critValueIVT  = noisyExtreme_subsamplingIntermediateQuantiles(alphaCI, noisyThetaSsorted, ...
            b, nSubsamples, quantilesConsidered);
        ciIntermediateSS =    [(noisyThetaIVT'   - critValueIVT(2, :).*(noisyThetaIVT'-noisyThetaIVTS' ));...
                           (noisyThetaIVT'   -  critValueIVT(1, :).*(noisyThetaIVT'-noisyThetaIVTS' )) ]; 
        
        
         % Central: naive
        [naiveThetaQ, naiveCL, naiveCU] = quantileBinomialCI(noisyThetaSsorted,...
                                quantilesConsidered, alphaCI, 1) ;
         
        % Central: analytical debiasing (based on Jochmans, Weidner (2019))
         
%          noisyThetaShpj1Qs = sort( noisyThetaShpj1  )   ;
%          noisyThetaShpj2Qs = sort( noisyThetaShpj2 )   ;
%          debiasedJWbias = (floor(T/2))*noisyThetaShpj1Qs + (T-floor(T/2))*noisyThetaShpj2Qs...
%                 -T*noisyThetaSsorted ;    
       
        jwCorrectedQuantiles = noisyExtreme_JWquantileBiasEstimator(quantilesConsidered, noisyThetaS, Vest, T); 
        debiasedJWqQ = quantile(noisyThetaS, jwCorrectedQuantiles);
        
        ciDebiased = noisyExtreme_jwQuantileBootstrap(noisyThetaS, Vest, T, quantilesConsidered, alphaCI, nBootstrap);
    
                            
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
        containsTrue(s, :) = (trueQuantiles>=ciTrue(1, :)).* (trueQuantiles<= ciTrue(2, :));
        
        
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

% %% figure
% % make thicker lines
% figure
% plot(quantilesConsidered, mean(containsSubsampledMax,1))
% hold on
% plot(quantilesConsidered, mean(containsSimulated,1))
% plot(quantilesConsidered, mean(containsIntermediateNormal,1))
% plot(quantilesConsidered, mean(containsNaive,1))
% plot(quantilesConsidered, mean(containsDebiased,1))
% 
% yline(0.95) 
%  
% legend('Subsampling', 'Simulated', 'Intermediate', 'Central: naive', 'Central: debiased')
% xlabel('Quantile')
% ylabel('Coverage')
% % title(['95% nominal CI for quantile, different approximations, N=' num2str(N) ',T=' ...
% %     num2str(T) ', \kappa=' num2str(kappa) ', \beta=' num2str(beta) ',  rate conditions   satisfied'])
% 



%% 
% figure
% plot(quantilesConsidered, mean(lengthSubsampledMax,1))
% hold on
% plot(quantilesConsidered, mean(lengthSimulated,1))
% plot(quantilesConsidered, mean(lengthIntermediate,1))
% plot(quantilesConsidered, mean(lengthNaive,1), 'x')
% plot(quantilesConsidered, mean(lengthDebiased,1))
% yline(0.95) 
% 
% ylim([0, 1.5*max(mean(lengthSubsampledMax,1) )])
%  
% legend('Subsampling', 'Simulated', 'Intermediate', 'Central: naive', 'Central: debiased')
% xlabel('Quantile')
% ylabel('Length')
% title(['95% nominal CI for quantile, different approximations, N=' num2str(N) ',T=' ...
%     num2str(T) ', \kappa=' num2str(kappa) ', \beta=' num2str(beta) ',  rate conditions   satisfied'])




% %% With more space around the maximum
% 
% spacing = 1:length(quantilesConsidered);
% spacing= (spacing).^1.5;
% figure
% plot(spacing, mean(containsSubsampledMax,1),'LineWidth', 2)
% % set(gca,'XTickLabels',quantilesConsidered);
% xticks([spacing(1:6:end)])
% xticklabels([quantilesConsidered(1:6:end)])
% xlim([min(spacing), max(spacing)]);
% hold on
% plot(spacing, mean(containsSubsampledq,1),'LineWidth', 2)
% plot(spacing, mean(containsSubsampledMixed,1),'LineWidth', 2)
% plot(spacing, mean(containsSimulatedMax,1),'LineWidth', 1)
% plot(spacing, mean(containsSimulatedQ,1),'LineWidth', 1)
% plot(spacing, mean(containsSimulatedMixed,1),'LineWidth', 1)
% plot(spacing, mean(containsSimulatedMaxT,1),'LineWidth', 1)
% plot(spacing, mean(containsSimulatedQT,1),'LineWidth', 1)
% plot(spacing, mean(containsSimulatedMixedT,1),'LineWidth', 1)
% 
% plot(spacing, mean(containsIntermediateNormal,1),'LineWidth', 1)
% plot(spacing, mean(containsIntermediateSS,1),'LineWidth', 1)
% plot(spacing, mean(containsNaive,1), '-x','LineWidth', 1)
% plot(spacing, mean(containsDebiased,1),'LineWidth', 1)
% % plot(spacing, mean(containsTrue,1),'LineWidth', 1)
% yline(1-alphaCI) 
%  
% legend('Subsampling: max', 'Subsampling: q', 'Subsampling: mixed', 'SimP:max', ...
%     'SimP:q','SimP:mixed','SimT:max','SimT:q','SimT:mixed',...
%     'Intermediate: Normal','Intermediate:Subsampling', 'Central: naive', 'Central: debiased')%, 'Central: true')
% xlabel('Quantile')
% ylabel('Coverage')
% % title(['95% nominal CI for quantile, different approximations, N=' num2str(N) ',T=' ...
% %     num2str(T) ', \kappa=' num2str(kappa) ', \beta=' num2str(beta) ',  rate  conditions satisfied'])
% 
%  %% Lengths with same spacing
%  
% 
% figure
% plot(spacing, mean(lengthSubsampledMax,1),'LineWidth', 1)
% hold on
% xticks([spacing(1:6:end)])
% xticklabels([quantilesConsidered(1:6:end)])
% xlim([min(spacing), max(spacing)]);
% ylim([0, 2*max(mean(lengthSubsampledMax))])
% plot(spacing, mean(lengthSubsampledq,1),'LineWidth', 1)
% plot(spacing, mean(lengthSubsampledMixed,1),'LineWidth', 1)
% plot(spacing, mean(lengthSimulatedMax,1),'LineWidth', 1)
% plot(spacing, mean(lengthIntermediateNormal,1),'LineWidth', 1)
% plot(spacing, mean(lengthIntermediateSS,1),'LineWidth', 1)
% plot(spacing, mean(lengthNaive,1), '-x','LineWidth', 1)
% plot(spacing, mean(lengthDebiased,1),'LineWidth', 1)
%  
% %  ylim([0, 1.5*max(mean(lengthSubsampled,1) )])
%  
%  
% legend('Subsampling: max', 'Subsampling: q', 'Subsampling: mixed', 'Simulated', ...
%     'Intermediate: Normal','Intermediate:Subsampling', 'Central: naive', 'Central: debiased')
% xlabel('Quantile')
% ylabel('Length')
% % title(['95% nominal CI for quantile, different approximations, N=' num2str(N) ',T=' ...
% %     num2str(T) ', \kappa=' num2str(kappa) ', \beta=' num2str(beta) ',  rate  conditions  not satisfied'])


 
%% save

fileName = ['Outputs/',num2str(nSamples),'N', num2str(N), 'T', num2str(T), 'F', thetaNameSave{thetaDistrChoice},...
    thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
    uParamNameSave{uDistrChoice}, num2str(uDistributionParam{uDistrChoice}),'.mat' ];
save(fileName)