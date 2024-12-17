% ===========================================================
% File: exportFigures.m
% Description: This script exports the figures based on simulations for
%              comparing various confidence intervals for extreme
%              quantiles.
%
% ===========================================================
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Author: Vladislav Morozov
%
% Plot creation is 
%
% Created figures are saved in the 'results/figures/' folder.
% ===========================================================


%% Load in common tuning parameters

setPlottingParameters

%% Plot descriptions

% Implementation notes: 
% 1. Since different plots are required, plot type is supplied as a string,
%    and called with eval.
% 2. Plots are drawn in three steps: first the full line. Then a possibly
%    sparse collection of markers. Finally, a dummy plot with both the line
%    and the markers. The dummy plot is the one used to draw the legend.

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot 1: coverages %%%
%%%%%%%%%%%%%%%%%%%%%%%%%

% Limits for y axis
linePlots{1}.yLim = [0, 1];
% Label for y axis
linePlots{1}.yLabel = 'Coverage';
% Method for processing data to plot
linePlots{1}.computeData = ...
    @(resultsArray, methodID) ...
        smoothdata(...
        computeCoverageLengthNonNaN(resultsArray, methodID, 'coverage'), ...
        "gaussian", 10);
% Line plot call
linePlots{1}.plotCallLine = ['linePlot = plot(spacing, currentData', ...
    ', methodsCI{methodID}.plottingLineStyle', ...
    ', "LineWidth", plotLineThickness', ...
    ', "Color", methodsCI{methodID}.(colorField)', ...
    ', "DisplayName", methodsCI{methodID}.legendName);'];
% Marker plot call
linePlots{1}.plotCallMarker = ['markerPlot = plot(spacingMarker, currentDataMarker', ...
    ', "LineStyle", "none"' ...
    ', "Marker", methodsCI{methodID}.plottingMarker', ...
    ', "MarkerSize", methodsCI{methodID}.plottingMarkerSize', ...
    ', "LineWidth", plotLineThickness', ...
    ', "Color", methodsCI{methodID}.(colorField)', ...
    ', "DisplayName", methodsCI{methodID}.legendName);'];
% Legend plot call
linePlots{1}.plotCallLegend = ['legendPlot = plot(-0.001, 0', ...
    ', methodsCI{methodID}.plottingLineStyle', ...
    ', "Marker", methodsCI{methodID}.plottingMarker', ...
    ', "MarkerSize", methodsCI{methodID}.plottingMarkerSize', ...
    ', "LineWidth", plotLineThickness', ...
    ', "Color", methodsCI{methodID}.(colorField)', ...
    ', "DisplayName", methodsCI{methodID}.legendName);'];
% Type of the plot, used to to generate file name
linePlots{1}.plotType = 'coverage';
% ID of first method to plotted
linePlots{1}.firstMethodID = 1;
% Whether to add a horizontal line and at which level
linePlots{1}.yLine = 1-alphaCI;
% Whether to add legend
linePlots{1}.plotLegend = true;
% Legend position
linePlots{1}.legendPosition = [0.7355, 0.12, 0.1, 0.04];
% Exponent for nonlinearly transforming Y axis
linePlots{1}.spacingExponentY = 2.7;
% Whether special ticks for the Y axis should be used and which
linePlots{1}.yTicks = [0, 0.5:0.1:0.9, 1-alphaCI, 1];
% Suptitle for the overall plot
linePlots{1}.suptitle = '\textbf{Coverage}';


%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot 2: lengths %%%
%%%%%%%%%%%%%%%%%%%%%%%

% Limits for y axis
linePlots{2}.yLim = [];
% Label for y axis
linePlots{2}.yLabel = 'Interval length';
% Method for processing data to plot
linePlots{2}.computeData = ...
    @(resultsArray, methodID) ...
        smoothdata(...
        computeCoverageLengthNonNaN(resultsArray, methodID, 'length'), ...
        "gaussian", 10);
% Line plot call
linePlots{2}.plotCallLine = ['linePlot = semilogy(spacing, currentData', ...
    ', methodsCI{methodID}.plottingLineStyle', ...
    ', "LineWidth", plotLineThickness', ...
    ', "Color", methodsCI{methodID}.(colorField)', ...
    ', "DisplayName", methodsCI{methodID}.legendName);'];
% Marker plot call
linePlots{2}.plotCallMarker = ['markerPlot = semilogy(spacingMarker, currentDataMarker', ...
    ', "LineStyle", "none"' ...
    ', "Marker", methodsCI{methodID}.plottingMarker', ...
    ', "MarkerSize", methodsCI{methodID}.plottingMarkerSize', ...
    ', "LineWidth", plotLineThickness', ...
    ', "Color", methodsCI{methodID}.(colorField)', ...
    ', "DisplayName", methodsCI{methodID}.legendName);'];
% Legend plot call 
linePlots{2}.plotCallLegend = ['legendPlot = semilogy(-0.001, 0', ...
    ', methodsCI{methodID}.plottingLineStyle', ...
    ', "Marker", methodsCI{methodID}.plottingMarker', ...
    ', "MarkerSize", methodsCI{methodID}.plottingMarkerSize', ...
    ', "LineWidth", plotLineThickness', ...
    ', "Color", methodsCI{methodID}.(colorField)', ...
    ', "DisplayName", methodsCI{methodID}.legendName);'];
% Type of the plot, used to to generate file name
linePlots{2}.plotType = 'length';
% ID of first method to plotted
linePlots{2}.firstMethodID = 1;  
% Whether to add a horizontal line and at which level
linePlots{2}.yLine = [];
% Whether to add legend
linePlots{2}.plotLegend = true;
% Legend position
linePlots{2}.legendPosition = [0.7355, 0.12, 0.1, 0.04];
% Exponent for nonlinearly transforming Y axis
linePlots{2}.spacingExponentY = 1;
% Whether special ticks for the Y axis should be used and which
linePlots{2}.yTicks = [0.1, 1, 10, 100, 1000, 5000];
% Suptitle for the overall plot
linePlots{2}.suptitle = '\textbf{Length}';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot 3: relative MAE of adjusted estimator %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Limits for y axis
linePlots{3}.yLim = [0, 1.25];
% Label for y axis
linePlots{3}.yLabel = 'Relative MSE';
% Method for processing data to plot
linePlots{3}.computeData = ...
    @(resultsArray, methodID) ...
        smoothdata(nanmean(abs(resultsArray{methodID}.estError).^2)./...
            nanmean(abs(resultsArray{1}.estError).^2), ...
             "gaussian", 10);

% Line plot call
linePlots{3}.plotCallLine = ['linePlot = plot(spacing, currentData', ...
    ', methodsCI{methodID}.plottingLineStyle', ...
    ', "LineWidth", plotLineThickness', ...
    ', "Color", methodsCI{methodID}.(colorField)', ...
    ', "DisplayName", methodsCI{methodID}.legendName);'];
% Marker plot call
linePlots{3}.plotCallMarker = ['markerPlot = plot(spacingMarker, currentDataMarker', ...
    ', "LineStyle", "none"' ...
    ', "Marker", methodsCI{methodID}.plottingMarker', ...
    ', "MarkerSize", methodsCI{methodID}.plottingMarkerSize', ...
    ', "LineWidth", plotLineThickness', ...
    ', "Color", methodsCI{methodID}.(colorField)', ...
    ', "DisplayName", methodsCI{methodID}.legendName);'];
% Legend plot call
linePlots{3}.plotCallLegend = ['legendPlot = plot(-0.001, 0', ...
    ', methodsCI{methodID}.plottingLineStyle', ...
    ', "Marker", methodsCI{methodID}.plottingMarker', ...
    ', "MarkerSize", methodsCI{methodID}.plottingMarkerSize', ...
    ', "LineWidth", plotLineThickness', ...
    ', "Color", methodsCI{methodID}.(colorField)', ...
    ', "DisplayName", methodsCI{methodID}.legendName);'];
% Type of the plot, used to to generate file name
linePlots{3}.plotType = 'estError';
% ID of first method to plotted
linePlots{3}.firstMethodID = 2;  
% Whether to add a horizontal line and at which level
linePlots{3}.yLine = 1; 
% Whether to add legend
linePlots{3}.plotLegend = true;
% Legend position
linePlots{3}.legendPosition = [0.7355, 0.108, 0.1, 0.04];
% Exponent for nonlinearly transforming Y axis
linePlots{3}.spacingExponentY = 1;
% Whether special ticks for the Y axis should be used and which
linePlots{3}.yTicks = [0:0.5:1, 1.25];
% Suptitle for the overall plot
linePlots{3}.suptitle = '\textbf{Efficiency of Corrected Estimators Relative to Sample Quantile}';







% TEMP
Ns = [200, 2000, 10000];
 
% --- Plot generation ---

switch colorMode
    case 'color'
        colorField = 'plottingColor';
    case 'BW'
        colorField = 'plottingColorBW';
end
% Extract number of sample sizes used. 
% N indexes rows; T indexes columns
numN = length(Ns);
numT = length(Ts);

% Zip together distribution samplers in the format (thetaSampler, uSampler)
samplerTable = combinations(thetaDistrsArray, uDistrsArray);

% Each combination of distributions receives their own plot

for plotID = 1 :length(linePlots)
    for plotDGP_ID = 10 : height(samplerTable)

        % Create figure
        if plotQuietly ~= 1
            figure('Renderer', 'painters', ...
                'Position', [50 50 plotWallCoverages plotHallCoverages]);
        else
            figure('visible','off',...
                'Renderer', 'painters',...
                'Position', [50 50 plotWallCoverages plotHallCoverages]);
        end
    
 

        % Use tight_subplots
        [has, ~] = tight_subplot(3, 3,[.07 .036],[.07 .105],[.05 .04]); % tight_subplot(numN, numT,[.07 .036],[.07 .105],[.05 .04]);

        % Loop over (N, T): each combination receives a subplot
        for NID = 1:numT
            for TID = 1:numN

                                % TEMP
                Ns = [200, 2000, 10000];
                numN = 3;
                numT = 3;
                numSamples = 3333;

                % Create subplot
                plotNum = (TID-1)*numT+NID;
                axes(has(plotNum))  



                % Extract current sample sizes
                N = Ns(TID);
                T = Ts(NID);

                % Extract current samplers for theta and u
                thetaSampler = samplerTable{plotDGP_ID, 1}{1};
                uSampler = samplerTable{plotDGP_ID, 2}{1};

                % Load in corresponding simulation result file
                fileName = makeOutputFileName(thetaSampler, uSampler, ...
                    N, T, ...
                    numSamples, simContext);
                load(fileName)
                
                % Patch colors 
                setConfidenceIntervalMethods_CompareIntervals

                % TEMP: patch parameters
                setPlottingParameters

                % Set spacing based on the quantiles in the loaded file
                spacing = 1:length(targetQuantilesDGP);
                spacing= (spacing).^spacingExponent;
                spacingMarker = spacing(1:markerStep:end);
             

                % Loop through confidence interval methods
                for methodID = linePlots{plotID}.firstMethodID:numMethods
                    % Compute data to plot

                    currentData = linePlots{plotID}.computeData(resultsArray, methodID);
                    
                    % Change spacing
                    currentData = currentData .^ linePlots{plotID}.spacingExponentY;
                    currentDataMarker = currentData(1:markerStep:end);
                    % Add line to plot
                    eval(linePlots{plotID}.plotCallLine)
                    linePlot.HandleVisibility = 'off';
                    hold on
                    % Add markers to the plot
                    eval(linePlots{plotID}.plotCallMarker)
                    markerPlot.HandleVisibility = 'off';
                    % Add dummy line with both markers and line for legend
                    eval(linePlots{plotID}.plotCallLegend)
                    % Ensure that plotting is done on the same subplot
                    
                end

                % x-axis: respace ticks according to spacing
                xticks([spacing(1:spacingStep:end), spacing(end)])
                % Erase x-tick and y-tick labels by default
                xticklabels([])


                defaultYTicks = gca().YTick;
                yticklabels([])
                
                % Set x-axis limits according to spacing
                xlim([min(spacing), max(spacing)]);
                % Add x-tick labels and axis label only on the bottom plots
                if TID == numN
                    xlabel('Quantile')
                    xticklabels([targetQuantilesDGP(1:spacingStep:end), targetQuantilesDGP(end)])
                end

                % y-axis: change y limits according to the plot
                if ~isempty(linePlots{plotID}.yLim)
                    ylim(linePlots{plotID}.yLim.^ linePlots{plotID}.spacingExponentY);
                end
                
                % y-axis: add y-line if one is requested
                if ~isempty(linePlots{plotID}.yLine)
                    hV = yline(linePlots{plotID}.yLine.^ linePlots{plotID}.spacingExponentY);
                    hV.HandleVisibility='off';
                end

                if ~isempty(linePlots{plotID}.yTicks)
                    yticks(linePlots{plotID}.yTicks.^linePlots{plotID}.spacingExponentY)
                end
                % y label and ticks only on the left plots
                if NID == 1
                    ylabel(linePlots{plotID}.yLabel)

                    %
                    if isempty(linePlots{plotID}.yTicks)
                        yticklabels(defaultYTicks)

                    else
                        
                        yticklabels( linePlots{plotID}.yTicks)
                    end

                end
 

                % Add a title to the subplot and left-justify it
                ttl = title("N="+num2str(Ns(TID))+", T="+num2str(Ts(NID)));
                ttl.Units = 'Normalize';
                ttl.Position(1) = 0;
                ttl.HorizontalAlignment = 'left';

                % Display legend on last plot if legend is required
                if plotNum == numN*numT && linePlots{plotID}.plotLegend 
                    lgd = legend('Position', linePlots{plotID}.legendPosition);
                    fontsize(lgd, 6.5,'points')
                end

            end
        end
        % Add suptitle 
        sgt = sgtitle(linePlots{plotID}.suptitle);
               
        % Create figure saving name
        figureSavingName =   "results/figures/" + simContext + "_" + ...
            linePlots{plotID}.plotType + "_" + ...
            thetaSampler.distrMachineName + "_" + ...
            uSampler.distrMachineName;



        % Export as PNG
        set(gcf, 'PaperPosition', [0 0 plotRatioAllCoverages*8 8])
        print(gcf, figureSavingName, '-dpng', '-r300' );

        % Prepare export settings for PDF
        set(gcf,'Units','Inches');
        pos = get(gcf,'Position');
        set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
        % Export as PDF
        print(gcf, figureSavingName, '-dpdf');


        % TEMP
        numN = 3;
                numT = 3;

                    


         plotDGP_ID
    end

end
 


















%% OLD PLOTS GO BELOW HERE


%% Experimental single plot
        % Set spacing based on the quantiles in the loaded file
        spacing = 1:length(targetQuantilesDGP);
        spacing= (spacing).^spacingExponent;

ySpacing = 0:10;
ySpacing = ySpacing.^spacingExponent;
% Create plots
% Create figure
if plotQuietly ~= 1
    p = figure('Renderer', 'painters', 'Position', [50 50 plotW plotHall]);
else
    p = figure('visible','off', 'Renderer', 'painters', 'Position', [50 50 plotW plotHall]);% Do not plot
end

% Loop through methods
for methodID = 1:numMethods
    %  Add plot
    

    plot(spacing, mean(resultsArray{methodID}.ciCovers), ...
        methodsCI{methodID}.plottingLineStyle,...
        'LineWidth', plotLineThickness, ...
        'Color', methodsCI{methodID}.plottingColor, ...
        'DisplayName', methodsCI{methodID}.legendName)

    hold on
end

% Correct x axis
xticks([spacing(1:spacingStep:end), spacing(end)])  
xticklabels([targetQuantilesDGP(1:spacingStep:end), targetQuantilesDGP(end)])
xlim([min(spacing), max(spacing)]);

 

% Display legend
legend()









%% V3 plots

% Subsampled with r=0, q=qSubsampling
plot(spacing, mean(containsSubsampledMax,1),'-o','LineWidth', plotLineThickness, 'Color', colorSSmixed)
% Simulated using PWM estimator
plot(spacing, mean(containsPWMMixed,1),'-pentagram', 'LineWidth', plotLineThickness, 'Color', colorSimMixedPWM)
plot(spacing, mean(containsPWMMax,1),'-*', 'LineWidth', plotLineThickness, 'Color', colorSimMaxPWM)
% Simulated with Hill estimator, only for heavy-tailed distribution
if j==1
     plot(spacing, mean(containsHillMixed,1),'-square', 'LineWidth', plotLineThickness, 'Color', colorSimMixedHill)
    plot(spacing, mean(containsHillMax,1),'-diamond', 'LineWidth', plotLineThickness, 'Color', colorSimMaxHill)
   end
% IVT
 kIVT = floor((1-quantilesConsidered)*N); % Solve for k
sIIVT = floor(sqrt(kIVT)); % Take square root
IVTpossible = sIIVT>0;
interNormal = mean(containsIntermediateNormal,1);
interSS = mean(containsIntermediateSS,1);
plot(spacing(IVTpossible), interNormal(IVTpossible),'--^','LineWidth', plotLineThickness, 'Color', colorInterNormal)
plot(spacing(IVTpossible), interSS(IVTpossible),'--v','LineWidth', plotLineThickness, 'Color', colorInterSS)
% Extrapolation
extrValid = logical(nonEmptyExtrapolation(end, :)); % quantiles for which construction of the interval is possible
extrCoverage = mean(containsExtrapolation,1);
plot(spacing(extrValid),extrCoverage(extrValid) ,'--<','LineWidth', plotLineThickness, 'Color', colorExtrapolation)
% Central
plot(spacing, mean(containsNaive,1), '-.+','LineWidth', plotLineThickness, 'Color', colorRaw)
plot(spacing, mean(containsDebiased,1),'-..','LineWidth', plotLineThickness, 'Color', colorJW)
%plot(spacing, mean(containsTrue,1),'LineWidth', plotLineThickness)
yline(1-alphaCI) ;

if N==2000
    if j==1 % Account for using the Hill estimator
        legend('Extreme: mixed, subsampling (1a)', 'Extreme: max, subsampling (1b)',  ...
            'Extreme: mixed, PWM (1c)','Extreme: max, PWM (1d)',...
            'Extreme: mixed, Hill (1e)', 'Extreme: max, Hill (1f)',...
            'Intermediate: normal (2a)', 'Intermediate: Subsampling (2b)',...
            'Intermediate: extrapolation (2c)',...
            'Central: raw data (3a)', 'Central: analytical correction (3b)',...
            'Location', 'southwest')%, 'Central: true')
    else % No Hill estimator
      legend('Extreme: mixed, subsampling (1a)', 'Extreme: max, subsampling (1b)',  ...
            'Extreme: mixed, PWM (1c)','Extreme: max, PWM (1d)',... 
            'Intermediate: normal (2a)', 'Intermediate: Subsampling (2b)',...
            'Intermediate: extrapolation (2c)',...
            'Central: raw data (3a)', 'Central: analytical correction (3b)',...
            'Location', 'southwest')%, 'Central: true')
    end
end

   

xlabel('Quantile')
ylabel('Coverage')

if t<3 % Add an alternative naming scheme for noiseless data
    title(['Coverage, 95% CI for quantiles, N=', num2str(N), ',T=', num2str(T), ', F=', ...
        thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
        num2str(thetaDistributionParam{thetaDistrChoice}), ', u_{it}~', uName{uDistrChoice},...
        ', ', uParamName{uDistrChoice},'=', num2str(uDistributionParam{uDistrChoice}) ])
else
    title(['Coverage, 95% CI for quantiles, N=', num2str(N), ',T=', num2str(T), ', F=', ...
        thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
        num2str(thetaDistributionParam{thetaDistrChoice}), ', noiseless data'])
end

 
figureSavingName = ['Figures/allCoverage',num2str(nSamples),'N', num2str(N), 'T', num2str(T), 'F', thetaNameSave{thetaDistrChoice},...
    thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
    uParamNameSave{uDistrChoice}, num2str(uDistributionParam{uDistrChoice}) ];

saveas(p,figureSavingName,'epsc');

%% Coverages (selected)

% Create figure
if plotQuietly ~= 1
    % Plot
    p = figure('Renderer', 'painters', 'Position', [50 50 plotWsel plotH]);
else
    p = figure('visible','off', 'Renderer', 'painters', 'Position', [50 50 plotWsel plotH]);% Do not plot
end


% Start plot, create labels

plot(spacing, mean(containsSubsampledMixed,1),'-x','LineWidth', plotLineThickness, 'Color', colorSSmax)
xticks([spacing(1:spacingStep:end), spacing(end)])  
xticklabels([quantilesConsidered(1:spacingStep:end), quantilesConsidered(end)])
xlim([min(spacing), max(spacing)]);
hold on

% Subsampled with r=l, q=qSubsampling
plot(spacing, mean(containsSubsampledMax,1),'-o','LineWidth', plotLineThickness, 'Color', colorSSmixed) % very magenta
% Add universally consistent simulated line for larger sample sizes
if N>=1000
    plot(spacing, mean(containsPWMMixed,1),'-pentagram', 'LineWidth', plotLineThickness, 'Color', colorSimMixedPWM)

end
% IVT
  
interNormal = mean(containsIntermediateNormal,1);
interSS = mean(containsIntermediateSS,1);
plot(spacing(IVTpossible), interNormal(IVTpossible),'--^','LineWidth', plotLineThickness, 'Color', colorInterNormal)
plot(spacing(IVTpossible), interSS(IVTpossible),'--v','LineWidth', plotLineThickness, 'Color', colorInterSS)
% Extrapolation
extrValid = logical(nonEmptyExtrapolation(end, :)); % quantiles for which construction of the interval is possible
extrCoverage = mean(containsExtrapolation,1);
plot(spacing(extrValid),extrCoverage(extrValid) ,'--<','LineWidth', plotLineThickness, 'Color', colorExtrapolation)
% Central
plot(spacing, mean(containsNaive,1), '-.+','LineWidth', plotLineThickness, 'Color', colorRaw)
plot(spacing, mean(containsDebiased,1),'-..','LineWidth', plotLineThickness, 'Color', colorJW)
%plot(spacing, mean(containsTrue,1),'LineWidth', plotLineThickness)
yline(1-alphaCI) ;

if N==2000
    if N>=1000
        legend('Extreme: mixed, subsampling (1a)', 'Extreme: max, subsampling (1b)', ...
            'Extreme: mixed, PWM (1c)',...
            'Intermediate: normal (2a)', 'Intermediate: Subsampling (2b)',...
            'Intermediate: extrapolation (2c)',...
            'Central: raw data (3a)', 'Central: analytical correction (3b)',...
            'Location', 'southwest')%, 'Central: true')
    else
        legend('Extreme: max, subsampling',  'Extreme: mixed, subsampling',  ...
            'Intermediate: normal', 'Intermediate: Subsampling','Intermediate: extrapolation',...
            'Central: raw data', 'Central: analytical correction',...
            'Location', 'southwest')%, 'Central: true')
    end
end

xlabel('Quantile')
ylabel('Coverage')
if t<3 % Add an alternative naming scheme for noiseless data
    title(['Coverage, 95% CI for quantiles, N=', num2str(N), ',T=', num2str(T), ', F=', ...
        thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
        num2str(thetaDistributionParam{thetaDistrChoice}), ', u_{it}~', uName{uDistrChoice},...
        ', ', uParamName{uDistrChoice},'=', num2str(uDistributionParam{uDistrChoice}) ])
else
    title(['Coverage, 95% CI for quantiles, N=', num2str(N), ',T=', num2str(T), ', F=', ...
        thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
        num2str(thetaDistributionParam{thetaDistrChoice}), ', noiseless data'])
end
 
figureSavingName = ['Figures/selectedCoverage',num2str(nSamples),'N', num2str(N), 'T', num2str(T), 'F', thetaNameSave{thetaDistrChoice},...
    thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
    uParamNameSave{uDistrChoice}, num2str(uDistributionParam{uDistrChoice}) ];

saveas(p,figureSavingName,'epsc');
%% Interval length (all)




% Create plot
if plotQuietly ~= 1
    % Plot
    p = figure('Renderer', 'painters', 'Position', [50 50 plotW plotHall]);
else
    p = figure('visible','off', 'Renderer', 'painters', 'Position', [50 50 plotW plotHall]);% Do not plot
end


% Start plot, create labels
plot(spacing, mean(lengthSubsampledMixed,1),'-x','LineWidth', plotLineThickness, 'Color', colorSSmax)
xticks([spacing(1:spacingStep:end), spacing(end)])  
xticklabels([quantilesConsidered(1:spacingStep:end), quantilesConsidered(end)])
xlim([min(spacing), max(spacing)]);
hold on

% Subsampled with r=0, q=qSubsampling
plot(spacing, mean(lengthSubsampledMax,1),'-o','LineWidth', plotLineThickness, 'Color', colorSSmixed) % very magenta
% Simulated using PWM estimator
plot(spacing, mean(lengthPWMMixed,1),'-pentagram', 'LineWidth', plotLineThickness, 'Color', colorSimMixedPWM)
plot(spacing, mean(lengthPWMMax,1),'-*', 'LineWidth', plotLineThickness, 'Color', colorSimMixedPWM)
% Simulated with Hill estimator, only for heavy-tailed distribution
if j==1
    plot(spacing, mean(lengthHillMixed,1),'-square', 'LineWidth', plotLineThickness, 'Color', colorSimMixedHill)
    plot(spacing, mean(lengthHillMax,1),'-diamond', 'LineWidth', plotLineThickness, 'Color', colorSimMixedHill)

end
% IVT
plot(spacing, mean(lengthIntermediateNormal,1),'--^','LineWidth', plotLineThickness, 'Color', colorInterNormal)
plot(spacing, mean(lengthIntermediateSS,1),'--v','LineWidth', plotLineThickness, 'Color', colorInterSS)
% Extrapolation
extrValid = logical(nonEmptyExtrapolation(end, :)); % quantiles for which construction of the interval is possible
extrLength = mean(lengthExtrapolation,1);
plot(spacing(extrValid),extrLength(extrValid) ,'--<','LineWidth', plotLineThickness, 'Color', colorExtrapolation)
% Central
plot(spacing, mean(lengthNaive,1), '-.+','LineWidth', plotLineThickness, 'Color', colorRaw)
plot(spacing, mean(lengthDebiased,1),'-..','LineWidth', plotLineThickness, 'Color', colorJW) 

ylim([min(extrLength(extrValid)),max( mean(lengthIntermediateSS,1) )])

if N==2000
    if j==1 % Account for using the Hill estimator
        legend('Extreme: mixed, subsampling (1a)', 'Extreme: max, subsampling (1b)',  ...
            'Extreme: mixed, PWM (1c)','Extreme: max, PWM (1d)',...
            'Extreme: mixed, Hill (1e)', 'Extreme: max, Hill (1f)',...
            'Intermediate: normal (2a)', 'Intermediate: Subsampling (2b)',...
            'Intermediate: extrapolation (2c)',...
            'Central: raw data (3a)', 'Central: analytical correction (3b)',...
            'Location', 'southwest')%, 'Central: true')
    else % No Hill estimator
      legend('Extreme: mixed, subsampling (1a)', 'Extreme: max, subsampling (1b)',  ...
            'Extreme: mixed, PWM (1c)','Extreme: max, PWM (1d)',... 
            'Intermediate: normal (2a)', 'Intermediate: Subsampling (2b)',...
            'Intermediate: extrapolation (2c)',...
            'Central: raw data (3a)', 'Central: analytical correction (3b)',...
            'Location', 'southwest')%, 'Central: true')
    end
end


xlabel('Quantile')
ylabel('Length')
if t<3 % Add an alternative naming scheme for noiseless data
    title(['Length, 95% CI for quantiles, N=', num2str(N), ',T=', num2str(T), ', F=', ...
        thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
        num2str(thetaDistributionParam{thetaDistrChoice}), ', u_{it}~', uName{uDistrChoice},...
        ', ', uParamName{uDistrChoice},'=', num2str(uDistributionParam{uDistrChoice}) ])
else
    title(['Length, 95% CI for quantiles, N=', num2str(N), ',T=', num2str(T), ', F=', ...
        thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
        num2str(thetaDistributionParam{thetaDistrChoice}), ', noiseless data'])
end

figureSavingName = ['Figures/allLength',num2str(nSamples),'N', num2str(N), 'T', num2str(T), 'F', thetaNameSave{thetaDistrChoice},...
    thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
    uParamNameSave{uDistrChoice}, num2str(uDistributionParam{uDistrChoice}) ];

saveas(p,figureSavingName,'epsc');

%% Interval length (selected)




% Create plot
if plotQuietly ~= 1
    % Plot
    p = figure('Renderer', 'painters', 'Position', [50 50 plotWsel plotH]);
else
    p = figure('visible','off', 'Renderer', 'painters', 'Position', [50 50 plotWsel plotH]);% Do not plot
end

% Start plot, create labels
plot(spacing, mean(lengthSubsampledMixed,1),'-x','LineWidth', plotLineThickness, 'Color', colorSSmax)
xticks([spacing(1:spacingStep:end), spacing(end)])  
xticklabels([quantilesConsidered(1:spacingStep:end), quantilesConsidered(end)])
xlim([min(spacing), max(spacing)]);
hold on

% Subsampled with r=0, q=qSubsampling
plot(spacing, mean(lengthSubsampledMax,1),'-o','LineWidth', plotLineThickness, 'Color', colorSSmixed) % very magenta
% Simulated using PWM estimator
if N==2000
    plot(spacing, mean(lengthPWMMixed,1),'-pentagram', 'LineWidth', plotLineThickness, 'Color', colorSimMixedPWM)
end
 
% IVT
interNormal = mean(lengthIntermediateNormal,1);
interSS = mean(lengthIntermediateSS,1);
plot(spacing(IVTpossible), interNormal(IVTpossible),'--^','LineWidth', plotLineThickness, 'Color', colorInterNormal)
plot(spacing(IVTpossible), interSS(IVTpossible),'--v','LineWidth', plotLineThickness, 'Color', colorInterSS)
% Extrapolation
extrValid = logical(nonEmptyExtrapolation(end, :)); % quantiles for which construction of the interval is possible
extrLength = mean(lengthExtrapolation,1);
plot(spacing(extrValid),extrLength(extrValid) ,'--<','LineWidth', plotLineThickness, 'Color', colorExtrapolation)
% Central
plot(spacing, mean(lengthNaive,1), '-.+','LineWidth', plotLineThickness, 'Color', colorRaw)
plot(spacing, mean(lengthDebiased,1),'-..','LineWidth', plotLineThickness, 'Color', colorJW) 

ylim([min(extrLength(extrValid)),max( mean(lengthIntermediateSS,1) )])

if N==2000
           legend('Extreme: mixed, subsampling (1a)', 'Extreme: max, subsampling (1b)',  ...
            'Extreme: mixed, PWM (1c)',...
            'Intermediate: normal (2a)', 'Intermediate: Subsampling (2b)',...
            'Intermediate: extrapolation (2c)',...
            'Central: raw data (3a)', 'Central: analytical correction (3b)',...
            'Location', 'southwest')%, 'Central: true')
end
   

xlabel('Quantile')
ylabel('Length')
if t<3 % Add an alternative naming scheme for noiseless data
    title(['Length, 95% CI for quantiles, N=', num2str(N), ',T=', num2str(T), ', F=', ...
        thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
        num2str(thetaDistributionParam{thetaDistrChoice}), ', u_{it}~', uName{uDistrChoice},...
        ', ', uParamName{uDistrChoice},'=', num2str(uDistributionParam{uDistrChoice}) ])
else
    title(['Length, 95% CI for quantiles, N=', num2str(N), ',T=', num2str(T), ', F=', ...
        thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
        num2str(thetaDistributionParam{thetaDistrChoice}), ', noiseless data'])
end

figureSavingName = ['Figures/selectedLength',num2str(nSamples),'N', num2str(N), 'T', num2str(T), 'F', thetaNameSave{thetaDistrChoice},...
    thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
    uParamNameSave{uDistrChoice}, num2str(uDistributionParam{uDistrChoice}) ];

saveas(p,figureSavingName,'epsc');
 
 

%% MAE of corrected estimators

% Use raw sample quantiles

refV = mean(abs(errorSimple));
if plotQuietly ~= 1
    % Plot
    p = figure('Renderer', 'painters', 'Position', [50 50 plotW plotHMae]);
else
    p = figure('visible','off', 'Renderer', 'painters', 'Position', [50 50 800 350]);% Do not plot
end

% First plot: zoomed in
subplot(2, 1, 1)
semilogy(spacing, mean(abs(errorCorrectedMixed)./refV, 1), '-x','LineWidth', plotLineThickness, 'Color', colorSSmax)
hold on 
xlim([min(spacing), max(spacing)]);
xticks([spacing(1:spacingStep:end), spacing(end)])
xticklabels([quantilesConsidered(1:spacingStep:end), quantilesConsidered(end)])
plot(spacing, mean(abs(errorCorrectedMax)./refV, 1) ,'-o','LineWidth', plotLineThickness, 'Color', colorSSmixed)
plot(spacing, mean(abs(errorCorrectedPWMMixed)./refV, 1),'-pentagram','LineWidth', plotLineThickness, 'Color', colorSimMixedPWM)
if j==1 % For heavy-tailed distribution pot
    plot(spacing, mean(abs(errorCorrectedHillmixed)./refV, 1),'-s','LineWidth', plotLineThickness, 'Color', colorSimMixedHill)
end
plot(spacing, mean(abs(errorExtrapolation)./refV, 1),'--<','LineWidth', plotLineThickness, 'Color', colorExtrapolation)
plot(spacing, mean(abs(errorCorrectedJW)./refV, 1),'-..', 'LineWidth', plotLineThickness,'Color', colorJW);

ylim([0.5, 2])

yline(1);
xlabel('Quantile')
ylabel('Relative MAE')

% Second plot: zoomed out
subplot(2, 1, 2)

semilogy(spacing, mean(abs(errorCorrectedMixed)./refV, 1), '-x','LineWidth', plotLineThickness, 'Color', colorSSmax)
hold on 
xlim([min(spacing), max(spacing)]);
xticks([spacing(1:spacingStep:end), spacing(end)])
xticklabels([quantilesConsidered(1:spacingStep:end), quantilesConsidered(end)])
semilogy(spacing, mean(abs(errorCorrectedMax)./refV, 1) ,'-o','LineWidth', plotLineThickness, 'Color', colorSSmixed)
plot(spacing, mean(abs(errorCorrectedPWMMixed)./refV, 1),'-pentagram','LineWidth', plotLineThickness, 'Color', colorSimMixedPWM)
if j==1 % For heavy-tailed distribution pot
    plot(spacing, mean(abs(errorCorrectedHillmixed)./refV, 1),'-s','LineWidth', plotLineThickness, 'Color', colorSimMixedHill)
end
plot(spacing, mean(abs(errorExtrapolation)./refV, 1),'--<','LineWidth', plotLineThickness, 'Color', colorExtrapolation)
plot(spacing, mean(abs(errorCorrectedJW)./refV, 1),'-..', 'LineWidth', plotLineThickness,'Color', colorJW);

xlabel('Quantile')
ylabel('Relative MAE')
yline(1);

if N==2000
    if j==1
        legend(  'Extreme: mixed, subsampling (1a)', 'Extreme: max, subsampling (1b)',...
            'Extreme: mixed, PWM (1c)', 'Extreme: mixed, Hill (1e)',...
            'Intermediate: extrapolation (2c)',...
            'Central: analytical correction (3b)',...
            'Location', 'southwest')
        
    else
        legend(  'Extreme: mixed, subsampling (1a)', 'Extreme: max, subsampling (1b)',...
            'Extreme: mixed, PWM (1c)',  ...
            'Intermediate: extrapolation (2c)',...
            'Central: analytical correction (3b)',...
            'Location', 'southwest')
        
    end
end


   
xlabel('Quantile')
 
    if t==3
        suptitle({'MAE of corrected estimators, relative to raw sample quantile', ...
            ['N=', num2str(N), ',T=', num2str(T), ', F=', ...
            thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
            num2str(thetaDistributionParam{thetaDistrChoice}), ', noiseless data']})
    else
        suptitle({'MAE of corrected estimators, relative to raw sample quantile', ...
            ['N=', num2str(N), ',T=', num2str(T), ', F=', ...
            thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
            num2str(thetaDistributionParam{thetaDistrChoice}), ', u_{it}~', uName{uDistrChoice},...
            ', ', uParamName{uDistrChoice},'=', num2str(uDistributionParam{uDistrChoice})]})
    end
 
 
figureSavingName = ['Figures/mae',num2str(nSamples),'N', num2str(N), 'T', num2str(T), 'F', thetaNameSave{thetaDistrChoice},...
    thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
    uParamNameSave{uDistrChoice}, num2str(uDistributionParam{uDistrChoice}) ];

saveas(p,figureSavingName,'epsc');
  