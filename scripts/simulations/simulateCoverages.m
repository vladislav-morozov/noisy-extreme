% ===========================================================
% File: simulateCoveragesErrors.m
% Description: This script runs the main simulation loop, iterating 
%              through all combinations of data-generating processes (DGPs) 
%              and sample sizes. Simulation results are saved in .mat files 
%              specific to each DGP and (N, T) combination.
% ===========================================================
% Project Name: Inference on Extreme Quantiles of Unobserved
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
% ===========================================================

%% Define Simulation Parameters

% Generate combinations of DGPs by pairing distributions for coefficients 
% and shocks with sample sizes (N, T).
dgps = combinations(thetaDistrsArray, uDistrsArray, Ns, Ts);

% Define the number of confidence interval (CI) estimation methods
numMethods = length(methodsCI);

%% Set Up Parallel Processing

% Create or retrieve a parallel pool if it doesn’t exist
p = gcp('nocreate'); % Check for existing parallel pool
if isempty(p)
    parpool('LocalProfile1', 16); % Adjust profile and worker count 
end

%% Main Simulation Loop

% Loop over each DGP combination
for dgpID = 1:height(dgps)  

    % Extract sample sizes (N, T) for the current DGP
    N = dgps{dgpID, 3};
    T = dgps{dgpID, 4};

    % Extract DGPs for coefficients and shocks
    loopThetaSampler = dgps{dgpID, 1}{1};
    loopUSampler = dgps{dgpID, 2}{1};

    % Calibrate variance of the shock DGP to match coefficient DGP
    loopUSampler = loopUSampler.calibrateVariance(loopThetaSampler);

    % Define target quantiles based on coefficient DGP properties
    if ~loopThetaSampler.finiteRightEndpoint
        targetQuantilesDGP = targetQuantiles(targetQuantiles < 1);
    else
        targetQuantilesDGP = targetQuantiles;
    end

    % Compute true quantile values for the current DGP
    trueQuantileVals = ...
        loopThetaSampler.distrInverse(targetQuantilesDGP, ...
                                      loopThetaSampler.paramValue);

    % Initialize temporary result arrays for CI coverage, lengths, and
    % estimation errors
    ciCoversTemp = ...
        NaN(numSamples, length(targetQuantilesDGP), numMethods);
    ciLengthsTemp = ...
        NaN(numSamples, length(targetQuantilesDGP), numMethods);
    estErrorsTemp = ...
        NaN(numSamples, length(targetQuantilesDGP), numMethods);

    % Create a structured array to store simulation results
    resultsArray = ...
        createSimResultArrays(methodsCI, trueQuantileVals, numSamples);

    % Set up a progress bar for monitoring simulation progress
    progressQueue = createParallelProgressBar(numSamples);

    % Display information about the current simulation setup in the console
    fprintf('\n Currently working on:\n');
    fprintf(' - theta: %s\n - u: %s\n - N = %d, T = %d\n', ...
        loopThetaSampler.distrMachineName, ...
        loopUSampler.distrMachineName, N, T);

    %% Monte Carlo Simulation Loop
    parfor sampleID = 1:numSamples
        
        % Step 1: Draw data for the current sample
        [y, x, coefsTrue, ~] = ....
            linearModelDrawData(N, T, constantIncluded, ...
                                numCov, loopThetaSampler, ...
                                loopUSampler, sigmaSqX, ...
                                rhoTheta, rhoXtheta);

        % Extract the true value of the second coefficient (parameter of
        % interest)
        thetaTrue = coefsTrue(:, 2);
        thetaTrueSorted = sort(thetaTrue);

        % Step 2: Estimate coefficients and their variances
        [coefsEsts, varEsts] = OLS(y, x);
        thetaEsts = coefsEsts(:, 2);
        varEsts = T * squeeze(varEsts(2, 2, :));

        % Sort the estimated parameters for further processing
        thetaEstsSorted = sort(thetaEsts);

        % Step 3: Evaluate each CI method
        for methodID = 1:numMethods
            
            % Fit the current CI method to the sorted estimates
            currentApproach = ...
                methodsCI{methodID}.fit(thetaEstsSorted, ...
                                        targetQuantilesDGP, varEsts, T);

            % Store results for CI coverage, length, and estimation errors
            ciCoversTemp(sampleID, :, methodID) = ...
                currentApproach.computeCoverage(trueQuantileVals);
            ciLengthsTemp(sampleID, :, methodID) = ...
                currentApproach.computeLengths();
            estErrorsTemp(sampleID, :, methodID) = ....
                currentApproach.computeEstErrors(trueQuantileVals);
        end

        % Update the progress bar
        send(progressQueue, sampleID);
    end

    %% Update Result Arrays and Save Output

    % Transfer temporary results into the main results array
    resultsArray = updateSimResultArrays(resultsArray, ciCoversTemp, ...
                                         ciLengthsTemp, estErrorsTemp);

    % Delete the progress queue to avoid saving it
    clear progressQueue;

    % Construct filename for saving results
    fileName = makeOutputFileName(loopThetaSampler, loopUSampler, ...
                                  N, T, ...
                                  numSamples, simContext);
    
    % Save results to a .mat file
    save(fileName);
end