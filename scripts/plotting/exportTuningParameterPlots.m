setPlottingParameters

%% Plot descriptions
% Implementation note: since different plots are required, plot type is
% supplied as a string, and called with eval

% Plot 1: coverages 

linePlots{1}.yLim = [0, 1];

linePlots{1}.computeData = ...
    @(resultsArray, methodID) smoothdata(mean(resultsArray{methodID}.ciCovers), "gaussian", 10);

linePlots{1}.plotCallLine = ['linePlot = plot(spacing, currentData', ...
    ', methodsCI{methodID}.plottingLineStyle', ...
    ', "LineWidth", plotLineThickness', ...
    ', "Color", methodsCI{methodID}.plottingColor', ...
    ', "DisplayName", methodsCI{methodID}.legendName)'];

linePlots{1}.plotCallMarker = ['markerPlot = plot(spacingMarker, currentDataMarker', ...
    ', "LineStyle", "none"' ...
    ', "Marker", methodsCI{methodID}.plottingMarker', ...
    ', "MarkerSize", methodsCI{methodID}.plottingMarkerSize', ...
    ', "LineWidth", plotLineThickness', ...
    ', "Color", methodsCI{methodID}.plottingColor', ...
    ', "DisplayName", methodsCI{methodID}.legendName);'];

linePlots{1}.plotCallLegend = ['legendPlot = plot(-0.001, 0', ...
    ', methodsCI{methodID}.plottingLineStyle', ...
    ', "Marker", methodsCI{methodID}.plottingMarker', ...
    ', "MarkerSize", methodsCI{methodID}.plottingMarkerSize', ...
    ', "LineWidth", plotLineThickness', ...
    ', "Color", methodsCI{methodID}.plottingColor', ...
    ', "DisplayName", methodsCI{methodID}.legendName);'];

linePlots{1}.plotType = 'coverage';
linePlots{1}.firstMethodID = 1; % first method to plot
linePlots{1}.yLabel = 'Coverage';
linePlots{1}.yLine = 1-alphaCI;
linePlots{1}.legendPosition = [0.844, 0.085, 0.1, 0.07];
linePlots{1}.spacingExponentY = 2.7;
linePlots{1}.yTicks = [0, 0.4:0.1:0.9, 1-alphaCI, 1];

% Plot 2: lenghts
linePlots{2}.yLim = [];

linePlots{2}.computeData = ...
    @(resultsArray, methodID) mean(resultsArray{methodID}.ciLength);

linePlots{2}.plotCall = ['semilogy(spacing, smooth(currentData)', ...
                         ', methodsCI{methodID}.plottingLineStyle', ...
                         ', "LineWidth", plotLineThickness', ...
                         ', "Color", methodsCI{methodID}.plottingColor', ...
                         ', "DisplayName", methodsCI{methodID}.legendName)'];
linePlots{2}.plotType = 'coverage';
linePlots{2}.firstMethodID = 1;  
linePlots{2}.yLabel = 'Interval Length';
linePlots{2}.yLine = [];
linePlots{2}.legendPosition = [0.844, 0.085, 0.1, 0.07];
linePlots{2}.spacingExponentY = 1;
linePlots{2}.yTicks = [];

% Plot 3: MAE of estimator relative
linePlots{3}.yLim = [0, 2];

linePlots{3}.computeData = ...
    @(resultsArray, methodID) mean(abs(resultsArray{methodID}.estError).^2)./...
            mean(abs(resultsArray{1}.estError).^2);

linePlots{3}.plotCall = ['plot(spacing, smooth(currentData)', ...
                         ', methodsCI{methodID}.plottingLineStyle', ...
                         ', "LineWidth", plotLineThickness', ...
                         ', "Color", methodsCI{methodID}.plottingColor', ...
                         ', "DisplayName", methodsCI{methodID}.legendName)'];
linePlots{3}.plotType = 'estError';
linePlots{3}.firstMethodID = 2;  
linePlots{3}.yLabel = 'Relative MSE';
linePlots{3}.yLine  = 1;
linePlots{3}.legendPosition = [0.844, 0.414, 0.1, 0.07];
linePlots{3}.spacingExponentY = 1;
linePlots{3}.yTicks = 0:0.5:2;

% Coverage and length plots (Color)


% Extract number of sample sizes used. 
% N indexes rows; T indexes columns
numN = length(Ns);
numT = length(Ts);

% Zip together distribution samplers in the format (thetaSampler, uSampler)
samplerTable = combinations(thetaDistrsArray, uDistrsArray);

% Each combination of distributions receives their own plot

for plotID = 1:1 % 3:length(linePlots)
    for plotDGPID = 1:1 % height(samplerTable)

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
        [ha, ~] = tight_subplot(numN, numT,[.07 .023],[.07 .05],[.05 .04]);

        % Loop over (N, T): each combination receives a subplot
        for tID = 1:numT
            for nID = 1:numN

                % Create subplot
                plotNum = (nID-1)*numT+tID;
                axes(ha(plotNum)) %, 'Parent', p);

                % Extract current sample sizes
                N = Ns(nID);
                T = Ts(tID);

                % Extract current samplers for theta and u
                thetaSampler = samplerTable{plotDGPID, 1}{1};
                uSampler = samplerTable{plotDGPID, 2}{1};

                % Load in corresponding simulation result file
                fileName = makeOutputFileName(thetaSampler, uSampler, ...
                    N, T, ...
                    numSamples, simContext);
                load(fileName)
                
                % Patch colors 
                setConfidenceIntervalMethods_ExtremeTuningParameters

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
                if nID == numN
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

                 
                yticks( linePlots{plotID}.yTicks.^linePlots{plotID}.spacingExponentY)
                % y label and ticks only on the left plots
                if tID == 1
                    ylabel(linePlots{plotID}.yLabel)

                    %
                    if isempty(linePlots{plotID}.yTicks)
                        yticklabels(defaultYTicks)
                    else
                        
                        yticklabels( linePlots{plotID}.yTicks)
                    end

                end
 

                % Add a title to the subplot and left-justify it
                ttl = title("N="+num2str(Ns(nID))+", T="+num2str(Ts(tID)));
                ttl.Units = 'Normalize';
                ttl.Position(1) = 0;
                ttl.HorizontalAlignment = 'left';

                % Display legend on last plot
                if plotNum == numN*numT
                    legend('Position', linePlots{plotID}.legendPosition)
                end

            end
        end

        % Create figure saving name
        figureSavingName =   "figures/" + simContext + "_" + ...
            linePlots{plotID}.plotType + "_" + ...
            thetaSampler.distrMachineName + "_" + ...
            uSampler.distrMachineName;

        % Export as PNG
        set(gcf, 'PaperPosition', [0 0 plotRatioAllCoverages*10 10])
        print(gcf, figureSavingName, '-dpng', '-r300' );

        % Prepare export settings for PDF
        set(gcf,'Units','Inches');
        pos = get(gcf,'Position');
        set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
        % Export as PDF
        print(gcf, figureSavingName, '-dpdf');
    end

end
 




