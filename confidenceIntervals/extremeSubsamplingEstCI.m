function [subsampleExtremeEst, subsampleExtremeInt] = extremeSubsamplingEstCI(alphaCI, thetaVector, denominatorParam, subsampleSize, ...
            numSubsamples, targetQuantiles)
% extremeSubsamplingEstCI Computes 
% Subsample size may be chosen using the minimum volatility method or set
% directly

    N = length(thetaVector);
    
    % TUNING PARAMETERS: Note that the minimum volatility method requires
    % selecting a range of candidate values and the size of the moving window.
    % The results are not sensitive to these choices. The following values are
    % used by default, but they can be replaced with arguments
    candidateSizes = floor((0.25:0.05:2)*(N^(4/5)));
    mvMovingAverageSize = 5;

    % Check which version of subsampling to apply
    if isnumeric(subsampleSize)
        % Run subsampling with specified numeric sample size
        subsampleSize = floor(subsampleSize);
        [subsampleExtremeEst, subsampleExtremeInt] = ...
        computeSubsampledEstCI(thetaVector, targetQuantiles, alphaCI, ...
            denominatorParam, subsampleSize, numSubsamples);
    else
        % Run minimum volatility
 
        % Allocate intervals

        % Compute intervals for each candidate size
        for candidateSizeID = 1:length(candidateSizes)
            % Compute the subsampling interval
        end
       
        % Compute moving average of interval sizes
        
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
    l = (1 - targetQuantiles) * N; % constant l of F^{-1}(1-l/N)
    centeringTheta = thetas(floor(N - N * l / subsampleSize));
    
    % Allocate space for values of subsampled statistic W
    subsampledValuesW = zeros(numSubsamples, numTargetQuantiles);  

    % Draw subsamples
    for subsampleID = 1:numSubsamples
        % Draw subsample, sort it, extract
        currentSubsample = randsample(thetas, subsampleSize);
        sampleSorted = sort(currentSubsample);
        % Check how to handle the denominator
        if isnumeric(denominatorParam)
            % Use the presupplied q
            subsampledValuesW(subsampleID, :) = ...
                (sampleSorted(subsampleSize - floor(l))' - centeringTheta') ./ ...
                (sampleSorted(end - denominatorParam) - sampleSorted(end));
        else
            % Set q to match the corresponding sample quantile
            subsampledValuesW(subsampleID, :) = ...
                (sampleSorted(subsampleSize - ceil(l))' - centeringTheta') ./ ...
                (sampleSorted(subsampleSize - ceil(l))' - sampleSorted(end));

        end
    end
end
