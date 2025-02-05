% ===========================================================
% File: choosePlotSetsMethodsComparison.m
% Description: This script defines parameters for groups of plots,
%              depending on their destination.
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
% ===========================================================

%% Plots for the Online Appendix

plotSet{1}.destination = "OA";
plotSet{1}.colorField = 'plottingColor';
plotSet{1}.NsPlot = Ns;
plotSet{1}.TsPlot = Ts;
plotSet{1}.maxPlotID = length(linePlots);
plotSet{1}.minPlotDGP_ID =  1;
plotSet{1}.maxPlotDGP_ID =  height(samplerTable);
plotSet{1}.margH = [.07 .145];
plotSet{1}.legendFontSize = 6.5;
plotSet{1}.legendPosition = [0.814, 0.912, 0.1, 0.04];
plotSet{1}.plotH = 550;
plotSet{1}.plotW = 1.8*plotSet{1}.plotH; 

%% Plots for the main text

plotSet{2}.destination = "main";
plotSet{2}.colorField = 'plottingColorBW';
plotSet{2}.NsPlot = [Ns(1), Ns(2)];
plotSet{2}.TsPlot = [Ts(1), Ts(end)];
plotSet{2}.maxPlotID = 2;
plotSet{2}.minPlotDGP_ID =  7;
plotSet{2}.maxPlotDGP_ID =  8;
plotSet{2}.margH = [.07 .105];
plotSet{2}.legendFontSize = 9;
plotSet{2}.legendPosition = [0.7875, 0.1355, 0.1, 0.04];
plotSet{2}.plotH = 550;
plotSet{2}.plotW = 1.8*plotSet{1}.plotH; 