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
%
% Implementation notes: 
% 1. Since different plots are required, plot type is supplied as a string,
%    and called with eval.
% 2. Plots are drawn in three steps: first the full line. Then a possibly
%    sparse collection of markers. Finally, a dummy plot with both the line
%    and the markers. The dummy plot is the one used to draw the legend.

% ===========================================================


%% Load in common tuning parameters

setPlottingParameters
chooseLinePlotsMethodsComparison
 
 
%% --- Plot generation ---

% Set color mode
switch colorMode
    case 'color'
        colorField = 'plottingColor';
    case 'BW'
        colorField = 'plottingColorBW';
end

% Set (N, T) vectors to use in plotting
switch destination
    case 'main'
        NsPlot = [Ns(1), Ns(2)];
        TsPlot = [Ts(1), Ts(end)];
    case 'OA'
        NsPlot = Ns;
        TsPlot = Ts;
end


% Extract number of sample sizes used. 
% N indexes rows; T indexes columns
numN = length(NsPlot);
numT = length(TsPlot);

% Zip together distribution samplers in the format (thetaSampler, uSampler)
samplerTable = combinations(thetaDistrsArray, uDistrsArray);

% Each combination of distributions receives their own plot

for plotID = 1 : 1 % length(linePlots)
    for plotDGP_ID = 1 : 1 %  height(samplerTable)

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
        [has, ~] = tight_subplot(numN, numT,[.07 .036],[.07 .145],[.05 .04]); % tight_subplot(numN, numT,[.07 .036],[.07 .105],[.05 .04]);

        % Loop over (N, T): each combination receives a subplot
        for NID = 1:numT
            for TID = 1:numN
                % Create subplot
                plotNum = (TID-1)*numT+NID;
                axes(has(plotNum))  

                % Extract current sample sizes
                N = NsPlot(TID);
                T = TsPlot(NID);

                % Extract current samplers for theta and u
                thetaSampler = samplerTable{plotDGP_ID, 1}{1};
                uSampler = samplerTable{plotDGP_ID, 2}{1};

                % Load in corresponding simulation result file
                fileName = makeOutputFileName(thetaSampler, uSampler, ...
                    N, T, ...
                    numSamples, simContext);
                load(fileName)
                
                % ------------- Patches 
                % Patch colors if these have been changed after creation
                setConfidenceIntervalMethods_CompareIntervals 

                % Patch incorrect name on Gbeta
                if uSampler.distrLegendName == "G_{\kappa}"
                    uSampler.distrLegendName = "G_{\beta}";
                end

                
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
                ttl = title("N="+num2str(NsPlot(TID))+", T="+num2str(TsPlot(NID)));
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
        sgt = sgtitle({linePlots{plotID}.suptitle, ...
            "$F = " + thetaSampler.distrLegendName + "$, " + ...
            "$G = " + uSampler.distrLegendName + "$", ...
            }, ...
            'interpreter','latex');  

        % Create figure saving name
        figureSavingName =   "results/figures/" + ...
            colorMode + "_" + ...
            simContext + "_" + ...
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

        disp(plotDGP_ID)
    end
end