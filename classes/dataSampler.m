classdef dataSampler
    %DATASAMPLE Value class
    properties
       distrMachineName;
       distrLegendName;
       paramMachineName;
       paramLegendName;
       paramValue
       gammaSign;
       finiteLeftEndpoint;
       finiteRightEndpoint;
    end

    methods
        function this = dataSampler()
            % Constructor code here
        end

        function sample = generateSamples(this)
            % Simulation code here
        end
    end
end