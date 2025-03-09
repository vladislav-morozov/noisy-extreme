% ===========================================================
% File: quantileEstCIArray.m
% Description: This file implements a class for conveniently
%              storing estimation results for the empirical
%              application.
% ===========================================================
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Author: Vladislav Morozov
% ===========================================================

classdef quantileEstCIArray
    % quantileEstCIArray A class to hold estimation results for 
    % multiple confidence intervals and quantile estimators. The class
    % carries the context about the corresponding 
    
    properties
        characteristics; % (table) Description of the dataset on which the
                         % results are based (UA, sector, etc) 
        fittedCIs;       % (cell) Array of fitted quantiles and CIs
        gammaLeft;       % (double vector) estimates of the left tail 
                         % extreme value index
        gammaRight;      % (double vector) estimates of the right tail 
                         % extreme value index
        gammaKVector;    % (integer vector) values of intermediate order 
                         % statistic k used in estimation of gamma
        kLeftOpt;        % (integer) optimal value of k for the left tail
        kRightOpt;       % (integer) optimal value of k for the right tail
        meanTFP;         % (float) average of sample
        varTFP;          % (float) variance of sample
        N;               % (integer) sample size
    end
    
    methods
        % Constructor
        function resultArray = ...
                quantileEstCIArray(characterstics, ...
                fittedCIs, ...
                gammaKValues, ...
                gammaLeft, gammaRight, ...
                kLeftOpt, kRightOpt, ...
                meanTFP, varTFP, ...
                N)
            % quantileEstCIArray Create an instance with results. 
            %
            % Args:
            %     characterstics (table): description of the dataset in
            %       table form. Corressponds to the format used to filter
            %       the main dataset.
            %     fittedCIs (cell): array of fitted 
            %       quantileEstimatorConfidenceIntervalArray objects.
            %     gammaLeft (double vector): estimates of the left tail 
            %       extreme value index. Each value is based on the
            %       corresponding entry in gammaKVector
            %    gammaRight (double vector): estimates of the right tail 
            %       extreme value index
            %    gammaKVector (integer vector): values of intermediate order 
            %       statistic k used in estimation of gamma
            %    kLeftOpt (integer): optimal value of k for the left tail
            %    kRightOpt (integer): optimal value of k for the right tail
            %    meanTFP (float): average of sample
            %    varTFP (float): variance of sample
            %    N (integer): sample size
            %
            % Returns:
            %     resultArray (quantileEstCIArray): An instance of 
            %         simResultArray with given context and CIs/quantiles.
                                                                                            
            resultArray.characteristics = characterstics; 
            resultArray.fittedCIs = fittedCIs;
            resultArray.gammaKVector = gammaKValues;
            resultArray.gammaLeft = gammaLeft;
            resultArray.gammaRight = gammaRight;
            resultArray.kLeftOpt = kLeftOpt;
            resultArray.kRightOpt = kRightOpt;
            resultArray.meanTFP = meanTFP;
            resultArray.varTFP = varTFP;
            resultArray.N = N;
        end
    end
end