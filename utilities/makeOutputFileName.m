function fileName = ...
    makeOutputFileName(thetaSampler, uSampler, ...
                       N, T, ...
                       numSamples, simContext)
    % makeOutputFileName Generates a standardized file name for simulation
    % output.
    %
    % Constructs a file name string for saving simulation results based on
    % input parameters and sampler properties. The generated file name
    % follows a specific format to capture key simulation details.
    %
    % Args:
    %     thetaSampler (dataSampler): Instance of the dataSampler class 
    %         representing the distribution for theta coefficients.
    %     uSampler (dataSampler): Instance of the dataSampler class 
    %         representing the distribution for u (error terms).
    %     N (int): Cross-sectional sample size (number of individuals).
    %     T (int): Number of time periods (cross-sections).
    %     numSamples (int): Number of Monte Carlo samples in the simulation
    %     simContext (str): String identifier for the simulation context 
    %         (e.g., 'baseline' or other experiment descriptors).
    %
    % Returns:
    %     fileName (str): Constructed file name including all relevant 
    %         parameters, saved in the 'outputs' folder, with format:
    %         'outputs/[simContext]_samples_[numSamples]_N_[N]_T_[T]_...
    %          F_[thetaDistr]_[thetaParam]_[thetaParamValue]_...
    %          G_[uDistr]_[uParam]_[uParamValue].mat'
    %
    % Example:
    %     fileName = ...
    %       makeOutputFileName(thetaSampler, uSampler, ...
    %                           100, 50, ...
    %                           1000, 'base');
    % Returns a filename string similar to:
    % 'outputs/...
    % base_samples_1000_N_100_T_50_F_Normal_mu_0_G_Uniform_max_1.mat'
    
    % Construct the file name using strings with specified structure
    fileName = sprintf(['outputs/%s_samples_%d_N_%d_T_%d', ...
        '_F_%s_%s_%d_G_%s_%s_%d.mat'], ...
        simContext, ...                   % Simulation context
        numSamples, ...                   % Number of samples
        N, T, ...                         % Sample size and cross-sections
        thetaSampler.distrMachineName, ... % Theta distr name
        thetaSampler.paramMachineName, ... % Theta distr parameter name
        thetaSampler.paramValue, ...      % Theta distr parameter value
        uSampler.distrMachineName, ...    % u distr name
        uSampler.paramMachineName, ...    % u distr parameter name
        uSampler.paramValue);             % u distr parameter value
end
