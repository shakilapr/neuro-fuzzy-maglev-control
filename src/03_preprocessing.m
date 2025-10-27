% =====================================
% Section 3: Data Preprocessing
% =====================================

% Define figure folder for this section
figureFolder = 'figures/Section3';
if ~exist(figureFolder, 'dir')
    mkdir(figureFolder);
end

% Copy of data for comparison
data_before_clipping = data;

% 3.1 Handle missing and infinite values
data = rmmissing(data);
data = data(~any(isinf(data{:,:}), 2), :);

% 3.2 Clip variables to valid ranges
error_range = [-1, 1];
error_rate_range = [-10, 10];
control_signal_range = [-3, 3];
feedback_range = [-3, 0];
generated_signal_range = [-3, 0];

% Initialize clipping counters
clippedCounts = zeros(length(columnNames),1);

for i = 1:length(columnNames)
    varName = columnNames{i};
    originalData = data{:, varName};
    beforeClipping = originalData;
    switch varName
        case 'Error'
            minVal = error_range(1); maxVal = error_range(2);
        case 'ErrorRate'
            minVal = error_rate_range(1); maxVal = error_rate_range(2);
        case 'ControlSignal'
            minVal = control_signal_range(1); maxVal = control_signal_range(2);
        case 'Feedback'
            minVal = feedback_range(1); maxVal = feedback_range(2);
        case 'GeneratedSignal'
            minVal = generated_signal_range(1); maxVal = generated_signal_range(2);
    end
    % Count number of points to be clipped
    clippedCounts(i) = sum(originalData < minVal | originalData > maxVal);
    % Perform clipping
    data{:, varName} = min(max(originalData, minVal), maxVal);
    afterClipping = data{:, varName};
    
    % Side-by-side histograms
    figure;
    subplot(1,2,1);
    histogram(beforeClipping, 50);
    title(sprintf('Histogram of %s Before Clipping', varName));
    xlabel(varName);
    ylabel('Frequency');
    
    subplot(1,2,2);
    histogram(afterClipping, 50);
    title(sprintf('Histogram of %s After Clipping', varName));
    xlabel(varName);
    ylabel('Frequency');
    
    figureFileName = sprintf('%s_Histograms_BeforeAfterClipping.png', varName);
    saveas(gcf, fullfile(figureFolder, figureFileName));
    close(gcf);
    
    % Box plots before and after clipping
    figure;
    subplot(1,2,1);
    boxplot(beforeClipping);
    title(sprintf('Box Plot of %s Before Clipping', varName));
    ylabel(varName);
    
    subplot(1,2,2);
    boxplot(afterClipping);
    title(sprintf('Box Plot of %s After Clipping', varName));
    ylabel(varName);
    
    figureFileName = sprintf('%s_BoxPlots_BeforeAfterClipping.png', varName);
    saveas(gcf, fullfile(figureFolder, figureFileName));
    close(gcf);
end

% Clipping impact analysis
totalDataPoints = size(data, 1);
clippingImpactTable = table(columnNames', clippedCounts, (clippedCounts/totalDataPoints)*100, ...
    'VariableNames', {'Variable', 'ClippedPoints', 'PercentageClipped'});
disp('Clipping Impact Analysis:');
disp(clippingImpactTable);

% Save clipping impact table
writetable(clippingImpactTable, fullfile(figureFolder, 'ClippingImpactAnalysis.csv'));

% Correlation matrix after preprocessing
corrMatrixPost = corr(data{:,:});
figure;
heatmap(columnNames, columnNames, corrMatrixPost, 'Colormap', parula, 'ColorbarVisible', 'on');
title('Correlation Matrix Heatmap After Preprocessing');
figureFileName = 'CorrelationMatrixHeatmap_AfterPreprocessing.png';
saveas(gcf, fullfile(figureFolder, figureFileName));
close(gcf);

disp('Data preprocessing completed. Variables are clipped to their valid ranges.');