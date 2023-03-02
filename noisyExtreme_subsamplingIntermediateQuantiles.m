function C =  noisyExtreme_subsamplingIntermediateQuantiles(alpha, thetas, b, nSubsamples, quantilesConsidered)
% noisyExtreme_subsamplingIntermediateQuantiles Forms the subsampling
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
    k = (1-quantilesConsidered)*N; % constant l of F^{-1}(1-l/N)
    p = floor(sqrt(k));
    centeringTheta = thetas(floor(N- N*k/b)); % centering
 
    I = zeros(nSubsamples, Q); % store computed values
 
    for s=1:nSubsamples
           sampleS = randsample(thetas, b); % draw subsample 
           sampleSorted = sort(sampleS);
 
           I(s, :) = (sampleSorted(b-ceil(k))'-centeringTheta')./(sampleSorted(b-ceil(k))'-sampleSorted(b-ceil(k)-p)');
           
            
    end
    
    C= quantile(I, [alpha/2, 1-alpha/2]);

end