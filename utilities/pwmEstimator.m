function [gammaPWM, sigmaPWM] = pwmEstimator(thetaSorted, kVector)
    % pwmEstimator Implements the probability-weighted moment (PWM) 
    % estimators of Hosking and Wallis (1987) for the tail index and scale 
    % parameters of a generalized Pareto distribution.
    %
    % Args:
    %     thetaSorted (vector): A sorted vector of data.
    %     kVector (vector): A vector of integers specifying the number of  
    %         top order statistics to use.
    %
    % Returns:
    %     gammaPWM (vector): Vector with estimates for the extreme value
    %       index, each coordinate corresponds to the value of k specified  
    %       in kVector. 
    %     sigmaPWM (vector): Analogous vector with estimates for
    %       the scale parameters.
    %
    % References:
    %     Hosking, J. R. M., & Wallis, J. R. (1987). Parameter and Quantile
    %     Estimation for the Generalized Pareto Distribution.
    %     Technometrics, 29(3), 339–349. https://doi.org/10.2307/1269343
    
    % Total number of values of k to compute
    numK = length(kVector);
    
    % Allocate spaces for estimates
    gammaPWM = zeros(numK, 1);
    sigmaPWM = zeros(numK, 1);
    
    % Loop through the values of k
    for kID = 1:numK
        % Extract current k
        kLoop = kVector(kID);
        
        % Compute the estimates
        thetaData = thetaSorted(end - kLoop + 1:end);
        
        Pn = mean(thetaData - thetaData(1));
        w = (kLoop - 1:-1:0) / kLoop;
        Qn = (w * (thetaData - thetaData(1))) / kLoop;
        
        gammaPWM(kID) = (Pn - 4 * Qn) / (Pn - 2 * Qn);
        sigmaPWM(kID) = 2 * Pn * Qn / (Pn - 2 * Qn);
    end
end
