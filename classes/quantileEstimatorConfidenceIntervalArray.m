classdef quantileEstimatorConfidenceIntervalArray < handle
    %quantileEstimatorConfidenceIntervalArray A class for arrays of 
    % quantile estimators and confidence intervals.
    % Supports evaluating length, coverage, and custom methods for 
    % computing the interval.

    properties
        fittingFunction;         % Function that fits computes corrected 
                                 % quantile estimators and confidence 
                                 % interval given a vector of observations
                                 % and targetQuantiles. Must have two
                                 % outputs corresponding to
                                 % fittedQuantileEst and fittedCI formats
        machineReadableName;     % Name used for saving the interval 
                                 % e.g., "extremeSubsampling"
        legendName;              % Mame using for plotting
                                 % e.g., "Extreme approx. (w/ subsampling)"
        targetQuantiles;         % Row vector of target quantiles, 
                                 % Created during fitting
        fittedQuantileEst;       % |targetQuantiles|-vector (row) of 
                                 % corrected sample quantiles
                                 % Created during fitting
        fittedCI;                % 2x|targetQuantiles| of computed CIs for 
                                 % the targetQuantiles
                                 % First row -- lower bound
                                 % Second row -- upper bound
                                 % Created during fitting
    end

    methods
        % Constructor
        function ciArray = ...
                quantileEstimatorConfidenceIntervalArray(...
                fit, machineReadableName, legendName ...
                )
            %quantileEstimatorConfidenceIntervalArray Construct an instance  
            %  Initializes target quantiles, default estimators and CIs,
            %  and sets the specified names.

            % Set the target quantiles
            ciArray.targetQuantiles = [];

            % Default confidence intervals and quantile estimators
            defaultInterval = [];
            defaultInterval(2, :) = Inf;
            defaultInterval(1, :) = -Inf;
            ciArray.fittedCI = defaultInterval;
            ciArray.fittedQuantileEst = [];

            % Attach the fitting function
            ciArray.fittingFunction = fit;

            % Set names
            ciArray.machineReadableName = machineReadableName;
            ciArray.legendName = legendName;
        end

        % Method for fitting the CI
        function this = computeEstimatorsIntervals(...
                this, dataVector, targetQuantiles)
            %computeEstimatorsIntervals Fits the corrected estimators and 
            % confidence intervals. Uses the fit function to compute both
            % based on data vector dataVector and chosen targetQuantiles

            [this.fittedQuantileEst, this.fittedCI] = ...
                this.fittingFunction(dataVector, targetQuantiles);
            this.targetQuantiles = targetQuantiles;
        end

        % Method for computing the length of the interval
        function intervalLengths = computeLengths(this)
            %COMPUTELENGTHS Computes the length of the confidence intervals
            % Returns a vector of interval lengths for each target quantile

            intervalLengths = ...
                abs(this.fittedCI(2, :) - this.fittedCI(1, :));
        end

        % Method for checking whether the interval contains target values
        function containsTargets = checkCoverage(this, trueQuantileValues)
            %CHECKCOVERAGE Checks if the fitted CIs cover the true
            % quantiles. Returns a Boolean vector indicating coverage for
            % each target quantile. trueQuantiles must be the quantiles in
            % this.targetQuantiles.

            containsTargets = ...
                (trueQuantileValues >= this.fittedCI(1, :)) .* ...
                (trueQuantileValues <= this.fittedCI(2, :));
        end

        % Method for computing the error of the estimators
        function errorEstimator = computeEstErrors(...
                this, trueQuantileValues)
            %COMPUTEESTERRORS Computes the errors made by the fitted
            %estimators. Returns a vector matching the dimension of 
            % trueQuantileValues

            errorEstimator = this.fittedQuantileEst-trueQuantileValues;
        end

        % Destructor
        function delete(~)
            %DELETE Destructor for the 
            % quantileEstimatorConfidenceIntervalArray class
 
        end
    end
end
