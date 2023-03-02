function [Cmax, Cq, Cmixed] = noisyExtreme_subsamplingCriticalValues(alpha, thetas, k, b, ...
            nSubsamples, quantilesConsidered)
% noisyExtreme_subsamplingCriticalValues Returns critical values for
% extreme order approximations using subsampling.

    % Call subsampling
    [Wmax, Wq, Wmixed] =  noisyExtreme_subsamplingExtremeQuantiles(thetas,...
        k, b, nSubsamples, quantilesConsidered);

    % Return critical values
    Cmax = quantile(Wmax, [alpha/2, 1-alpha/2, 1/2]);
    Cq = quantile(Wq, [alpha/2, 1-alpha/2, 1/2]);
    Cmixed = quantile(Wmixed, [alpha/2, 1-alpha/2, 1/2]);
end