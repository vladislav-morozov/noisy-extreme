function varianceEstimator = noisyExtreme_OLSvarianceEstimator(y, x, individualEstimators)
    % noisyExtreme_OLSvarianceEstimator Constructs  covariance matrices
    % for all individual estimators


    [T, N, k] = size(x);
    varianceEstimator = zeros(k,k, N);
    sigmaHatSq = zeros(N,1);
    for i=1:N
       H = squeeze(x(:,i,:));
       errorsVectorI = y(1:end,i)-H*individualEstimators(:,i);
       sigmaHatSq(i) = errorsVectorI'*errorsVectorI/(T-k);
       varianceEstimator(:, :, i)= (H'*H)\eye(k)*sigmaHatSq(i) ;  
    end
end