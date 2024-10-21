% ===========================================================
% File: dataSampler.m
% Description: This file implements a value class for data generating
% processes used for coefficients and idiosyncratic shocks. 
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
%
% ===========================================================

classdef dataSampler
    %DATASAMPLER Class for sampling from one-dimensional distributions
    %controlled by 1 parameter. Value class

    properties
       distrInverse;         % inverse of CDF, depends on u\in[0, 1] and 
                             % parameters
       distrMachineName;     % Name used for saving the results 
                             % e.g., "frechet"
       distrLegendName;      % Name used in plots (e.g. 'F_{Fr, \kappa}')
       paramMachineName;     % Name of parameter used for saving results
                             % e.g. 'kappa'
       paramLegendName;      % Name of parameter used for plotting
                             % e.g. '\kappa'
       paramValue;           % Value used for the parameter
       gammaSignRight;       % Sign of EV index for the right tail
       finiteRightEndpoint   % Whether the right endpoint is finite 
       gammaSignLeft;        % Sign of EV index for the left tail  
       finiteLeftEndpoint;   % Whether the left endpoint is finite 
    end

    methods
        function sampler = dataSampler(distrInverse, ...
                distrMachineName, distrLegendName, ...
                paramMachineName, paramLegendName, ...
                paramValue, ...
                gammaSignRight, finiteRightEndpoint, ...
                gammaSignLeft, finiteLeftEndpoint)
            %DATASAMPLER Constructs an instance of dataSampler using
            % specified parameter values. If no values are given regarding
            % the left endpoint parameters, those are set to NaN

            % Initialize properties
            sampler.distrInverse = distrInverse;
            sampler.distrMachineName = distrMachineName;
            sampler.distrLegendName = distrLegendName;
            sampler.paramMachineName = paramMachineName;
            sampler.paramLegendName = paramLegendName;
            sampler.paramValue = paramValue;
            sampler.gammaSignRight = gammaSignRight;
            sampler.finiteRightEndpoint = finiteRightEndpoint;

            % Set left tail parameters to NaN if not provided
            if nargin < 10
                sampler.gammaSignLeft = NaN;
                sampler.finiteLeftEndpoint = NaN;                
            else
                sampler.gammaSignLeft = gammaSignLeft;
                sampler.finiteLeftEndpoint = finiteLeftEndpoint;
            end
        end
        
        % Method for drawing samples from this instance
        function rand_sample = sample(this, numSamples)
            %SAMPLE Draws numSamples iid observations using the
            % distrInverse with the specified paramValue

            % Draw a uniform sample
            unifSample = rand(numSamples, 1);

            % Take the integral transform to obtain the sample of interest
            rand_sample = this.distrInverse(unifSample, this.paramValue);
        end

    end
end