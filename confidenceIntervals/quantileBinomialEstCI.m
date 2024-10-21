function [quantileEst, quantileCIs] = quantileBinomialEstCI(...
                    dataVector, q, alphaCI, sorted...
                    )
    % QUANTILEBINOMIALCI Computes the qth sample quantile by interpolation 
    %   and returns a binomial (1-alpha)x100% confidence interval.
    %   q can be a row vector.
    %
    % Args:
    %     dataVector (vector): The data from which to compute the quantiles
    %     q (vector): A row vector of target quantiles.
    %     alphaCI (scalar): The alpha level for the confidence interval.
    %     sorted (logical): Indicates if dataVector is already sorted, set
    %                       1 if already sorte
    %
    % Returns:
    %     quantileEst (vector): Interpolated estimated quantiles
    %     quantileCIs (matrix): Matrix of confidence intervals for target
    %                           quantiles, each column corresponds to
    %                           different quantile; first row is the lower
    %                           bound

    
    % Sort the data vector if not already sorted
    if sorted ~= 1
        dataVector = sort(dataVector);
    end
    
    N = length(dataVector);        % Number of observations
    R = (N + 1) * q;               % Rank of the qth quantile
    r = floor(R);                  % Integer part of the rank
    f = R - r;                     % Fractional part of the rank
    dataVector(N+1) = dataVector(N); % Extend the data for interpolation
    dataVector(N+2) = dataVector(N);
    
    % Compute the qth quantile by linear interpolation
    quantileEst = dataVector(r) + f' .* (dataVector(r + 1) - dataVector(r));
    % Ensure that a row vector is returned
    if ~isrow(quantileEst)
        quantileEst = quantileEst';
    end
    
    % Compute the binomial confidence intervals
    t = binoinv(alphaCI, N, q) - 1;
    u = binoinv(1 - alphaCI, N, q);
    
    % Adjustments for confidence intervals
    g = (alphaCI - binocdf(t, N, q)) ./ (binocdf(t + 1, N, q) - binocdf(t, N, q));
    h = (alphaCI - 1 + binocdf(u, N, q)) ./ (binocdf(u, N, q) - binocdf(u - 1, N, q));
    
    % Compute the lower and upper bounds of the confidence intervals
    cl = dataVector(t + 1) + g' .* (dataVector(t + 2) - dataVector(t + 1));
    cu = dataVector(u + 1) - h' .* (dataVector(u + 1) - dataVector(u));

    if ~isrow(cl)
        cl = cl';
        cu = cu';
    end

    % Return array of CIs 
    quantileCIs = [cl; cu];
end
