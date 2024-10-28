function queue = createParallelProgressBar(totalIterations)
    % createParallelProgressBar Initializes a progress bar for parallel
    % computations. The bar is closed after execution completes. 
    %
    % Args:
    %     totalIterations (int): Total number of iterations for the
    %                            progress bar.
    %
    % Returns:
    %     queue (parallel.pool.DataQueue): DataQueue to receive progress
    %                                      updates.
    %
    % Usage:
    %   1. Insert
    %
    % Example usage in a parallel loop:
    %     nunSamples = 100;
    %     queue = createParallelProgressBar(numSamples);
    %     parfor i = 1:numSamples
    %         % Simulate computation
    %         pause(0.1);
    %         % Update progress bar
    %         send(queue, i);
    %     end

    % Initialize DataQueue and Progress Bar
    queue = parallel.pool.DataQueue;
    progressBar = waitbar(0, 'Processing...', 'Name', 'Computation Progress');
 
    % Reset persistent variable count
    persistent count
    count = 0;

    % Nested function to update progress
    function updateProgress(~)

        count = count + 1;
        waitbar(count / totalIterations, progressBar, ...
            sprintf('Processing... %.1f%%', ...
            100 * count / totalIterations));
        if count == totalIterations
            close(progressBar);
            count = [];
        end
    end

    % Add listener to the DataQueue
    afterEach(queue, @updateProgress);

    
end
