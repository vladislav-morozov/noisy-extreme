function resultsArray = updateSimResultArrays(resultsArray, ...
    ciCoversTemp, ciLengthsTemp, estErrorsTemp)
% updateSimResultArrays Updates the results array.
% Inserts the corresponding simulation results into each component 
% of the resultsArray.
%
% Args:
%     resultsArray (cell): Cell array of simResultArray instances.
%     ciCoversTemp (double, 3D array): 3D array where rows index datasets,
%         columns index quantiles, and the third dimension indexes methods. 
%         Third dimension must match the number of arrays in resultsArray.
%     ciLengthsTemp (double, 3D array): 3D array of CI lengths.
%     estErrorsTemp (double, 3D array): 3D array of estimator errors.
%
% Returns:
%     resultsArray (cell): Updated cell array of simResultArray instances.

    % Extract number of methods
    numMethods = length(resultsArray);

    % Loop over methods (the third dimension of arrays)
    for methodID = 1:numMethods
        % Update coverage matrix for each method
        resultsArray{methodID}.ciCovers = ...
            squeeze(ciCoversTemp(:, :, methodID));
        
        % Update length matrix for each method
        resultsArray{methodID}.ciLength = ...
            squeeze(ciLengthsTemp(:, :, methodID));
        
        % Update estimator error matrix for each method
        resultsArray{methodID}.estError = ...
            squeeze(estErrorsTemp(:, :, methodID));
    end
end
