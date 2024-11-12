%% Plotting parameters

% Set thickness of the lines to use
plotLineThickness= 1.1;

% Adjust the exponential spacing between quantile
spacingExponent= 1.2;  

% Dimensions of the plots to use
plotW = 800;
plotWsel = 1000;
plotHall = 400;
plotH = 270;
plotHMae = 700;

% Set spacing based on quantiles associated to the distribution 
spacingStep = 10;

markerStep = 2;

plotHallCoverages = 500;
plotRatioAllCoverages = 1.8;
plotWallCoverages= plotRatioAllCoverages*plotHallCoverages;

% Set text interpreters to latex
set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultTextInterpreter', 'latex'); 
   
