% ===========================================================
% File: simulateCoveragesErrors.m
% Description: This file contains the main simulation loop of the
% simulations. It runs the simulation for all combinations of data
% generating processes and sample sizes. The results are saved in .mat
% files specific to given DGP and (N, T)
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
% ===========================================================

%% Zip together the defining parameters of the simulation

% Create combinations of DGPs
dgps = combinations(thetaDistrsArray, uDistrsArray);

% Create combinations of sample sizes
sampleSizes = combinations(Ns, Ts);

% Number of methods to evaluate
numMethods = length(methodsCI);

%% Main simulation
% Loop through DGP

for dgpID = 1:height(dgps)
    % Extract data generating processes for coefficients and shocks
    thetaSampler = dgps{dgpID, 1}{1};
    uSampler = dgps{dgpID, 2}{1}; 

    % Adjust the variance of the DGP for the shocks
    uSampler = uSampler.calibrateVariance(thetaSampler);

    % Create a vector of appropriate target quantiles for current DGP
    % Do not target the endpoints for distributions with infinite endpoints
    if ~thetaSampler.finiteRightEndpoint
        targetQuantilesDGP = targetQuantiles(targetQuantiles<1);
    else 
        targetQuantilesDGP = targetQuantiles;
    end

    % Compute the true quantiles
    trueQuantileVals = thetaSampler.distrInverse(targetQuantilesDGP, thetaSampler.paramValue);

    % Create temporary arrays, these will be inserted into results arrays
    ciCoversTemp = NaN(numSamples, length(targetQuantilesDGP), numMethods);
    ciLengthsTemp = NaN(numSamples, length(targetQuantilesDGP), numMethods);
    estErrorsTemp = NaN(numSamples, length(targetQuantilesDGP), numMethods);

    % Loop through sample sizes
    for sampleSizeID = 1:height(sampleSizes)
        % Set sample sizes
        N = sampleSizes{sampleSizeID, 1};
        T = sampleSizes{sampleSizeID, 2};

        % Create result arrays for 
        resultsArray = ...
            createSimResultArrays(methodsCI, trueQuantileVals, numSamples);

        % Draw Monte Carlo samples: simulation computations go here
        
        % Create bar to visualize progress
        queue = parallel.pool.DataQueue;
        parallelProgressBar(queue, numSamples);

        parfor sampleID = 1:numSamples
            % Draw data
            [y, x, coefsTrue, ~] = ...
                linearModelDrawData(N, T, constantIncluded, numCov, ...
                thetaSampler, uSampler, sigmaSqX, rhoTheta, rhoXtheta);

            % Parameter of interest: second coordinate
            thetaTrue = coefsTrue(:, 2); % second coordinate
            thetaTrueSorted =sort(thetaTrue); 

            % Compute estimators and standard errors
            [coefsEsts, varEsts] = OLS(y, x);
            thetaEsts = coefsEsts(:, 2);
            varEsts = T*squeeze(varEsts(2, 2, :));

            % Sort estimates
            thetaEstsSorted = sort(thetaEsts);
    
            % Loop through the methods
            for methodID = 1:numMethods
                % Fit the current method
                currentApproach = ...
                    methodsCI{methodID}.fit(thetaEstsSorted, ...
                    targetQuantilesDGP);
 
                % Save results to temporary arrays
                ciCoversTemp(sampleID, :, methodID) = ...
                    currentApproach.computeCoverage(trueQuantileVals);
                ciLengthsTemp(sampleID, :, methodID) = ...
                    currentApproach.computeLengths();
                estErrorsTemp(sampleID, :, methodID) = ...
                    currentApproach.computeEstErrors(trueQuantileVals);

            end
            % Send a message to update the progress bar
            send(queue, sampleID);
            disp(sampleID)


        end

        % Update arrays
        resultsArray = ...
            updateSimResultArrays(resultsArray, ...
            ciCoversTemp, ciLengthsTemp, estErrorsTemp);

        % Save results for DGP and sample size combination
        fileName = ['outputs/samples_',num2str(numSamples),...
            '_N_', num2str(N), '_T_', num2str(T), ...
            '_F_', thetaSampler.distrMachineName,...
            '_', thetaSampler.paramMachineName, '_',...
            num2str(thetaSampler.paramValue),...
            '_G_', uSampler.distrMachineName,... 
              '_', uSampler.paramMachineName, '_',...
            num2str(uSampler.paramValue),...
            '.mat' ];
        save(strjoin(fileName, ''))
     
    end
end