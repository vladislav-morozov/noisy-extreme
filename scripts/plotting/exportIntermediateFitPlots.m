% ===========================================================
% File: exportIntermediateFitPlots.m
% Description: This script exports the figures based on simulations for
%              checking the quality of the normal approximation in the
%              feasible intermediate extreme order theoem
%
% ===========================================================
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Author: Vladislav Morozov
%
% This script exports the following groups of plots:
%   1. Online appendix plots on quality of approximation in the IVT.
%
% Created figures are saved in the 'results/figures/' folder.
% ===========================================================

% --- Plot configuration ---
 
% Load in plot configurations
setPlottingParameters                       % General plotting parameters
quantileIDS = [1, 11, 19, 37];              % Indices of quantiles to plot
dgpsPlot = dgps([1, 2, 4, 6], :);           % Select specific DGPs


% --- Plot generation ---

% Create figure
figure('Renderer', 'painters', ...
    'Position', [50 50 800 500]);

% Use tight_subplots
[has, ~] = tight_subplot(length(quantileIDS), height(dgpsPlot), [.07 .036], [.07 .135],[.115 .04]);

% Loop through DGP IDs
for DGP_ID = 1:height(dgpsPlot)

    % Extract samplers 
    thetaSampler = dgpsPlot{DGP_ID, 1}{1};
    uSampler = dgpsPlot{DGP_ID, 2}{1};

    % Extract sample sizes
    N = dgpsPlot{DGP_ID, 3};
    T = dgpsPlot{DGP_ID, 4};
    
    % Load in corresponding simulation result file
    fileName = makeOutputFileName(...
        thetaSampler, uSampler, ...
        N, T, ...
        numSamples, plotContext);
    load(fileName)

    % Loop through quantile indices
    for quantPos = 1 : length(quantileIDS)
        
        % Create subplot
        axes(has(DGP_ID + (quantPos-1)*(height(dgpsPlot))))

        % Check if construction of statistic failed
        if length(unique(ivtArray(:, quantileIDS(quantPos)))) <= 2
            % If failed, add a dummy plot to set axis limits
            plot(xValues, 0.45)
            ylim([0, 0.45])

            % Plot N/A text
            text('String', '$N/A$', ...
                'Units', 'normalized', ...
                'Position', [0.4, 0.5], ...  
                'HorizontalAlignment', 'left', ...
                'FontSize', 10);

            % Skip further plotting for this (DGP, Quantile) combiation
            continue
        end

        % Plot the distribution of the statistic
        kdes = ksdensity(ivtArray(:, quantileIDS(quantPos)), xValues);
        plot(xValues, kdes, ...
            'LineWidth', plotLineThickness)

        % Superimpose normal density
        hold on
        plot(xValues, normpdf(xValues), ...
            'LineWidth', 2, ...
            'LineStyle','--')

        % Set y-limits
        ylim([0, 0.45])

        % Set tick labels to only appear on the edge subplots
        if quantPos ~= length(quantileIDS)
            xticklabels([])
        end

        % Add y tick labels only to the leftmost plots
        if DGP_ID ~= 1
            yticklabels([])
        end

        % Add sample sizes to top row
        if quantPos == 1
            % Add a title to the subplot and left-justify it
            ttl = title("N="+num2str(N));
            ttl.Units = 'Normalize';
            ttl.Position(1) = 0;
            ttl.HorizontalAlignment = 'left';
        end

    end
    
    % Add legend to the last subplot
    if DGP_ID == height(dgpsPlot)
        legend('IVT Statistic', 'N(0, 1)', ...
            'Position', [0.914, 0.905, 0, 0])
    end
end

% Add suptitle
sgtitle("Distribution of Self-Normalized Intermediate Statistic vs. N(0, 1)")
 
% Add quantile labels to rows
text('String', '$\tau=0.90$', ...
     'Units', 'normalized', ...
     'Position', [-4.15, 4.9], ...  
     'HorizontalAlignment', 'left', ...
     'FontSize', 10);

text('String', '$\tau=0.95$', ...
     'Units', 'normalized', ...
     'Position', [-4.15, 3.4], ... 
     'HorizontalAlignment', 'left', ...
     'FontSize', 10);

text('String', '$\tau=0.99$', ...
     'Units', 'normalized', ...
     'Position', [-4.15, 1.95], ...  
     'HorizontalAlignment', 'left', ...
     'FontSize', 10);

text('String', '$\tau=0.999$', ...
     'Units', 'normalized', ...
     'Position', [-4.15, 0.45], ...  
     'HorizontalAlignment', 'left', ...
     'FontSize', 10);

% Prepare export settings for PDF
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

% Export as PDF
print(gcf, figureSavingName, '-dpdf');