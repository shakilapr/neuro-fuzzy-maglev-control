% ======================================================================
% Data Preprocessing
% Part of: Neuro-Fuzzy Control for Magnetic Levitation Systems
% Author: Shakila Praveen Rathnayake
% Email: shakilabeta@gmail.com
% ======================================================================

% Section 3: Data Preprocessing
% ================================

% Define figure folder for this section
figureFolder3 = 'figures/Section3';
if ~exist(figureFolder3, 'dir')
    mkdir(figureFolder3);
end

% Copy of data for comparison
data_before_clipping = data;

% 3.1 Handle missing and infinite values
data = rmmissing(data);
data = data(~any(isinf(table2array(data)), 2), :);

% 3.2 Clip variables to valid ranges
error_range = [-1, 1];
error_rate_range = [-10, 10];
control_signal_range = [-3, 3];

% Initialize clipping counters
clippedCounts = zeros(length(columnNames),1);

for i = 1:length(columnNames)
    varName = columnNames{i};
    originalData = data{:, varName};
    beforeClipping = originalData;
    switch varName
        case 'Error'
            minVal = error_range(1); 
            maxVal = error_range(2);
        case 'ErrorRate'
            minVal = error_rate_range(1); 
            maxVal = error_rate_range(2);
        case 'ControlSignal'
            minVal = control_signal_range(1); 
            maxVal = control_signal_range(2);
    end
    % Count number of points to be clipped
    clippedCounts(i) = sum(originalData < minVal | originalData > maxVal);
    % Perform clipping
    data{:, varName} = min(max(originalData, minVal), maxVal);
    afterClipping = data{:, varName};
    
    % Side-by-side histograms with improved resolution
    figure('Visible', 'off');
    set(gcf, 'Position', [100, 100, 2400, 1200]); % Larger figure for side-by-side
    subplot(1,2,1);
    histogram(beforeClipping, 50, 'FaceColor', [0.2 0.6 0.8]);
    title(sprintf('Histogram of %s Before Clipping', varName), 'FontSize', 14);
    xlabel(varName, 'FontSize', 12);
    ylabel('Frequency', 'FontSize', 12);
    
    subplot(1,2,2);
    histogram(afterClipping, 50, 'FaceColor', [0.8 0.2 0.6]);
    title(sprintf('Histogram of %s After Clipping', varName), 'FontSize', 14);
    xlabel(varName, 'FontSize', 12);
    ylabel('Frequency', 'FontSize', 12);
    
    figureFileName = sprintf('%s_Histograms_BeforeAfterClipping.png', varName);
    print(fullfile(figureFolder3, figureFileName), '-dpng', '-r300');
    close(gcf);
    
    % Box plots before and after clipping with improved resolution
    figure('Visible', 'off');
    set(gcf, 'Position', [100, 100, 2400, 1200]);
    subplot(1,2,1);
    boxplot(beforeClipping, 'Colors', [0.2 0.6 0.8]);
    title(sprintf('Box Plot of %s Before Clipping', varName), 'FontSize', 14);
    ylabel(varName, 'FontSize', 12);
    
    subplot(1,2,2);
    boxplot(afterClipping, 'Colors', [0.8 0.2 0.6]);
    title(sprintf('Box Plot of %s After Clipping', varName), 'FontSize', 14);
    ylabel(varName, 'FontSize', 12);
    
    figureFileName = sprintf('%s_BoxPlots_BeforeAfterClipping.png', varName);
    print(fullfile(figureFolder3, figureFileName), '-dpng', '-r300');
    close(gcf);
end

% Clipping impact analysis
totalDataPoints = size(data, 1);
clippingImpactTable = table(columnNames', clippedCounts, ...
    (clippedCounts/totalDataPoints)*100, ...
    'VariableNames', {'Variable', 'ClippedPoints', 'PercentageClipped'});
disp('Clipping Impact Analysis:');
disp(clippingImpactTable);

% Save clipping impact table
writetable(clippingImpactTable, fullfile(figureFolder3, 'ClippingImpactAnalysis.csv'));

% Correlation matrix after preprocessing
corrMatrixPost = corr(table2array(data));
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
imagesc(corrMatrixPost);
colorbar;
title('Correlation Matrix After Preprocessing', 'FontSize', 14);
xticks(1:length(columnNames));
xticklabels(columnNames);
yticks(1:length(columnNames));
yticklabels(columnNames);
xlabel('Variables', 'FontSize', 12);
ylabel('Variables', 'FontSize', 12);
figureFileName = 'CorrelationMatrix_AfterPreprocessing.png';
print(fullfile(figureFolder3, figureFileName), '-dpng', '-r300');
close(gcf);

disp('Data preprocessing completed. Variables are clipped to their valid ranges.');

%% ====================================