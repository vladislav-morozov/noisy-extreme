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
        function this = dataSampler()
            % Constructor code here
        end
        
        % Drawing samples from this instance
        function sample = generateSamples(this)
            % Simulation code here
        end
    end
end