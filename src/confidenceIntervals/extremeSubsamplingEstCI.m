function [subsampleExtremeEst, subsampleExtremeInt] = ...
    extremeSubsamplingEstCI(thetaVector, targetQuantiles, alphaCI, ...
        denominatorParam, subsampleSize, numSubsamples)
    % EXTREMESUBSAMPLINGESTCI Computes quantile estimators and confidence 
    % intervals for quantiles using the feasible extreme value theorem with 
    % subsampled quantiles.
    %
    % Subsample size subsampleSize may be chosen using the minimum 
    % volatility method or set directly. In the latter case, subsampleSize 
    % should be a number. Any non-numeric value will instead use the 
    % minimum volatility method.
    %
    % Args:
    %     thetaVector (vector): A presorted vector of data.
    %     targetQuantiles (vector): A vector of target quantiles.
    %     alphaCI (float): Significance level for the confidence intervals.
    %     denominatorParam (string or int): If "sample", the denominator 
    %         uses the corresponding sample quantile. If a positive 
    %         integer, the corresponding order statistic is used.
    %     subsampleSize (int or string): Size of   subsamples to be drawn.
    %     numSubsamples (int): The number of subsamples to draw.
    %
    % Returns:
    %     subsampleExtremeEst (vector): Quantile estimators.
    %     subsampleExtremeInt (matrix): Confidence intervals for quantiles.
    
    N = length(thetaVector);
    
    % TUNING PARAMETERS: Note that the minimum volatility method requires
    % selecting a range of candidate values and the size of the moving 
    % window. The results are not sensitive to these choices. The following 
    % values are used by default, but they can be replaced with arguments.
    candidateSizes = floor(linspace( 0.7*N^(4/5), 2*N^(4/5), 20));
    mvMovingAverageSize = 5;
    
    % Check which version of subsampling to apply
    if isnumeric(subsampleSize)
        % Run subsampling with specified numeric sample size
        subsampleSize = floor(subsampleSize);
        [subsampleExtremeEst, subsampleExtremeInt] = ...
            computeSubsampledEstCI(thetaVector, targetQuantiles, ...
            alphaCI, denominatorParam, subsampleSize, numSubsamples);
    else
        % Run minimum volatility 
        % Allocate intervals
        estimatesMV = ...
            NaN(length(candidateSizes), length(targetQuantiles));
        intervalsMV = ...
            NaN(2, length(targetQuantiles), length(candidateSizes));
        
        % Compute intervals for each candidate size
        for candidateSizeID = 1:length(candidateSizes)
            % Compute the subsampling intervals
            candidateSize = candidateSizes(candidateSizeID);
            [estimatesMV(candidateSizeID, :), ...
                intervalsMV(:, :, candidateSizeID)] = ...
                computeSubsampledEstCI(thetaVector, targetQuantiles, ...
                alphaCI, denominatorParam, candidateSize, numSubsamples);
        end
        
        % Compute moving variance of interval sizes
        endpointVariances = movvar(intervalsMV, mvMovingAverageSize, 1, 3);
        
        % Sum endpoint variances and squeeze the result
        % Note that columns index candidate sizes and row index quantiles
        endpointVariances = squeeze(sum(endpointVariances, 1));
        
        % Coordinates of minimum volatility choice
        [~, bestSizeIDs] = min(endpointVariances, [], 2);
        
        % Construct intervals 
        indInt1 = ...
            sub2ind(size(intervalsMV), 1, ...
            1:length(targetQuantiles), bestSizeIDs');
        indInt2 = ...
            sub2ind(size(intervalsMV), 2, ...
            1:length(targetQuantiles), bestSizeIDs');
        subsampleExtremeInt = [intervalsMV(indInt1); intervalsMV(indInt2)];
        
        % Repeat the minimum volatility construction for the estimators
        estVariances = movvar(estimatesMV, mvMovingAverageSize, 1, 2);
        [~, bestSizeIDs] = min(estVariances, [], 1);
        indEst = ...
            sub2ind(size(estimatesMV), ...
            bestSizeIDs, 1:length(targetQuantiles));
        subsampleExtremeEst = estimatesMV(indEst);
    end
end



function [subsampleExtremeEst, subsampleExtremeInt] = ...
    computeSubsampledEstCI(thetas, targetQuantiles, alphaCI, ...
    denominatorParam, subsampleSize, numSubsamples)
    % COMPUTESUBSAMPLEDESTCI Computes median-unbiased estimator and CIs for 
    % target quantiles using subsampling.
    %
    % Args:
    %     thetas (vector): A presorted vector of data.
    %     targetQuantiles (vector): A vector of target quantiles.
    %     alphaCI (float): Significance level for the confidence intervals.
    %     denominatorParam (string or int): If "sample", uses the
    %         corresponding sample quantile. If a positive integer, the
    %         corresponding order statistic is used.
    %     subsampleSize (int): The size of the subsamples to be drawn.
    %     numSubsamples (int): The number of subsamples to draw.
    %
    % Returns:
    %     subsampleExtremeEst (vector): Median-unbiased estimator for 
    %                                   quantiles.
    %     subsampleExtremeInt (matrix): Confidence intervals, columns
    %                                   correspond to quantiles.
    
    % Do subsampling
    subsampledValuesW = ...
        computeSelfNormalizedStatisticSubsamples(thetas, targetQuantiles, ...
        denominatorParam, subsampleSize, numSubsamples);
    
    % Extract critical values
    critValues = ...
        quantile(subsampledValuesW, [alphaCI / 2, 1 - alphaCI / 2, 1 / 2]);
    
    % Compute estimators and intervals
    numerator = thetas(ceil(length(thetas) * targetQuantiles));
    if isnumeric(denominatorParam)    
        % Use the presupplied q
        denominator = thetas(end - denominatorParam);
       
    else
        % Set q to match the corresponding sample quantile
        denominator = numerator;
    end
    
    % Form the estimator
    subsampleExtremeEst = ...
        numerator' - critValues(3, :) .* (denominator' - thetas(end));
    
    % Form the confidence interval
    subsampleExtremeInt = ...
        [numerator' - critValues(1, :) .* (denominator' - thetas(end));
         numerator' - critValues(2, :) .* (denominator' - thetas(end))];
end



function subsampledValuesW = ...
    computeSelfNormalizedStatisticSubsamples(thetas, targetQuantiles, ...
        denominatorParam, subsampleSize, numSubsamples)
    % COMPUTESELFNORMALIZEDSTATISTICSUBSAMPLES Computes the subsampling 
    % statistic W based on data. 
    %
    % Args:
    %     thetas (vector): A presorted vector of data.
    %     targetQuantiles (vector): A vector of target quantiles.
    %     denominatorParam (string or int): If "sample", the denominator 
    %         uses the corresponding sample quantile. If a positive 
    %         integer, the corresponding order statistic is used.
    %     subsampleSize (int): The size of the subsamples to be drawn.
    %     numSubsamples (int): The number of subsamples to draw.
    %
    % Returns:
    %     subsampledValuesW (matrix): A matrix of subsampled statistics W. 
    %         Each row corresponds to a subsample, and each column 
    %         corresponds to a target quantile.

    % Obtain sample size
    N = length(thetas);
    % Number of quantiles to target
    numTargetQuantiles = length(targetQuantiles);
    % Extract sample quantiles corresponding to targetQuantiles
    lNum = (1 - targetQuantiles) * N; % constant l of F^{-1}(1-l/N)
    % Correct l used in the denominators to prevent divison by zero
    lDenom = max(ceil(lNum), 1);
    centeringTheta = thetas(floor(N - N * lNum / subsampleSize));
    
    % Allocate space for values of subsampled statistic W
    subsampledValuesW = zeros(numSubsamples, numTargetQuantiles);  

    indices = randi(N, subsampleSize, numSubsamples);
    % Draw subsamples
    for subsampleID = 1:numSubsamples
        % Draw subsample, sort it, extract
        currentSubsample = thetas(indices(:, subsampleID));
        sampleSorted = sort(currentSubsample);
        % Check how to handle the denominator
        if isnumeric(denominatorParam)
            % Use the presupplied q
            subsampledValuesW(subsampleID, :) = ...
                (sampleSorted(subsampleSize - floor(lNum))' - centeringTheta') ./ ...
                (sampleSorted(end - denominatorParam) - sampleSorted(end));
        else
            % Set q to match the corresponding sample quantile, except when
            % it leads to 0 denominator

            subsampledValuesW(subsampleID, :) = ...
                (sampleSorted(subsampleSize - ceil(lNum))' - centeringTheta') ./ ...
                (sampleSorted(subsampleSize - ceil(lDenom))' - sampleSorted(end));
        end
    end
end