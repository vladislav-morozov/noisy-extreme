function simResultArrayInstances = ...
    createSimResultArrays(ciMethodsArray, trueQuantileValues, numSamples)
% createSimResultArrays Creates and initializes simResultArray instances.
%
% Args:
%     ciMethodsArray (cell): cell array with methods array, each one will
%                            be used as a base for a simResultArray 
%     trueQuantileValues (double, vector): vector of target true quantiles
%     numSamples (int): number of datasets drawn in the simulation.
%
% Returns:
%     simResultArrayInstances (cell): cell array of initialized 
%                                     simResultArray instances.

    % Extract the number of methods
    numInstances = length(ciMethodsArray);

    % Initialize cell array to hold simResultArray instances
    simResultArrayInstances = cell(1, numInstances);
    
    % Loop over methods 

    for methodID = 1:numInstances
        % Create corresponding simResultArray instance
        simResultArrayInstances{methodID} = ...
            simResultArray(ciMethodsArray{methodID}, ...
            trueQuantileValues, numSamples);
    end
end
