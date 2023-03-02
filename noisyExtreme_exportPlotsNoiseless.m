%% Plotting parameters

plotLineThickness= 1.1;

plotW = 800;
plotH = 300;
plotHMae = 800;
% Specify colors
colorSSmax= [0.99, 0.03, 1]; % magenta
% colorSSmixed = [0.5, 0.03, 1]; % violet
colorSSmixed = [222, 7, 7]/255;

colorSimMax = [0.03,0.99, 0.99];
colorSimMixed = [3, 103, 161]/255;
colorSimMixedT = [2, 16, 97]/255;

% colorInterNormal = [255, 255, 25]/255;
colorInterNormal = [227, 207, 30]/255;
colorInterSS = [230, 187, 46]/255;

colorRaw = [46, 230, 46]/255;
colorJW = [ 106, 130, 68]/255;
%% Load in files

currentFileName =  ['Outputs/',num2str(nSamples),'N', num2str(N),'F', thetaNameSave{thetaDistrChoice},...
        thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
       'Noiseless.mat' ];
load(currentFileName)
 
% Set spacing based on quantiles associated to the distribution
spacingStep = 10;
spacing = 1:length(quantilesConsidered);
spacing= (spacing).^spacingExponent;

%% Coverages (all)
if plotQuietly ~= 1
    % Plot
    p = figure('Renderer', 'painters', 'Position', [50 50 plotW plotH]);
else
    p = figure('visible','off', 'Renderer', 'painters', 'Position', [50 50 800 350]);% Do not plot
end
plot(spacing, mean(containsSubsampledMax,1),'-o','LineWidth', plotLineThickness, 'Color', colorSSmax) % very magenta
xticks([spacing(1:spacingStep:end), spacing(end)])
xticklabels([quantilesConsidered(1:spacingStep:end), quantilesConsidered(end)])
xlim([min(spacing), max(spacing)]);
hold on
% plot(spacing, mean(containsSubsampledq,1),'LineWidth', 2)
plot(spacing, mean(containsSubsampledMixed,1),'-x','LineWidth', plotLineThickness, 'Color', colorSSmixed)
plot(spacing, mean(containsSimulatedMax,1),'-d', 'LineWidth', plotLineThickness, 'Color', colorSimMax)
% plot(spacing, mean(containsSimulatedQ,1),'LineWidth', plotLineThickness)
plot(spacing, mean(containsSimulatedMixed,1),'-s','LineWidth', plotLineThickness, 'Color', colorSimMixed)
% plot(spacing, mean(containsSimulatedMaxT,1),'LineWidth', plotLineThickness)
% plot(spacing, mean(containsSimulatedQT,1),'LineWidth', plotLineThickness)
plot(spacing, mean(containsSimulatedMixedT,1),'-p','LineWidth', plotLineThickness, 'Color', colorSimMixedT)

plot(spacing, mean(containsIntermediateNormal,1),'--^','LineWidth', plotLineThickness, 'Color', colorInterNormal)
plot(spacing, mean(containsIntermediateSS,1),'--v','LineWidth', plotLineThickness, 'Color', colorInterSS)
plot(spacing, mean(containsDebiased,1),'-..','LineWidth', plotLineThickness, 'Color', colorJW)
%plot(spacing, mean(containsTrue,1),'LineWidth', plotLineThickness)
yline(1-alphaCI) ;
  
    legend('Subsampling: max only',  'Subsampling: mixed',  ...
         'Simulated: max only','Simulated: mixed',...
         'Simulated: mixed with truncation',...
        'Intermediate: normal', 'Intermediate: Subsampling',...
         'Central',...
        'Location', 'southwest')%, 'Central: true')
 
xlabel('Quantile')
ylabel('Coverage')
title(['Coverage, 95% CI for quantiles, N=', num2str(N), ', F=', ...
    thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
    num2str(thetaDistributionParam{thetaDistrChoice}), ', noiseless data'])

 
figureSavingName = ['Figures/allCoverage',num2str(nSamples),'N', num2str(N),'F', thetaNameSave{thetaDistrChoice},...
    thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
    'Noiseless'];

saveas(p,figureSavingName,'epsc');

%% Coverages (selected)


if plotQuietly ~= 1
    % Plot
    p = figure('Renderer', 'painters', 'Position', [50 50 plotW plotH]);
else
    p = figure('visible','off', 'Renderer', 'painters', 'Position', [50 50 800 350]);% Do not plot
end
plot(spacing, mean(containsSubsampledMax,1),'-o','LineWidth', plotLineThickness,  'Color', colorSSmax)
xticks([spacing(1:spacingStep:end), spacing(end)])
xticklabels([quantilesConsidered(1:spacingStep:end), quantilesConsidered(end)])
xlim([min(spacing), max(spacing)]);
hold on
% plot(spacing, mean(containsSubsampledq,1),'LineWidth', 2)
plot(spacing, mean(containsSubsampledMixed,1),'-x','LineWidth', plotLineThickness, 'Color', colorSSmixed)
% plot(spacing, mean(containsSimulatedMax,1),'LineWidth', plotLineThickness)
% plot(spacing, mean(containsSimulatedQ,1),'LineWidth', plotLineThickness)
plot(spacing, mean(containsSimulatedMixed,1),'-s','LineWidth', plotLineThickness, 'Color', colorSimMixed)
% plot(spacing, mean(containsSimulatedMaxT,1),'LineWidth', plotLineThickness)
% plot(spacing, mean(containsSimulatedQT,1),'LineWidth', plotLineThickness)
% plot(spacing, mean(containsSimulatedMixedT,1),'LineWidth', plotLineThickness)

plot(spacing, mean(containsIntermediateNormal,1),'--^','LineWidth', plotLineThickness, 'Color', colorInterNormal)
% plot(spacing, mean(containsIntermediateSS,1),'LineWidth', plotLineThickness)
 plot(spacing, mean(containsDebiased,1),'-..','LineWidth', plotLineThickness,  'Color', colorJW)
% plot(spacing, mean(containsTrue,1),'LineWidth', plotLineThickness)
yline(1-alphaCI) ;
%  
legend('Subsampling: max only',  'Subsampling: mixed',  ...
     'Simulated: mixed',...
    'Intermediate',      'Central',...
    'Location', 'southwest')%, 'Central: true')
xlabel('Quantile')
ylabel('Coverage')
title(['Coverage, 95% CI for quantiles, N=', num2str(N), ', F=', ...
    thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
    num2str(thetaDistributionParam{thetaDistrChoice}), ', noiseless data'])

 
figureSavingName = ['Figures/selectedCoverage',num2str(nSamples),'N', num2str(T), 'F', thetaNameSave{thetaDistrChoice},...
    thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
    'Noiseless'];
saveas(p,figureSavingName,'epsc');
%% Interval length (all)

 

 
if plotQuietly ~= 1
    % Plot
    p = figure('Renderer', 'painters', 'Position', [50 50 plotW plotH]);
else
    p = figure('visible','off', 'Renderer', 'painters', 'Position', [50 50 800 350]);% Do not plot
end

plot(spacing, mean(lengthSubsampledMax,1),'-o', 'LineWidth', plotLineThickness,  'Color', colorSSmax)
hold on
xticks([spacing(1:spacingStep:end), spacing(end)])
xticklabels([quantilesConsidered(1:spacingStep:end), quantilesConsidered(end)])
xlim([min(spacing), max(spacing)]);
ylim([0, 1.1*max(mean(lengthSubsampledMax))])
% plot(spacing, mean(lengthSubsampledq,1),'LineWidth', plotLineThickness)
plot(spacing, mean(lengthSubsampledMixed,1),'-x','LineWidth', plotLineThickness,  'Color', colorSSmixed)
plot(spacing, mean(lengthSimulatedMax,1),'-d','LineWidth', plotLineThickness,  'Color', colorSimMax)
plot(spacing, mean(lengthSimulatedMixed,1),'-s','LineWidth', plotLineThickness,  'Color', colorSimMixed)
plot(spacing, mean(lengthSimulatedMixedT,1),'-p','LineWidth', plotLineThickness,  'Color', colorSimMixedT)
plot(spacing, mean(lengthIntermediateNormal,1),'--^','LineWidth', plotLineThickness,  'Color', colorInterNormal)
plot(spacing, mean(lengthIntermediateSS,1),'--v', 'LineWidth', plotLineThickness,  'Color', colorInterSS)
plot(spacing, mean(lengthDebiased,1),'-..','LineWidth', plotLineThickness,  'Color', colorJW)
 
%  ylim([0, 1.5*max(mean(lengthSubsampled,1) )])
 

xlabel('Quantile')
ylabel('Coverage')
                       
 
legend('Subsampling: max only',  'Subsampling: mixed',  ...
     'Simulated: max only','Simulated: mixed',...
     'Simulated: mixed with truncation',...
    'Intermediate: normal', 'Intermediate: Subsampling',...
     'Central',...
    'Location', 'best')%, 'Central: true')
xlabel('Quantile')
ylabel('Length')
title(['Length of 95% CI for quantiles, N=', num2str(N),', F=', ...
    thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
    num2str(thetaDistributionParam{thetaDistrChoice}), ', noiseless data'])
figureSavingName = ['Figures/allLength',num2str(nSamples),'N', num2str(N),'F', thetaNameSave{thetaDistrChoice},...
    thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
    'Noiseless' ];

saveas(p,figureSavingName,'epsc');



%% Length (selected)

%  
% if plotQuietly ~= 1
%     % Plot
%     p = figure('Renderer', 'painters', 'Position', [50 50 plotW plotH]);
% else
%     p = figure('visible','off', 'Renderer', 'painters', 'Position', [50 50 800 350]);% Do not plot
% end
% 
% plot(spacing, mean(lengthSubsampledMax,1),'-o', 'LineWidth', plotLineThickness,  'Color', colorSSmax)
% hold on
% xticks([spacing(1:spacingStep:end), spacing(end)])
% xticklabels([quantilesConsidered(1:spacingStep:end), quantilesConsidered(end)])
% xlim([min(spacing), max(spacing)]);
% ylim([0, 1.1*max(mean(lengthSubsampledMax))])
% % plot(spacing, mean(lengthSubsampledq,1),'LineWidth', plotLineThickness)
% plot(spacing, mean(lengthSubsampledMixed,1),'-x','LineWidth', plotLineThickness,  'Color', colorSSmixed)
% % plot(spacing, mean(lengthSimulatedMax,1),'-d','LineWidth', plotLineThickness,  'Color', colorSimMax)
% plot(spacing, mean(lengthSimulatedMixed,1),'-s','LineWidth', plotLineThickness,  'Color', colorSimMixed)
% % plot(spacing, mean(lengthSimulatedMixedT,1),'-p','LineWidth', plotLineThickness,  'Color', colorSimMixedT)
% plot(spacing, mean(lengthIntermediateNormal,1),'--^','LineWidth', plotLineThickness,  'Color', colorInterNormal)
% % plot(spacing, mean(lengthIntermediateSS,1),'--v', 'LineWidth', plotLineThickness,  'Color', colorInterSS)
% plot(spacing, mean(lengthNaive,1), '-.+','LineWidth', plotLineThickness,  'Color', colorRaw)
% plot(spacing, mean(lengthDebiased,1),'-..','LineWidth', plotLineThickness,  'Color', colorJW)
%  
% %  ylim([0, 1.5*max(mean(lengthSubsampled,1) )])
%  
% 
% xlabel('Quantile')
% ylabel('Coverage')
% title(['95% CI for quantiles, N=', num2str(N), ',T=', num2str(T), ', F=', ...
%     thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
%     num2str(thetaDistributionParam{thetaDistrChoice}), ', u_{it}~', uName{uDistrChoice},...
%     ', ', uParamName{uDistrChoice},'=', num2str(uDistributionParam{uDistrChoice}) ])
% 
%                               
%  
% legend('Subsampling: max only',  'Subsampling: mixed',  ...
%      'Simulated: mixed',...
%     'Intermediate',      'Central: raw data', 'Central: analytical correction',...
%     'Location', 'best')%, 'Central: true')
% xlabel('Quantile')
% ylabel('Length')
% title(['Length of 95% CI for quantiles, N=', num2str(N), ',T=', num2str(T), ', F=', ...
%     thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
%     num2str(thetaDistributionParam{thetaDistrChoice}), ', u_{it}~', uName{uDistrChoice},...
%     ', ', uParamName{uDistrChoice},'=', num2str(uDistributionParam{uDistrChoice}) ])
% figureSavingName = ['Figures/selectedLength',num2str(nSamples),'N', num2str(N), 'T', num2str(T), 'F', thetaNameSave{thetaDistrChoice},...
%     thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
%     uParamNameSave{uDistrChoice}, num2str(uDistributionParam{uDistrChoice}) ];
% 
% saveas(p,figureSavingName,'epsc');

%% MAE of corrected estimators

% Use raw sample quantiles
refV = mean(abs(errorSimple));

 
if plotQuietly ~= 1
    % Plot
    p = figure('Renderer', 'painters', 'Position', [50 50 plotW plotH]);
else
    p = figure('visible','off', 'Renderer', 'painters', 'Position', [50 50 800 350]);% Do not plot
end
% subplot(2, 1, 1)
% figure
plot(spacing, mean(abs(errorCorrectedMax)./refV, 1) ,'-o', 'Color', colorSSmax)
hold on 
xlim([min(spacing), max(spacing)]);
xticks([spacing(1:spacingStep:end), spacing(end)])
xticklabels([quantilesConsidered(1:spacingStep:end), quantilesConsidered(end)])
ylim([0.5, 2])
plot(spacing, mean(abs(errorCorrectedMixed)./refV, 1), '-x', 'Color', colorSSmixed)
plot(spacing, mean(abs(errorCorrectedSIMMax)./refV, 1),'-d', 'Color', colorSimMax)
plot(spacing, mean(abs(errorCorrectedSIMMixed)./refV, 1),'-s', 'Color', colorSimMixed)
 
yline(1);
xlabel('Quantile')
ylabel('Relative MAE')
% 
% subplot(2, 1, 2)
% plot(spacing, mean(abs(errorCorrectedMax)./refV, 1) ,'-o', 'Color', colorSSmax)
% hold on 
% xlim([min(spacing), max(spacing)]);
% xticks([spacing(1:spacingStep:end), spacing(end)])
% xticklabels([quantilesConsidered(1:spacingStep:end), quantilesConsidered(end)])
% ylim([0.5, 15])
% plot(spacing, mean(abs(errorCorrectedMixed)./refV, 1), '-x', 'Color', colorSSmixed)
% plot(spacing, mean(abs(errorCorrectedSIMMax)./refV, 1),'-d', 'Color', colorSimMax)
% plot(spacing, mean(abs(errorCorrectedSIMMixed)./refV, 1),'-s', 'Color', colorSimMixed)
%  xlabel('Quantile')
% ylabel('Relative MAE')
% yline(1);
legend( 'Subsampling: max only', 'Subsampling: mixed', ...
    'Simulated: max only', 'Simulated: mixed',... 
       'Location', 'best')

   
xlabel('Quantile')

suptitle({'MAE of corrected estimators, relative to raw sample quantile', ...
     ['N=', num2str(N), ', F=', ...
    thetaName{thetaDistrChoice},', ', thetaParamName{thetaDistrChoice}, '=',...
    num2str(thetaDistributionParam{thetaDistrChoice}),' noiseless data']})


 
figureSavingName = ['Figures/mae',num2str(nSamples),'N', num2str(N), 'F', thetaNameSave{thetaDistrChoice},...
    thetaParamNameSave{thetaDistrChoice}, num2str(thetaDistributionParam{thetaDistrChoice}),...
    'Noiseless'];

saveas(p,figureSavingName,'epsc');
 