%% Main loop 

% Load firm data
rawData = csvread('cdgprdata.csv', 1, 0);
% Separate the areas, using description on https://diegopuga.org/data/selectagg/
belowMedianDensity = rawData(rawData(:, 2)==1,:);
belowMedianDensity = belowMedianDensity(:, 3);
aboveMedianDensity = rawData(rawData(:, 2)==2,:);
aboveMedianDensity = aboveMedianDensity(:, 3);   

% select dataset    
dataUsed = aboveMedianDensity;

% create sample. The data is already sorted, so sufficient to sample directly
thetaSampler = @(u) aboveMedianDensity(ceil(length(dataUsed)*u)); 

% Select generating processes and insert all parameters   
uSampler = uDistribution{uDistrChoice};
uSampler = @(u) uSampler(uDistributionParam{uDistrChoice}, u) ;

% Compute variance adjustment
% Use automatic computation, no need for explicit functional codes
varTheta = var(thetaSampler(rand(100000, 1)));
varU = var(uSampler(rand(100000, 1)));
% Adjust
uSampler = @(u)  sqrt(varTheta/varU)*uSampler(u);

% Other parameters
quantilesConsidered = quantilesConsideredArray{thetaDistrChoice};
gammaSignChosen = gammaSign{thetaDistrChoice};

  %% Simulation loop and plotting

% Precompute quadrature points for integrating in MW interval
nGQ = 20; % quadrature order
[glPoints, ~, glLP] = lgwt(nGQ, -1, 1);
k=5;

% Prepare vectors fo recording coverage
containsPickandsMax = zeros(nSamples, length(quantilesConsidered));
containsPickandsQ = zeros(nSamples, length(quantilesConsidered));
containsPickandsMixed= zeros(nSamples, length(quantilesConsidered));
containsHillMax = zeros(nSamples, length(quantilesConsidered));
containsHillQ = zeros(nSamples, length(quantilesConsidered));
containsHillMixed= zeros(nSamples, length(quantilesConsidered));
containsTRUEssMax = zeros(nSamples, length(quantilesConsidered));
containsTRUEssMixed= zeros(nSamples, length(quantilesConsidered));

containsSubsampledMax = zeros(nSamples, length(quantilesConsidered));
containsMW = zeros(nSamples, length(quantilesConsidered));
containsSubsampledq = zeros(nSamples, length(quantilesConsidered));
containsSubsampledMixed = zeros(nSamples, length(quantilesConsidered));

% Intermediate
containsIntermediateNormal = zeros(nSamples, length(quantilesConsidered));
containsIntermediateSS = zeros(nSamples, length(quantilesConsidered));
containsExtrapolation = zeros(nSamples, length(quantilesConsidered));

% Central
containsNaive = zeros(nSamples, length(quantilesConsidered));
containsDebiased = zeros(nSamples, length(quantilesConsidered));
containsTrue = zeros(nSamples, length(quantilesConsidered));

nonEmptyMW = zeros(nSamples, length(quantilesConsidered));
        
lengthPickandsMax =  zeros(nSamples, length(quantilesConsidered));
lengthPickandsQ =  zeros(nSamples, length(quantilesConsidered));
lengthPickandsMixed=  zeros(nSamples, length(quantilesConsidered));
lengtHillMax =  zeros(nSamples, length(quantilesConsidered));
lengthHillQ =  zeros(nSamples, length(quantilesConsidered));
lengthHillMixed =  zeros(nSamples, length(quantilesConsidered));
lengthSubsampledMax = zeros(nSamples, length(quantilesConsidered));
lengthSubsampledMixed = zeros(nSamples, length(quantilesConsidered));
lengthSubsampledq = zeros(nSamples, length(quantilesConsidered));

% Intermediate
lengthIntermediateNormal = zeros(nSamples, length(quantilesConsidered));
lengthIntermediateSS= zeros(nSamples, length(quantilesConsidered));
lengthExtrapolation = zeros(nSamples, length(quantilesConsidered));

% Central
lengthNaive = zeros(nSamples, length(quantilesConsidered));
lengthDebiased = zeros(nSamples, length(quantilesConsidered));
lengthMW=  zeros(nSamples, length(quantilesConsidered));


% Errors

% Extreme corrections
    % Raw quantile
errorSimple = zeros(nSamples, length(quantilesConsidered));
    % Subsampled
errorCorrectedMax = zeros(nSamples, length(quantilesConsidered));
errorCorrectedq = zeros(nSamples, length(quantilesConsidered));
errorCorrectedMixed = zeros(nSamples, length(quantilesConsidered));
    % Generalized Pickands
errorCorrectedPickandsMax = zeros(nSamples, length(quantilesConsidered));
errorCorrectedPickandsq = zeros(nSamples, length(quantilesConsidered));
errorCorrectedPickandsMixed = zeros(nSamples, length(quantilesConsidered));
    % Hill
errorCorrectedHillMax = zeros(nSamples, length(quantilesConsidered));
errorCorrectedHillq = zeros(nSamples, length(quantilesConsidered));
errorCorrectedHillmixed = zeros(nSamples, length(quantilesConsidered));

% Intermediate
errorExtrapolation = zeros(nSamples, length(quantilesConsidered));

% Central corrections
errorCorrectedJW = zeros(nSamples, length(quantilesConsidered));




% True quantiles
trueQuantiles = thetaSampler(quantilesConsidered)';
l = (1-quantilesConsidered)*N; % approximating centering l


% Main loop

parfor s=1:nSamples % loop over samples
        %% Drawing data
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
        Vest = T*noisyExtreme_OLSvarianceEstimator(y, x, noisyBetaS');
        Vest = squeeze(Vest(2, 2, :));
       
        % Sort estimates
        noisyThetaSsorted = sort(noisyThetaS); 

        
        % Compute estimators, variances, ...
            % EV approximation
        maxNoisyS = noisyThetaSsorted(end); 
        maxQnoisyS = noisyThetaSsorted(end-qSubsampling);   
        maxLNoisyS = noisyThetaSsorted(ceil(N*quantilesConsidered));
 
        
        
      
        %% Extreme approximations (subsampling)
        % Critical values by subsampling
        b = (N)^(4/5);
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
         % Coverage and length
         
         % Errors
         
        %% Extreme approximations (simulation) 
        % Quantiles by simulation
        % Select intermediate order for k
        kGamma = floor((N )^(1/2));
        % Computer gamma estimator (Hill + generalized Pickands)
        gammaPickands = noisyExtreme_EVindexGeneralizedPickands(noisyThetaSsorted, kGamma); % generalized Pickands
        gammaHill = noisyExtreme_EVindexHill(noisyThetaSsorted, kGamma);

        % Critical values for Pickands estimator
        [critValuePickandsMmax, critValuePickandsq, critValuePickandsmixed] = ...
            noisyExtreme_GammaRatioLimitQuantiles(gammaPickands, ...
            qSimulation, l, [alphaCI/2, 1-alphaCI/2, 1/2]); % quantiles
        
        % Critical values for Hill estimator
        [critValueHillMmax, critValueHillq, critValueHillmixed] = ...
            noisyExtreme_GammaRatioLimitQuantiles(gammaHill, ...
            qSimulation, l, [alphaCI/2, 1-alphaCI/2, 1/2]); % quantiles

        % Pickands
                % Max-based approximation
        ciPickandsMax =  [maxNoisyS - critValuePickandsMmax(1, :)*(maxQnoisyS-maxNoisyS); ...
             maxNoisyS - critValuePickandsMmax(2, :)*(maxQnoisyS-maxNoisyS)];%    
        % Approximation with shifting order statistic 
        ciPickandsQ =  [maxLNoisyS' - critValuePickandsq(1, :).*(maxLNoisyS'-maxNoisyS); ...
             maxLNoisyS' - critValuePickandsq(2, :).*(maxLNoisyS'-maxNoisyS)];%   
        % Approximation with shifting order statistic in the numerator only
        ciPickandsMixed =  [maxLNoisyS' - critValuePickandsmixed(1, :).*(maxQnoisyS-maxNoisyS); ...
             maxLNoisyS' - critValuePickandsmixed(2, :).*(maxQnoisyS-maxNoisyS)];    
   
        % Hill
                % Max-based approximation
        ciHillMax =  [maxNoisyS - critValueHillMmax(1, :)*(maxQnoisyS-maxNoisyS); ...
             maxNoisyS - critValueHillMmax(2, :)*(maxQnoisyS-maxNoisyS)];%    
        % Approximation with shifting order statistic 
        ciHillNoisyQ = [ maxLNoisyS' - critValueHillq(1, :).*(maxLNoisyS'-maxNoisyS); ...
             maxLNoisyS' - critValueHillq(2, :).*(maxLNoisyS'-maxNoisyS)];%   
        % Approximation with shifting order statistic in the numerator only
        ciHillMixed =  [maxLNoisyS' - critValueHillmixed(1, :).*(maxQnoisyS-maxNoisyS); ...
             maxLNoisyS' - critValueHillmixed(2, :).*(maxQnoisyS-maxNoisyS)];
         
         
        % Coverage and length
        % Simulated (Pickands)
        containsPickandsMax(s, :) = (trueQuantiles>=ciPickandsMax(1, :)).* (trueQuantiles<= ciPickandsMax(2, :));
        containsPickandsQ(s, :) = (trueQuantiles>=ciPickandsQ(1, :)).* (trueQuantiles<= ciPickandsQ(2, :));
        containsPickandsMixed(s, :) = (trueQuantiles>=ciPickandsMixed(1, :)).* (trueQuantiles<= ciPickandsMixed(2, :));
        lengthPickandsMax(s, :) = ciPickandsMax(2, :)- ciPickandsMax(1, :);
        lengthPickandsQ(s, :) = ciPickandsQ(2, :)- ciPickandsQ(1, :);
        lengthPickandsMixed(s, :) = ciPickandsMixed(2, :)- ciPickandsMixed(1, :);
        
        % Simulated (Hill)
        containsHillMax(s, :) = (trueQuantiles>=ciHillMax(1, :)).* (trueQuantiles<= ciHillMax(2, :));
        containsHillQ(s, :) = (trueQuantiles>=ciHillNoisyQ(1, :)).* (trueQuantiles<= ciHillNoisyQ(2, :));
        containsHillMixed(s, :) = (trueQuantiles>=ciHillMixed(1, :)).* (trueQuantiles<= ciHillMixed(2, :));
        lengtHillMax(s, :) = ciHillMax(2, :)- ciHillMax(1, :);
        lengthHillQ(s, :) = ciHillNoisyQ(2, :)- ciHillNoisyQ(1, :);
        lengthHillMixed(s, :) = ciHillMixed(2, :)- ciHillMixed(1, :);

        % Corrected estimators
        correctedEstimatorPickandsmax =  maxNoisyS - critValuePickandsMmax(3, :)*(maxQnoisyS-maxNoisyS);
        correctedEstimatorPickandsq =  maxLNoisyS' - critValuePickandsq(3, :).*(maxLNoisyS'-maxNoisyS);
        correctedEstimatorPickandsmixed=  maxLNoisyS' - critValuePickandsmixed(3, :).*(maxQnoisyS-maxNoisyS);
        
        correctedEstimatorHillmax =  maxNoisyS - critValueHillMmax(3, :)*(maxQnoisyS-maxNoisyS);
        correctedEstimatorHillq =  maxLNoisyS' - critValueHillq(3, :).*(maxLNoisyS'-maxNoisyS);
        correctedEstimatorHillmixed=  maxLNoisyS' - critValueHillmixed(3, :).*(maxQnoisyS-maxNoisyS);
                
        % Save the errors made
        errorSimple(s, :) = trueQuantiles-maxLNoisyS';
        errorCorrectedMax(s, :) = trueQuantiles-correctedEstimatorSSmax;
        errorCorrectedq(s, :) = trueQuantiles-correctedEstimatorSSq;
        errorCorrectedMixed(s, :) = trueQuantiles-correctedEsimatorSSmixed;
        
        errorCorrectedPickandsMax(s, :) = trueQuantiles-correctedEstimatorPickandsmax;
        errorCorrectedPickandsq(s, :) = trueQuantiles-correctedEstimatorPickandsq;
        errorCorrectedPickandsMixed(s, :) = trueQuantiles-correctedEstimatorPickandsmixed;
 
        errorCorrectedHillMax(s, :) = trueQuantiles-correctedEstimatorHillmax;
        errorCorrectedHillq(s, :) = trueQuantiles-correctedEstimatorHillq;
        errorCorrectedHillmixed(s, :) = trueQuantiles-correctedEstimatorHillmixed;
        
            %% Muller, Wang optimal approximation
            % Trim corresponding number of top statistics
        noisyThetaSsortedK = noisyThetaSsorted(end-k+1:end)';
            % Initialize temporary objects that accelerate computation
        previousSuccess= [];
        q0Previous = [];
        countPrevious = []; 
        previousLogFyxTemp = [];
        q0Lprevious = []; 
        q0Uprevious = []; 
           % Compute intervals
        ciMW = zeros(2, length(l));
        mwSuccessLoop = zeros(1, length(l));
        for i=1:length(l)
            [ciMW(1, i), ciMW(2, i), mwSuccessLoop(i),  previousSuccess, q0Previous, ...
            countPrevious, previousLogFyxTemp, q0Lprevious, q0Uprevious] =...
            mw_CIex(noisyThetaSsortedK, l(end+1-i), alphaCI, glPoints, glLP,...
            previousSuccess, q0Previous, countPrevious, previousLogFyxTemp, ...
            q0Lprevious, q0Uprevious);
        end 
        
%         % for comparison, old
%         for i=1:length(l)
%             [ciMW(1, i), ciMW(2, i), mwSuccessLoop(i) ] =...
%             mw_CIOLD(noisyThetaSsortedK, l(end+1-i), alphaCI, 0);
%         i
%         end 
        % Coverage and length
        containsMW(s, :) =  (trueQuantiles>=ciMW(1, :)).* (trueQuantiles<= ciMW(2, :));
        nonEmptyMW(s, :) = mwSuccessLoop;
        lengthMW(s, :) = ciMW(2, :)- ciMW(1, :);                   
        
        %% Feasible IVT approximations
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
                 
       % Coverage and length
        containsIntermediateNormal(s, :) = (trueQuantiles>=ciIntermediateNormal(1, :)).* (trueQuantiles<= ciIntermediateNormal(2, :));
        containsIntermediateSS(s, :) = (trueQuantiles>=ciIntermediateSS(1, :)).* (trueQuantiles<= ciIntermediateSS(2, :));
        lengthIntermediateNormal(s, :) = ciIntermediateNormal(2, :)- ciIntermediateNormal(1, :);
        lengthIntermediateSS(s, :) = ciIntermediateSS(2, :)- ciIntermediateSS(1, :);

        %% Intermediate extrapolation estimator
        [extrapolationEst, extrapolationInt] = ...
           noisyExtreme_extrapolationEstimator(noisyThetaSsorted,...
           quantilesConsidered, alphaCI, k);
       
        % Coverage and length
        containsExtrapolation(s, :) = (trueQuantiles>=extrapolationInt(1, :)).* (trueQuantiles<= extrapolationInt(2, :));
        lengthExtrapolation(s, :) = extrapolationInt(2, :)- extrapolationInt(1, :);
        % Estimator error
        errorExtrapolation(s, :) = trueQuantiles-extrapolationEst;
        %% central approximations    
        % Central: naive
        [naiveThetaQ, naiveCL, naiveCU] = quantileBinomialCI(noisyThetaSsorted,...
                                quantilesConsidered, alphaCI, 1) ;
         
        % Central: analytical debiasing (based on Jochmans, Weidner (2019))
        jwCorrectedQuantiles = noisyExtreme_JWquantileBiasEstimator(quantilesConsidered, noisyThetaS, Vest, T); 
        debiasedJWqQ = quantile(noisyThetaS, jwCorrectedQuantiles);
        
        ciDebiased = noisyExtreme_jwQuantileBootstrap(noisyThetaS, Vest, T, quantilesConsidered, alphaCI, nBootstrap);
    
        
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
         % True
        
        containsTRUEssMax(s, :) = (trueQuantiles>=TRUEciSubsampledMax(1, :)).* (trueQuantiles<= TRUEciSubsampledMax(2, :));
        containsTRUEssMixed(s, :) = (trueQuantiles>=TRUEciSubsampledMixed(1, :)).* (trueQuantiles<= TRUEciSubsampledMixed(2, :));
       
        
    
        containsNaive(s, :) = (trueQuantiles>=ciNaive(1, :)).* (trueQuantiles<= ciNaive(2, :));
        containsDebiased(s, :) = (trueQuantiles>=ciDebiased(1, :)).* (trueQuantiles<= ciDebiased(2, :));
        containsTrue(s, :) = (trueQuantiles>=ciTrue(1, :)).* (trueQuantiles<= ciTrue(2, :));
        
        
        
        
        % Compute interval lengths
       
        lengthSubsampledMax(s, :) = ciSubsampledMax(2, :)- ciSubsampledMax(1, :);
        lengthSubsampledq(s, :) = ciSubsampledq(2, :)- ciSubsampledq(1, :);
        lengthSubsampledMixed(s, :) = ciSubsampledMixed(2, :)- ciSubsampledMixed(1, :);

        
        lengthNaive(s, :) = ciNaive(2, :)- ciNaive(1, :);
        lengthDebiased(s, :) = ciDebiased(2, :)- ciDebiased(1, :);
        s
end
 
%% save

if saveResults == 1
    fileName = ['Outputs/',num2str(nSamples),'N', num2str(N), 'T', num2str(T), 'F', thetaNameSave{thetaDistrChoice},...
        thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
        uParamNameSave{uDistrChoice}, num2str(uDistributionParam{uDistrChoice}),'.mat' ];
    save(fileName)
end