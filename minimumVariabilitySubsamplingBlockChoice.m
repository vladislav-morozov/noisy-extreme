% Sample time series data
data = randn(1000, 1); % Replace with your time series data

% Define block sizes to evaluate
block_sizes = 1:50;

% Function to calculate the subsampling estimator variance
function var_est = subsample_var(data, block_size)
    n = length(data);
    num_blocks = floor(n / block_size);
    block_means = zeros(num_blocks, 1);
    for i = 1:num_blocks
        block_means(i) = mean(data((i-1)*block_size + 1:i*block_size));
    end
    var_est = var(block_means);
end

% Calculate variances for different block sizes
variances = arrayfun(@(b) subsample_var(data, b), block_sizes);

% Find the block size with minimum variance
[min_variance, optimal_block_size] = min(variances);

% Display the optimal block size
fprintf('Optimal block size: %d\n', optimal_block_size);
