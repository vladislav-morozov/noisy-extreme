function kOpt = ...
    bootstrapChooseK(thetaVector, kVector, numBootstrapSamples)
    % bootstrapChooseK Chooses the optimal number k of intermediate order
    % statistics using semiparametric bootstrap and the PWM estimator.
    %
    % Args:
    %     thetaVector (vector): Sorted vector of data. 
    %     kVector (vector): vector of candidate values of k 
    %                       (positive integers).
    %     numBootstrapSamples (int): Number of bootstrap samples to draw.
    %
    % Returns:
    %     kOpt (int): Optimal value of k.
    %
    % References:
    %     1. Caers, J., Beirlant, J., & Maes, M. A. (1999). Statistics for
    %        Modeling Heavy Tailed Distributions in Geology: Part I.
    %        Methodology. Mathematical Geology, 31(4), 391–410.
    %     2. Algorithm 4.3 in Caeiro, F., & Gomes, M. I. (2016). Threshold
    %        Selection in Extreme Value Analysis. In Extreme Value Modeling
    %        and Risk Analysis (pp. 69–85). Chapman and Hall/CRC.
    
    % Compute PWM estimators for EV index and Pareto scale parameters
    [gammaEstCandidates, sigmaEstCandidates] = ...
        pwmEstimator(thetaVector, kVector);
    
    % Extract sample size
    N = length(thetaVector);
    
    % Create a vector for bootstrap estimates of the MSE
    mseEsts = nan(length(kVector), 1);
    
    % Bootstrap
    for kID = 1:length(kVector)
        % Extract current candidate value of k being evaluated
        kCandidate = kVector(kID);
        
        % Draw bootstrap samples from the semiparametric model
        candidateBootstrapSamples = ...
            sampleEDFGPHybrid(N * numBootstrapSamples, thetaVector, ...
            kCandidate, gammaEstCandidates(kID), sigmaEstCandidates(kID));
        
        % Reshape them into individual bootstrap samples
        candidateBootstrapSamples = ...
            reshape(candidateBootstrapSamples, [N, numBootstrapSamples]);
        
        % Compute the bootstrap PWM estimators
        gammaBootstrap = ...
            bootstrapPWM(candidateBootstrapSamples, kCandidate);
        
        % Compute the MSE
        mseEsts(kID) = ...
            mean((gammaBootstrap - gammaEstCandidates(kID)).^2, "omitnan");
    end
    
    % Return the index of the optimal k
    [~, kOptIdx] = min(mseEsts);
    
    % Select largest of optimal values in case of multiplicity
    kOptIdx = kOptIdx(1);
    
    % Return optimal k
    kOpt = kVector(kOptIdx);
end


function longSample = ...
    sampleEDFGPHybrid(numSamples, thetaVector, kCandidate, ...
        gammaVal, sigmaVal)
    % sampleEDFGPHybrid Draws samples from the semiparametric distribution
    % that characterizes the bootstrap algorithm of Caers et al. (1999).
    %
    % Args:
    %     numSamples (int): Size of sample to draw.
    %     thetaVector (vector): Sorted vector of data - sampling base.
    %     kCandidate (int): Positive integer, value of k being evaluated.
    %     gammaVal (float): Value of the gamma parameter for the 
    %         generalized Pareto tail to be simulated.
    %     sigmaVal (float): Value of the sigma parameter for the 
    %         generalized Pareto tail to be simulated.
    %
    % Returns:
    %     longSample (vector): Sample of size numSamples.
    %
    % References:
    %     Caers, J., Beirlant, J., & Maes, M. A. (1999). Statistics for
    %     Modeling Heavy Tailed Distributions in Geology: Part I.
    %     Methodology. Mathematical Geology, 31(4), 391–410.
    %     https://doi.org/10.1023/A:1007538624271

    % Simulate the number of observations drawn from the empirical
    % distribution function (non-tail portion of the sample)
    numNonTailObs = ...
        sum(rand(numSamples, 1) < 1 - kCandidate / length(thetaVector));
    
    % Draw samples from the EDF for the non-tail observations
    nonTailSample = ...
        datasample(thetaVector(1:end - kCandidate), numNonTailObs);
    
    % Create a GP distribution object for the tail portion
    gpDist = ...
        makedist('GeneralizedPareto', 'k', gammaVal, 'sigma', sigmaVal, ...
                  'theta', thetaVector(end - kCandidate));
    
    % Sample from the GP distribution
    tailSample = gpDist.random(numSamples - numNonTailObs, 1);
    
    % Combine the two samples and shuffle them randomly to ensure the
    % correct sampling distribution
    longSample = [nonTailSample; tailSample];
    longSample = longSample(randperm(length(longSample)));
end


function bootstrapGammasVec = ...
    bootstrapPWM(candidateBootstrapSamples, kCandidate)
    % bootstrapPWM Computes the PWM estimator on the bootstrap subsamples in
    % the candidateBootstrapSamples matrix. Columns of that matrix must
    % correspond to individual bootstrap samples. Uses kCandidate as the
    % value of k.
    %
    % Args:
    %     candidateBootstrapSamples (matrix): Matrix where columns 
    %         correspond to individual bootstrap samples.
    %     kCandidate (int): Positive integer, value of k being evaluated.
    %
    % Returns:
    %     bootstrapGammasVec (vector): Vector of PWM estimates for each 
    %         bootstrap sample.

    % Extract dimensions
    [~, numBootstrapSamples] = size(candidateBootstrapSamples);
    
    % Create vector to hold bootstrap estimates
    bootstrapGammasVec = nan(numBootstrapSamples, 1);
    
    % Loop through samples
    for sampleID = 1:numBootstrapSamples
        % Extract and sort sample
        bootstrapSample = sort(candidateBootstrapSamples(:, sampleID));
        
        % Apply the PWM estimator
        bootstrapGammasVec(sampleID) = ...
            pwmEstimator(bootstrapSample, kCandidate);
    end
end