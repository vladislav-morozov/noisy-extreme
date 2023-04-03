

%% Plotting parameters

plotLineThickness= 1.1;

plotW = 800;
plotWsel = 1000;
plotHall = 400;
plotH = 270;
plotHMae = 700;
% Specify colors
colorSSmax= [0.99, 0.03, 1];  % subsampled with r=0
colorSSmixed = [222, 7, 7]/255; % subsampled with r=l
colorSimMax = [0.03,0.99, 0.99];
colorSimMaxHill = [60, 103, 161]/255; % Hill
colorSimMixedHill = [3, 103, 161]/255; % Hill
colorSimMaxPWM = [60, 16, 97]/255; % PWM
colorSimMixedPWM = [2, 16, 97]/255; % PWM
colorInterNormal = [227, 207, 30]/255; % IVT with normal quantiles
colorInterSS = [230, 187, 46]/255; % IVT with subsampling
colorExtrapolation = [255, 165,0]/255; % Extrapolation
colorRaw = [46, 230, 46]/255;
colorJW = [ 106, 130, 68]/255;
colorMW = [ 0, 130, 128]/255;
%% Load in files

currentFileName =  ['Outputs/',num2str(nSamples),'N', num2str(N), 'T', num2str(T), 'F', thetaNameSave{thetaDistrChoice},...
        thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
        uParamNameSave{uDistrChoice}, num2str(uDistributionParam{uDistrChoice}),'.mat' ];
load(currentFileName)

% Patch in the extrapolation estimator
currentFileName =  ['Outputs/inter',num2str(nSamples),'N', num2str(N), 'T', num2str(T), 'F', thetaNameSave{thetaDistrChoice},...
        thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
        uParamNameSave{uDistrChoice}, num2str(uDistributionParam{uDistrChoice}),'.mat' ];
load(currentFileName)

% Set spacing based on quantiles associated to the distribution
spacingStep = 10;
spacing = 1:length(quantilesConsidered);
spacing= (spacing).^spacingExponent;

plotQuietly =1; 

%% Coverages (all)

% Create figure
if plotQuietly ~= 1
    p = figure('Renderer', 'painters', 'Position', [50 50 plotW plotHall]);
else
    p = figure('visible','off', 'Renderer', 'painters', 'Position', [50 50 plotW plotHall]);% Do not plot
end

% Start plot, create labels
plot(spacing, mean(containsSubsampledMixed,1),'-x','LineWidth', plotLineThickness, 'Color', colorSSmax)
xticks([spacing(1:spacingStep:end), spacing(end)])  
xticklabels([quantilesConsidered(1:spacingStep:end), quantilesConsidered(end)])
xlim([min(spacing), max(spacing)]);
hold on

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
 