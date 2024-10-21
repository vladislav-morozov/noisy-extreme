% ===========================================================
% File: simResultArray.m
% Description: This file implements a handle class for conveniently storing
% the detailed simulation results.
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
% ===========================================================

classdef simResultArray < handle
    % SIMRESULTARRAY A handle class to hold simulation results for 
    % confidence intervals and quantile estimators. Results are organized 
    % in matrices where rows index datasets and columns index target 
    % quantiles.
    
    properties
        approachName;          % (string) Name of approach being evaluated
        targetQuantiles;       % (double, vector) Target quantiles (between
                               % 0 and 1)
        trueQuantileValues;    % (double, vector) Values of true quantiles 
        ciCovers;              % (double, matrix) whether the CI covers the
                               % true quantile
        ciLength;              % (double, matrix) Lengths of the CI
        estError;              % (double, matrix) Error made by estimator
    end
    
    methods
        % Constructor
        function resultArray = ...
                simResultArray(estCIArray, trueQuantileValues, numSamples)
            % SIMRESULTARRAY Create an instance. Preallocates space for 
            % saving the results of simulations and saves the name of the
            % associated method.
            %
            % Args:
            %     estCIArray (quantileEstimatorConfidenceIntervalArray): 
            %         An instance of the quantile estimator confidence 
            %         interval array.
            %     trueQuantileValues (double, vector): Vector of true 
            %         quantiles targeted.
            %     numSamples (int): Number of samples in the simulation.
            %
            % Returns:
            %     resultArray (simResultArray): An instance of 
            %         simResultArray with allocated space for results and
            %          method name saved.
            
            % Extract approach name
            resultArray.approachName = estCIArray.machineReadableName;
            
            % Attach true quantiles
            resultArray.trueQuantileValues = trueQuantileValues;
            
            % Allocate space for results for simulations
            resultArray.ciCovers = ...
                NaN(numSamples, length(trueQuantileValues));
            resultArray.ciLength = ...
                NaN(numSamples, length(trueQuantileValues));
            resultArray.estError = ...
                NaN(numSamples, length(trueQuantileValues));
        end
        
        % Method for inserting a row
        function updateRow(this, fittedEstCIArray, rowID)
            % UPDATEROW Updates row number rowID using the results in
            % fittedEstCIArray. Note: rows correspond to datasets, columns
            % correspond to quantiles in the trueQuantileValues vector.
            %
            % Args:
            %  fittedEstCIArray (quantileEstimatorConfidenceIntervalArray):
            %         A fitted instance of a
            %         quantileEstimatorConfidenceIntervalArray.
            %  rowID (int): The row number to update.
            %
            % Updates:
            %  ciCovers: whether corresponding quantile is covered by CIs
            %            in given dataset 
            %  ciLength: length of CI for corresponding quantile
            %  estError: error in estimating given quantile
            
            % Update coverage matrix
            this.ciCovers(rowID, :) = ...
                fittedEstCIArray.computeCoverage(this.trueQuantileValues);
            
            % Update length matrix
            this.ciLength(rowID, :) = ...
                fittedEstCIArray.computeLengths();
            
            % Update estimator error matrix
            this.estError(rowID, :) = ...
                fittedEstCIArray.computeEstErrors(this.trueQuantileValues);
        end
    end
end
