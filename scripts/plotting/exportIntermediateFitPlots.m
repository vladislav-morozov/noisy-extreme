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
setPlottingParameters                       % general plotting parameters

% --- Plot generation ---


% Create figure
figure('Renderer', 'painters', ...
    'Position', [50 50 800 500]);

% Use tight_subplots
[has, ~] = tight_subplot(2, 3,[.07 .036], [.07 .135],[.05 .04]);

% Loop through DGP IDs
for DGP_ID = 1:height(dgps)
    % Create subplot
    axes(has(DGP_ID))

    % Extract samplers 
    thetaSampler = dgps{DGP_ID, 1}{1};
    uSampler = dgps{DGP_ID, 2}{1};

    % Extract sample sizes
    N = dgps{DGP_ID, 3};
    T = dgps{DGP_ID, 4};
    
    % Load in corresponding simulation result file
    fileName = makeOutputFileName(...
        thetaSampler, uSampler, ...
        N, T, ...
        numSamples, plotContext);
    load(fileName)

    % Plot the distribution of the statistic
    kdes = ksdensity(ivtArray(:, 5), xValues);
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
    if DGP_ID < 4
        xticklabels([])
    end

    if rem(DGP_ID, 3) ~= 1
        yticklabels([])
    end

    % Add a title to the subplot and left-justify it
    ttl = title("N="+num2str(N));
    ttl.Units = 'Normalize';
    ttl.Position(1) = 0;
    ttl.HorizontalAlignment = 'left';

    % Add legend to the last subplot
    if DGP_ID == height(dgps)
        legend('Feasible IVT statistic', 'N(0, 1)', ...
            'Position', [0.864, 0.905, 0, 0])
    end
end

% Add suptitle
sgtitle("Distribution of Self-Normalized Intermediate Statistic vs. N(0, 1)")
 

% Create figure saving name
figureSavingName =   "results/figures/" + ...
    plotContext + "_" + ...
    thetaSampler.distrMachineName + "_" + ...
    uSampler.distrMachineName;

% Export as PNG
set(gcf, 'PaperPosition', [0 0 1.8*8 8])
print(gcf, figureSavingName, '-dpng', '-r300' );

% Prepare export settings for PDF
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% Export as PDF
print(gcf, figureSavingName, '-dpdf');
