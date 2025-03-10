% ===========================================================
% File: exportEmpiricalPlots.m
% Description: This script exports the figures for the empi-
%              rical application to extreme quantiles of firm
%              productivity in denser and less dense areas.
% ===========================================================
%
% Project Name: Inference on Extreme Quantiles of Unobserved 
%               Individual Heterogeneity
% Author: Vladislav Morozov
% ===========================================================
%
% This script exports the 
%
% Created figures are saved in the 'results/figures/' folder.
%
% Implementation notes: 
%  
% ===========================================================

%% Load configuration parameters

setPlottingParametersEmpirical
 
% Quantiles without adjustment
% One plot per sector

% Loop through confidence interval sets
for ciSetID = 1 : length(ciSets)
    ciIDsToPlot = ciSets{ciSetID}.ciIDs;


    % Loop through sectors
    for comboID =  1 : numNonDensCombos

        % Export the required sectors (due to data avalaibility limitations)
        if ~ismember(exportCombosNoDens{comboID, 1}, sectorsExported)
            continue
        end

        % --- Figure creation ---
        figure('Renderer','painters', ...
            'Position', [50 50 plotW plotH])

        % Create tight subplot with density statuses as rows
        if exportCombosNoDens{comboID, 1} == sectorsExported(1)
            topMarg = 0.20;
        else
            topMarg = 0.15;
        end
        [has, ~] = tight_subplot(2, length(densityLevels), ...
            [0.08 0.045], [0.13 topMarg], [0.05 0.05]);

        % --- Plotting loop ---
        for densityID = 1 : length(densityLevels)

            % Initialize empty legend
            legendVec = [];

            % Find position in full combo table
            overallComboID = findOverallID(exportCombinations, ...
                exportCombosNoDens, ...
                densityVarName, ...
                densityLevels, ...
                comboID, ...
                densityID);

            % Load in data if it exists
            fileName  = empResultOutputName(empResultFolder, ...
                exportCombinations, overallComboID);
            try
                load(fileName)
            catch
                axes(has(0 + densityID))
                text('String','N/A',...
                    'Units','normalized', ...
                    'Position', [0.4, 0.5]);
                axes(has(1 + densityID))
                text('String','N/A',...
                    'Units','normalized', ...
                    'Position', [0.4, 0.5]);
                continue
            end

            % Extract sample sizes
            sampleSize{densityID} = currentResults.N;

            % --- Plotting quantiles ---
            for ciID = 1 : length(currentResults.fittedCIs) 

                % Skip aproach if necessary
                if ~ ismember(ciID, ciIDsToPlot)
                    continue
                end

                % Extract quantile data
                quantileData = currentResults.fittedCIs{ciID}.fittedCI;
                quantileData = smoothdata(quantileData', ...
                    "gaussian", ciSets{ciSetID}.gaussK)';

                % Extract target quantiles
                currentTargetQuantiles = ...
                  currentResults.fittedCIs{ciID}.targetQuantiles;

                for tailID = 1 : 2
                    % Left tail is 1, right tail is 2

                    % Compute plotting data
                    [tailTargetQuantiles, tailQuantiles, ...
                        spacing, ticks, tickLabels, ...
                        thresholdTau] = ...
                        tailPlotData(currentTargetQuantiles, ...
                        quantileData, ...
                        thresholds(tailID), ...
                        spacingExponentX, tickStep, ...
                        currentResults.N);
                    spacingMarker = spacing(1:markerStep:end);
                    tailMarker = tailQuantiles(:, 1:markerStep:end);

                    % Switch axes
                    axes(has(2 * (tailID - 1) + densityID))

                    % Line plot
                    plot(spacing, tailQuantiles, ...
                        "LineStyle", patchedCI{ciID}.plottingLineStyle, ...
                        "LineWidth", plotLineThickness, ...
                        "Color", patchedCI{ciID}.(ciSets{ciSetID}.colorField), ...
                        'HandleVisibility','off');
                    hold on

                    % Marker plot
                    plot(spacingMarker, tailMarker, ...
                        currentResults.fittedCIs{ciID}.plottingLineStyle, ...
                        "LineStyle", "none", ...
                        "Marker", patchedCI{ciID}.plottingMarker, ...
                        "MarkerSize", patchedCI{ciID}.plottingMarkerSize, ...
                        "LineWidth", plotLineThickness, ...
                        "Color", patchedCI{ciID}.(ciSets{ciSetID}.colorField), ...
                        'HandleVisibility','off');

                    % Legend plot
                    plot(-0.001, min(tailQuantiles, [], 'all'), ...
                        currentResults.fittedCIs{ciID}.plottingLineStyle, ...
                        "LineStyle", patchedCI{ciID}.plottingLineStyle, ...
                        "Marker", patchedCI{ciID}.plottingMarker, ...
                        "MarkerSize", patchedCI{ciID}.plottingMarkerSize, ...
                        "LineWidth", plotLineThickness, ...
                        "Color", patchedCI{ciID}.(ciSets{ciSetID}.colorField), ...
                        "DisplayName", patchedCI{ciID}.legendName);

                    % x-axis: ticks, labels, limits
                    xticks(ticks)
                    xticklabels(tickLabels)
                    xlim([min(spacing), max(spacing)])

                    % --- Extreme rule of thumb zone ---
                    % Get coordinate of zone start
                    [~, coord] = min(abs(tailTargetQuantiles - thresholdTau));
                    % Add vertical line for zone border
                    xline(spacing(coord), ":", ...
                        'HandleVisibility','off', ...
                        "Color", [0.7,0.7,0.7])
                    % Shade the rea
                    if tailID == 1
                        xregion(spacing(1), spacing(coord), ...
                            "FaceColor", extremeRegionColor, ...
                            'HandleVisibility','off')
                    else
                        xregion(spacing(coord), spacing(end), ...
                            "FaceColor", extremeRegionColor, ...
                            'HandleVisibility','off')
                    end 
                end 
            end
        end

        % --- y-limits ---
        for tailID = 1 : 2
            if useRunningYLim 
                % Set dummy limits
                yLimRunning = [inf, -inf];
                for densityID = 1 : length(densityLevels)
                    % Switch axes
                    axes(has(2 * (tailID - 1) + densityID))

                    % Get limits of current axis
                    yLimRunning = [yLimRunning; get(gca, 'YLim')];
                end
                % Expand limits to fit both kinds of areas
                ylim([min(yLimRunning(:, 1)), max(yLimRunning(:, 2)) ])
                % Delete ticks on the right plots
                if densityID ~= 1
                    yticklabels([])
                end
            else
                for densityID = 1 : length(densityLevels)
                    % Switch axes
                    axes(has(2 * (tailID - 1) + densityID))
                    ylim(yLimsSplit{tailID}{find(sectorsExported == exportCombosNoDens{comboID, 1})});
                end
            end  
        end

        % --- Left/right styling: xlabel, rectangles, area text ---
        % Set coordinates for areas
        if exportCombosNoDens{comboID, 1} == sectorsExported(1)
            rectangleCoords = rectangleFirst;
            textCoords = textCoordFirst;
        else
            rectangleCoords = rectangleAfter;
            textCoords = textCoordAfter;
        end
        % Add objects
        for densityID = 1 : length(densityLevels)
            % xlabel
            axes(has(2 + densityID));
            xlabel("Quantile")

            % Draw faint rectangles around below/above median density plots
            annotation('rectangle',rectangleCoords{densityID}, ...
                'Color',rectangleColor)

            % Add text on top of rectangle
            boxTitle = densityLevels{densityID} + ...
                ". $N$=" + sampleSize{densityID};
            annotation('textbox',textCoords{densityID}, ...
                'String',boxTitle,...
                'EdgeColor','none', ...
                'Color', boxTitleColor,...
                'interpreter','latex')
        end

        % --- Legend on last plot ---
        if densityID == length(densityLevels) && ...
                exportCombosNoDens{comboID, 1} == sectorsExported(end)
            % legend(legendVec)
            legend()
        end

        % --- Suptitle ---
        % Add overall title to first exported plot
        if exportCombosNoDens{comboID, 1} == sectorsExported(1)
            firstLine = firstLineNoAdjust;
        else
            firstLine = '';
        end
        % Set the suptitle
        sgt = sgtitle(...
            suptitleBuilderQuantileComp(firstLine, ...
            currentResults, ...
            densityVarName, ...
            sectorLabelsPath));

        % --- Exporting in SVG and PDF ---
        figureSavingName = empResultOutputName(figureOutputFolder, ...
            exportCombosNoDens,...
            comboID);
        figureSavingName = extractBefore(figureSavingName, ...
            strlength(figureSavingName)-11);
        figureSavingName = figureSavingName + ciSets{ciSetID}.titleTail;
        set(gcf,'Units','Inches');
        pos = get(gcf,'Position');
        set(gcf,'PaperPositionMode','Auto',...
            'PaperUnits','Inches', ...
            'PaperSize',[pos(3), pos(4)])
        print(gcf, figureSavingName, '-dsvg');
        print(gcf, figureSavingName, '-dpdf');
    end
end

%% Auxiliary functions

function [tailTargetQuantiles, tailQuantiles, ...
    spacing, ...
    ticks, tickLabels, ...
    ruleOfThumbTau] = ...
        tailPlotData(targetQuantiles, quantileData, ...
                    thresholdQ, ...
                    spacingExponentX, tickStep, ...
                    N)
% tailPlotData Determine

    if thresholdQ >= 0.5
        % Right tail
        
        % Extract data
        tailTargetQuantiles = targetQuantiles(targetQuantiles >= thresholdQ);
        tailQuantiles = quantileData(:, targetQuantiles >= thresholdQ);

        % Create nonlinear spacing
        spacing = 1:length(tailTargetQuantiles);
        spacing = (spacing).^spacingExponentX;

        % Determine ticks
        ticks = unique([spacing(1:tickStep:end), spacing(end)]);

        % Determine tick labels
        tempLabels = tailTargetQuantiles;
        tempLabels(2:end-1) = round(tempLabels(2:end-1), 5);
        tempLabels = tempLabels(:);
        tempLabels = [tempLabels(1:tickStep:end); tempLabels(end)];
        tickLabels = unique(tempLabels);

        % Compute rule of thumb threshold
        ruleOfThumbTau = 1 - 100/N;
    else
        % Left tail

        % Extract data
        tailTargetQuantiles = targetQuantiles(targetQuantiles <= thresholdQ);
        tailQuantiles = quantileData(:, targetQuantiles <= thresholdQ);

        % Create nonlinear spacing
        spacing = 1:length(tailTargetQuantiles);
        spacing = (spacing).^spacingExponentX;
        spacing = -fliplr(spacing);

        % Determine ticks
        ticks = unique([spacing(1:tickStep:end), spacing(end)]);

        % Determine tick labels
        tempLabels = tailTargetQuantiles;
        tempLabels(2:end-1) = round(tempLabels(2:end-1), 3);
        tempLabels = tempLabels(:);
        tempLabels = [tempLabels(1:tickStep:end); tempLabels(end)];
        tickLabels = unique(tempLabels);

        % Compute rule of thumb threshold
        ruleOfThumbTau = 100/N;
    end
    
end

function fileName = ...
    empResultOutputName(empResultFolder, ...
            exportCombinations, overallComboID)
% empResultOutputName Generates a standardized file name for quantile
% estimation and CI output.
%
% Args:
%     quantileOutputFolder (string): path to folder where the results
%       should be stored
%     currentComboTable (table): table used for selecting slices of
%       data. Its column names will form part of the name.
%     comboID (integer): row ID for currentComboTable. Values from that
%       row are assumed to characterize the dataset and used to save
%       the results.
%
% Returns:
%     fileName (str): Constructed file name including all relevant
%         parameters, saved in the quantileOutputFolder
 
    % Initialize the file name
    fileName = "";

    % Generate section based on filtering columns and their values 
    for filterColID = 1 : length(exportCombinations.Properties.VariableNames)

        % Name and value of current column
        currentColName = exportCombinations.Properties.VariableNames{filterColID};
        currentFilterValue = exportCombinations{overallComboID, filterColID};

        % Update name
        fileName = fileName +  currentColName + "_" + num2str(currentFilterValue);

        % Add an underscore unless processing last column
        if filterColID ~= length(exportCombinations.Properties.VariableNames)
            fileName = fileName + "_";
        end

    end
 
    % Add the folder
    fileName = empResultFolder + fileName;
end

function overallComboID = findOverallID(currentComboTable, ...
                            currentComboTableNoAbsentVar, ...
                            absentVarName, ...
                            absentVarLevels, ...
                            comboID, ...
                            absentVarLevelID)
% findOverallID Find the index of the current reduced combination in the
% full combination table when the two differ by absentVar.
% 
% Args: 
%     currentComboTable (table): full table with all variables.
%     currentComboTableNoAbsentVar (table): reduced table that does not  
%       have absentVar.
%     absentVarName (string): name of the absent variable
%     absentVarLevels (cell): levels of the absent variable
%     comboID (integer): row index of the combo in the table with no
%       absentVar.
%     absentVarLevelID (integer): index of desired level of absentVar.
% 
% Returns:
%     overallComboID (index): position of desired combo in overall table 

    % Find position in full combo table
    idx = currentComboTable.(absentVarName) == absentVarLevels{absentVarLevelID};
    % Loop through columns specified to be filtered on
    for filterColID = 1 : length(currentComboTableNoAbsentVar.Properties.VariableNames)
        % Name and value of current column
        currentColName = currentComboTableNoAbsentVar.Properties.VariableNames{filterColID};
        currentFilterValue = currentComboTableNoAbsentVar{comboID, filterColID};
        % Update index
        idx = idx & currentComboTable.(currentColName) == currentFilterValue;
    end
    overallComboID = 1 : height(currentComboTable);
    overallComboID = overallComboID(idx);
end


function suptitle = suptitleBuilderQuantileComp(initString, ...
                    currentResults, ...
                    densityVarName, ...
                    sectorLabelsPath)
% suptitleBuilderQuantileComp Build the suptitle for plots of extreme
% quantiles
%
% Args:
%     initString (string): first line of suptitle.
%     currentResults (quantileEstCIArray): array of results.
%     densityVarName (string): name of density variable.
%     sectorLabelPath (string): path to table with sector names. 
%
% Returns:
%      suptitle (cell): cell of suptitle lines

    % Create array to hold lines of title
    suptitle = cell(1);
    currentIndex = 1;

    % Insert the first line if supplied
    if initString
        suptitle{currentIndex} = initString;
        currentIndex = currentIndex + 1;
    end 

    % Construct remaining parts based on characteristics aside from
    % densities
    charTable = currentResults.characteristics;
    charTable.(densityVarName) = [];

    % Add sector information
    sectorInfoFlag = any(cellfun(@isequal, ...
        charTable.Properties.VariableNames, ...
        repmat({"nace_section"}, ...
            size(charTable.Properties.VariableNames))));
    if sectorInfoFlag
        % Import labels for sectors
        sectorLabels = readtable(sectorLabelsPath);
        sectorLabels = convertvars(sectorLabels,"name", 'string');
        suptitle{currentIndex} = "Sector: " + sectorLabels{charTable.nace_section, 2}; 
    else
        suptitle{currentIndex} = "Pooling all sectors";
    end
 
end