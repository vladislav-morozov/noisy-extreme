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
if varU>0 % the noiseless case needs no adjustment
    uSampler = @(u)    sqrt(varTheta/varU)*uSampler(u);
end
% Other parameters
quantilesConsidered = quantilesConsideredArray{thetaDistrChoice};
gammaSignChosen = gammaSign{thetaDistrChoice};

%% Simulation loop and plotting

% Precompute quadrature points for integrating in MW interval
nGQ = 20; % quadrature order
[glPoints, ~, glLP] = lgwt(nGQ, -1, 1);
k= ceil(sqrt(N));

% Intermediate
errorExtrapolation = zeros(nSamples, length(quantilesConsidered));
containsExtrapolation = zeros(nSamples, length(quantilesConsidered));
lengthExtrapolation = zeros(nSamples, length(quantilesConsidered));
nonEmptyExtrapolation = zeros(nSamples, length(quantilesConsidered));
 


% True quantiles
trueQuantiles = thetaSampler(quantilesConsidered);
l = (1-quantilesConsidered)*N; % approximating centering l


% Main loop

parfor s=1:nSamples % loop over samples
    %% Drawing data
    % Draw coefficients and data in a potentially correlated
    % manner
    [y, x, betaS, ~] = ...
        linearModelDrawData(N, T, constantIncluded, numCov, ...
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
    
    
    
     % Intermediate extrapolation estimator
    [extrapolationEst, extrapolationInt, extrPoss] = ...
        noisyExtreme_extrapolationEstimator(noisyThetaSsorted,...
        quantilesConsidered, alphaCI, k);
    
    % Coverage and length
    containsExtrapolation(s, :) = (trueQuantiles>=extrapolationInt(1, :)).* (trueQuantiles<= extrapolationInt(2, :));
    lengthExtrapolation(s, :) = extrapolationInt(2, :)- extrapolationInt(1, :);
    % Estimator error
    errorExtrapolation(s, :) = trueQuantiles-extrapolationEst;
    % Whether construction was possible
    nonEmptyExtrapolation(s, :)=  extrPoss;
  
    s
end

%% save

if saveResults == 1
    fileName = ['Outputs/inter',num2str(nSamples),'N', num2str(N), 'T', num2str(T), 'F', thetaNameSave{thetaDistrChoice},...
        thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
        uParamNameSave{uDistrChoice}, num2str(uDistributionParam{uDistrChoice}),'.mat' ];
    save(fileName)
end