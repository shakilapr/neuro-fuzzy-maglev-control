% ======================================================================
% Data Loading and Exploration
% Part of: Neuro-Fuzzy Control for Magnetic Levitation Systems
% Author: Shakila Praveen Rathnayake
% Email: shakilabeta@gmail.com
% ======================================================================

% Section 2: Data Loading and Exploration
% ===============================

% Define figure folder for this section
figureFolder2 = 'figures/Section2';
if ~exist(figureFolder2, 'dir')
    mkdir(figureFolder2);
end

% Define column names
columnNames = {'Error', 'ErrorRate', 'ControlSignal'};

% Load dataset
data = readtable('dataset.csv', 'ReadVariableNames', true);

% Assign variable names (if not already assigned)
data.Properties.VariableNames = columnNames;

% Display first few rows
disp('First 5 rows of the combined dataset:');
disp(head(data, 5));

% Summary statistics
disp('Summary statistics of the combined dataset:');
summary(data);

% Visualize data with improved resolution
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
subplot(3,1,1); 
plot(data.Error, 'LineWidth', 1.5); 
title('Error Over Time', 'FontSize', 14); 
ylabel('Error', 'FontSize', 12);

subplot(3,1,2); 
plot(data.ErrorRate, 'LineWidth', 1.5); 
title('Error Rate Over Time', 'FontSize', 14); 
ylabel('Error Rate', 'FontSize', 12);

subplot(3,1,3); 
plot(data.ControlSignal, 'LineWidth', 1.5); 
title('Control Signal Over Time', 'FontSize', 14); 
ylabel('Control Signal', 'FontSize', 12);

xlabel('Time Steps', 'FontSize', 12);
figureFileName = 'VariablesOverTime.png';
print(fullfile(figureFolder2, figureFileName), '-dpng', '-r300');
close(gcf);

% Histogram of variables with improved resolution
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
for i = 1:length(columnNames)
    subplot(2,2,i);
    histogram(data{:, i}, 50, 'FaceColor', [0.2 0.6 0.8]);
    title(sprintf('Histogram of %s', columnNames{i}), 'FontSize', 12);
    xlabel(columnNames{i}, 'FontSize', 12);
    ylabel('Frequency', 'FontSize', 12);
end
% Remove empty subplot if number of variables is odd
if mod(length(columnNames),2) ~= 0
    subplot(2,2,length(columnNames)+1);
    axis off;
end
figureFileName = 'VariableHistograms.png';
print(fullfile(figureFolder2, figureFileName), '-dpng', '-r300');
close(gcf);

% Combined distribution plot with improved resolution
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
hold on;
colors = lines(length(columnNames));
for i = 1:length(columnNames)
    histogram(data{:, i}, 50, 'Normalization', 'pdf', ...
        'DisplayName', columnNames{i}, 'FaceAlpha', 0.5, ...
        'EdgeColor', 'none', 'FaceColor', colors(i,:));
end
title('Combined Variable Distributions', 'FontSize', 14);
xlabel('Value', 'FontSize', 12);
ylabel('Probability Density', 'FontSize', 12);
legend('show', 'Location', 'best');
grid on;
figureFileName = 'CombinedVariableDistributions.png';
print(fullfile(figureFolder2, figureFileName), '-dpng', '-r300');
close(gcf);

% Correlation matrix heatmap
corrMatrix = corr(table2array(data));
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
imagesc(corrMatrix);
colorbar;
title('Correlation Matrix', 'FontSize', 14);
xticks(1:length(columnNames));
xticklabels(columnNames);
yticks(1:length(columnNames));
yticklabels(columnNames);
xlabel('Variables', 'FontSize', 12);
ylabel('Variables', 'FontSize', 12);
figureFileName = 'CorrelationMatrix.png';
print(fullfile(figureFolder2, figureFileName), '-dpng', '-r300');
close(gcf);

% Pairwise scatter plots
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1600, 1200]);
plotmatrix(table2array(data));
sgtitle('Pairwise Scatter Plots', 'FontSize', 16);
figureFileName = 'PairwiseScatterPlots.png';
print(fullfile(figureFolder2, figureFileName), '-dpng', '-r300');
close(gcf);

% Box plots for outlier detection
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
for i = 1:length(columnNames)
    subplot(2,2,i);
    boxplot(data{:, i}, 'Colors', [0.2 0.6 0.8], 'Whisker', 1.5);
    title(sprintf('Box Plot of %s', columnNames{i}), 'FontSize', 12);
    ylabel(columnNames{i}, 'FontSize', 12);
end
% Remove empty subplot if number of variables is odd
if mod(length(columnNames),2) ~= 0
    subplot(2,2,length(columnNames)+1);
    axis off;
end
figureFileName = 'BoxPlots_OutlierDetection.png';
print(fullfile(figureFolder2, figureFileName), '-dpng', '-r300');
close(gcf);

% Time-Series Zoomed Plots
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
startIdx = 1;
endIdx = min(1000, size(data,1)); % Ensure endIdx does not exceed data size
subplot(3,1,1); 
plot(data.Error(startIdx:endIdx), 'LineWidth', 1.5); 
title('Error Over Time (Zoomed)', 'FontSize', 14); 
ylabel('Error', 'FontSize', 12);

subplot(3,1,2); 
plot(data.ErrorRate(startIdx:endIdx), 'LineWidth', 1.5); 
title('Error Rate Over Time (Zoomed)', 'FontSize', 14); 
ylabel('Error Rate', 'FontSize', 12);

subplot(3,1,3); 
plot(data.ControlSignal(startIdx:endIdx), 'LineWidth', 1.5); 
title('Control Signal Over Time (Zoomed)', 'FontSize', 14); 
ylabel('Control Signal', 'FontSize', 12);

xlabel('Time Steps', 'FontSize', 12);
figureFileName = 'TimeSeriesZoomedPlots.png';
print(fullfile(figureFolder2, figureFileName), '-dpng', '-r300');
close(gcf);

% Moving average trend analysis
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
windowSize = 100;
for i = 1:length(columnNames)
    subplot(3,1,i);
    movAvg = movmean(data{:, i}, windowSize);
    plot(movAvg, 'LineWidth', 1.5);
    title(sprintf('%s Moving Average (Window Size = %d)', columnNames{i}, windowSize), 'FontSize', 12);
    ylabel(columnNames{i}, 'FontSize', 12);
    grid on;
end
xlabel('Time Steps', 'FontSize', 12);
figureFileName = 'MovingAverageTrendAnalysis.png';
print(fullfile(figureFolder2, figureFileName), '-dpng', '-r300');
close(gcf);

% Scatter plot for interaction terms
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
scatter(data.Error .* data.ErrorRate, data.ControlSignal, 15, [0.2 0.6 0.8], 'filled');
xlabel('Error × ErrorRate', 'FontSize', 12);
ylabel('Control Signal', 'FontSize', 12);
title('Interaction between Error × ErrorRate and Control Signal', 'FontSize', 14);
grid on;
figureFileName = 'InteractionScatterPlot.png';
print(fullfile(figureFolder2, figureFileName), '-dpng', '-r300');
close(gcf);

% Missing Values Visualization
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
imagesc(ismissing(data{:,:}));
colorbar;
title('Missing Values Heatmap', 'FontSize', 14);
xlabel('Variable', 'FontSize', 12);
ylabel('Data Point', 'FontSize', 12);
xticks(1:length(columnNames));
xticklabels(columnNames);
yticks([]);
figureFileName = 'MissingValuesHeatmap.png';
print(fullfile(figureFolder2, figureFileName), '-dpng', '-r300');
close(gcf);

% Cumulative Distribution Functions (CDF)
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
hold on;
colors = lines(length(columnNames));
for i = 1:length(columnNames)
    [f,x] = ecdf(data{:, i});
    plot(x, f, 'LineWidth', 2, 'Color', colors(i,:));
end
legend(columnNames, 'Location', 'best');
title('Cumulative Distribution Functions', 'FontSize', 14);
xlabel('Value', 'FontSize', 12);
ylabel('Cumulative Probability', 'FontSize', 12);
grid on;
figureFileName = 'CumulativeDistributionFunctions.png';
print(fullfile(figureFolder2, figureFileName), '-dpng', '-r300');
close(gcf);

% Principal Component Analysis (PCA) Scatter Plot
[coeff, score, ~, ~, explained] = pca(table2array(data));
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
scatter(score(:,1), score(:,2), 15, [0.2 0.6 0.8], 'filled');
xlabel(sprintf('PC1 (%.2f%% Variance)', explained(1)), 'FontSize', 12);
ylabel(sprintf('PC2 (%.2f%% Variance)', explained(2)), 'FontSize', 12);
title('PCA Scatter Plot', 'FontSize', 14);
grid on;
figureFileName = 'PCA_ScatterPlot.png';
print(fullfile(figureFolder2, figureFileName), '-dpng', '-r300');
close(gcf);

% Data Completeness Bar Chart
missingSummary = sum(ismissing(data{:,:}));
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
barh(missingSummary, 'FaceColor', [0.2 0.6 0.8]);
yticks(1:length(columnNames));
yticklabels(columnNames);
xlabel('Number of Missing Values', 'FontSize', 12);
title('Data Completeness', 'FontSize', 14);
grid on;
figureFileName = 'DataCompletenessBarChart.png';
print(fullfile(figureFolder2, figureFileName), '-dpng', '-r300');
close(gcf);

%% ================================