function [Wmax, Wq, Wmixed] =  noisyExtreme_subsamplingExtremeQuantiles(thetas, k, b, nSubsamples, quantilesConsidered)
% noisyExtreme_subsamplingExtremeQuantiles Forms the subsampling
% estimator using subsamples of size b from the noisy observations thetas.
% thetas must be presorted
% nSubsamples is used.  
% k is the order for the denominator
% quantiles is the vector of quantiles to consider. 
% If 1 is included, it's handled separately

    
    b =  floor(b); % round subsample size
    N = length(thetas);
    % Select centering constants
    Q = length(quantilesConsidered);
    l = (1-quantilesConsidered)*N; % constant l of F^{-1}(1-l/N)
    centeringTheta = thetas(floor(N- N*l/b)); % centering
    Wq = zeros(nSubsamples, Q); % store computed values
    Wmax = zeros(nSubsamples, Q); % store computed values
    Wmixed = zeros(nSubsamples, Q); % store computed values
 
    for s=1:nSubsamples
           sampleS = randsample(thetas, b); % draw subsample 
           sampleSorted = sort(sampleS);
           sampleOrderS = maxk(sampleS, k);
%            
%            Ws(s, :) = (sampleOrderS(1)-centeringTheta')/(sampleOrderS(k)-sampleOrderS(1));
%            
           % Using the maximum for all, only l changes 
           Wmax(s, :) = (sampleSorted(end)-centeringTheta')./(sampleSorted(end-k)-sampleSorted(end));
           % Using order statistic corresponding to l in the numerator and
           % denominator
           Wq(s, :) = (sampleSorted(b-ceil(l))'-centeringTheta')./(sampleSorted(b-ceil(l))'-sampleSorted(end));
           % Using order statistic in the numberator, fixed statistic in
           % the denominator
           Wmixed(s, :) = (sampleSorted(b-floor(l))'-centeringTheta')./(sampleSorted(end-k)-sampleSorted(end));
           
    end
    

end