
%% Define Simulation Parameters

% Generate combinations of DGPs by pairing distributions for coefficients 
% and shocks with sample sizes (N, T).
dgps = combinations(thetaDistrsArray, uDistrsArray, Ns, Ts);

%% Set Up Parallel Processing

% Create or retrieve a parallel pool if it doesn’t exist
p = gcp('nocreate'); % Check for existing parallel pool
if isempty(p)
    parpool('LocalProfile1', 16); % Adjust profile and worker count 
end


%% Loop over each DGP combination
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

    % Create an array to hold the results
    ivtArray = nan(numSamples, length(targetQuantilesDGP));

    % Set up a progress bar for monitoring simulation progress
    progressQueue = createParallelProgressBar(numSamples);

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

        % Compute IVT statistics
        ivtStatistics = ...
         computeIVTRatios(thetaEstsSorted, targetQuantilesDGP, trueQuantileVals');
        
        % Insert the statistics into the results array
        ivtArray(sampleID, :) = ivtStatistics;

        % Update the progress bar
        send(progressQueue, sampleID);
    end

     
    % Construct filename for saving results
    fileName = makeOutputFileName(loopThetaSampler, loopUSampler, ...
                                  N, T, ...
                                  numSamples, simContext);
    
    % Save results to a .mat file
    save(fileName);
end