% ===========================================================
% File: choosePlotSetsTuningParameters.m
% Description: This script defines parameters for groups of plots regarding
%              the impact of tuning parameters
%
% ===========================================================
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Developed by: Vladislav Morozov
%
% This script sets parameters for plots for the main text or the Online
% Appendix.
%
% Each set of plots is described by a struct with the following fields:
% - destination (string):
%       plot purpose, 'OA' or 'main'.
% - colorField (string): 
%       Name of field containing the color to be used (color or BW).
% - NsPlot (vector):
%       Vector of values of N to plot.
% - TsPlot (vector):
%       Vector of values of T to plot.
% - maxPlotID (int):
%       ID of last line plot to export.
% - minPlotDGP_ID (int):
%       ID of first DGP combination to export.
% - maxPlotDGP_ID (int):
%       ID of last DGP combination to export.
% - margH (vector):
%       Vector of top and bottom margins.
% - legendFontSize (numeric)
%       Font size in legend.
% - legendPosition (vector):
%       Position of legend.
% - intervalSets (arrays):
%       Blocks of intervals to plot
% ===========================================================

%% Plots for the Online Appendix

plotSet{1}.destination = "OA";                            % destination
plotSet{1}.colorField = 'plottingColor';                  % color field name
plotSet{1}.NsPlot = [Ns(1), Ns(2)];                       % N to plot
plotSet{1}.TsPlot = [Ts(1), Ts(end)];                     % T to plot
plotSet{1}.maxPlotID = length(linePlots);                 % last line plot
plotSet{1}.minPlotDGP_ID =  1;                            % first DGP ID
plotSet{1}.maxPlotDGP_ID =  height(samplerTable);         % last DPG ID
plotSet{1}.margH = [.07 .175];                            % Vertical margins
plotSet{1}.legendFontSize = 6.5;                          % Font size
plotSet{1}.legendPosition = [0.814, 0.892, 0.1, 0.04];    % Position
plotSet{1}.plotH = 550;                                   % Px height
plotSet{1}.plotW = 550*1.8;                               % Px width

% Set intervals
extrSet.firstID = 1;                % Only subsampled
extrSet.lastID = 8;
extrSet.name = "subs";

simSet.firstID = 9;                 % Only simulated
simSet.lastID = 16;
simSet.name = "sim";

jointSet.firstID = 1;               % Both subsampled and simulated
jointSet.lastID = 16;
jointSet.name = "joint";

% Add interval sets
plotSet{1}.intervalSets = {extrSet, simSet, jointSet};    %  Interval sets

