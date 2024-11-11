function matchedVars = findAndCollect(pattern)
% findAndCollect Finds variables matching the given pattern and stores them
% in a cell array.
%
% Args:
%     pattern (char): The pattern to match variable names.
%
% Returns:
%     matchedVars (cell): A cell array containing the matched variables.

    % Find variable names that match the pattern
    varsBase = evalin('base', ['who(''', pattern, '*'')']);
    
    % Initialize the cell array to store the variables
    matchedVars = cell(1, length(varsBase));
    
    % Loop through variable names, retrieve their values, and store in cell array
    for i = 1:length(varsBase)
        matchedVars{i} = evalin('caller', varsBase{i});
    end
end
