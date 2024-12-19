function averageNonNan = ...
    computeCoverageLengthNonNaN(resultsArray, methodID, property)
% computeCoverageLengthNonNaN Computes the average coverage or length only
% across observations where construction was possible.
%
% Args:
%     resultsArray (cell array): Cell array of simResultArray objects.
%     methodID (integer): Coordinate of CI method of interest.
%     property (string): The property to be returned. Allowed values are 
%       'coverage' and 'length'.
%
% Returns:
%     averageNonNan (vector): Vector of averages of the desired property  
%         across samples where construction was possible.
%
% Example:
%     results = {simResultArray1, simResultArray2};
%     methodID = 1;
%     property = 'coverage';
%     averageNonNan = ...
%       computeCoverageLengthNonNaN(results, methodID, property);

    % Extract number of quantiles
    numQuantiles = length(resultsArray{methodID}.trueQuantileValues);

    % Allocate row vector for results
    averageNonNan = nan(1, numQuantiles);

    % Determine which property results to use based on the desired property
    switch property
        case 'coverage'
            fieldName = 'ciCovers';
        case 'length'
            fieldName = 'ciLength';
        otherwise
            error('Invalid results property')
    end

    % Loop through quantiles
    for quantID = 1:numQuantiles
        % Identify successful constructions
        constructionSuccess = ...
            ~isnan(resultsArray{methodID}.ciLength(:, quantID));

        % Extract corresponding properties
        nonNaNProperty = ...
            resultsArray{methodID}.(fieldName)(constructionSuccess, quantID);

        % Compute average
        averageNonNan(quantID) = mean(nonNaNProperty);
    end
end
