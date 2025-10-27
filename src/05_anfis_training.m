% ======================================================================
% ANFIS Model Development
% Part of: Neuro-Fuzzy Control for Magnetic Levitation Systems
% Author: Shakila Praveen Rathnayake
% Email: shakilabeta@gmail.com
% ======================================================================

% Section 5: ANFIS Model Development
% ======================================

% Load ANFIS prepared data
load('anfis_prepared_data.mat');

% Define figure folder for this section
figureFolder5 = 'figures/Section5';
if ~exist(figureFolder5, 'dir')
    mkdir(figureFolder5);
end

% Prepare input and output data
inputs = trainData_ANFIS(:, 1:2); % Error and ErrorRate (non-normalized)
outputs = trainData_ANFIS(:, 3);  % ControlSignal (non-normalized)

% Generate a timestamp for FIS filenames
timestamp = datestr(now, 'yyyymmdd_HHMMSS'); % Format: YYYYMMDD_HHMMSS

% Generate initial FIS structure using genfis1 with adjustable number of MFs
fis = genfis1([inputs outputs], [numMFs_error numMFs_errorRate], 'gbellmf');

% Visualize initial membership functions
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1600, 1200]);
subplot(2,1,1);
plotmf(fis, 'input', 1);
title('Initial Membership Functions for Error', 'FontSize', 14);
subplot(2,1,2);
plotmf(fis, 'input', 2);
title('Initial Membership Functions for ErrorRate', 'FontSize', 14);
figureFileName = 'InitialMembershipFunctions.png';
print(fullfile(figureFolder5, figureFileName), '-dpng', '-r300');
close(gcf);

% Save the initial FIS with timestamp
initialFISFileName = sprintf('anfis_initial_%s.fis', timestamp);
writeFIS(fis, initialFISFileName);

% Set ANFIS training options
anfis_options = anfisOptions('EpochNumber', numEpochs, ...
                             'InitialFIS', fis, ...
                             'ValidationData', testData_ANFIS, ...
                             'OptimizationMethod', 1);

% Train ANFIS model
[anfisModel, trainError, stepSize, chkFIS, chkError] = anfis(trainData_ANFIS, anfis_options);

% Plot training and validation error
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
plot(1:numEpochs, trainError, 'b', 'LineWidth', 2);
hold on;
plot(1:numEpochs, chkError, 'r', 'LineWidth', 2);
legend('Training Error', 'Validation Error', 'FontSize', 12);
xlabel('Epochs', 'FontSize', 12);
ylabel('Error', 'FontSize', 12);
title('ANFIS Training and Validation Error', 'FontSize', 14);
grid on;
figureFileName = 'ANFIS_TrainingValidationError.png';
print(fullfile(figureFolder5, figureFileName), '-dpng', '-r300');
close(gcf);

% Save the trained FIS with timestamp
trainedFISFileName = sprintf('anfis_trained_%s.fis', timestamp);
writeFIS(anfisModel, trainedFISFileName);

% Evaluate ANFIS on testing data
anfis_output = evalfis(testData_ANFIS(:, 1:2), anfisModel);

% Compute evaluation metrics
mae_anfis = mean(abs(testData_ANFIS(:, 3) - anfis_output));
rmse_anfis = sqrt(mean((testData_ANFIS(:, 3) - anfis_output).^2));

% R-squared value
SS_res_anfis = sum((testData_ANFIS(:, 3) - anfis_output).^2);
SS_tot_anfis = sum((testData_ANFIS(:, 3) - mean(testData_ANFIS(:, 3))).^2);
R_squared_anfis = 1 - (SS_res_anfis / SS_tot_anfis);

disp(['ANFIS Mean Absolute Error (MAE): ', num2str(mae_anfis)]);
disp(['ANFIS Root Mean Squared Error (RMSE): ', num2str(rmse_anfis)]);
disp(['ANFIS R-squared: ', num2str(R_squared_anfis)]);

% Plot actual vs predicted control signals
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
plot(testData_ANFIS(:, 3), 'b', 'LineWidth', 1.5, ...
    'DisplayName', 'Actual Control Signal');
hold on;
plot(anfis_output, 'r--', 'LineWidth', 1.5, ...
    'DisplayName', 'ANFIS Predicted Control Signal');
legend('show', 'FontSize', 12);
title('Actual vs. Predicted Control Signal (ANFIS)', 'FontSize', 14);
xlabel('Time Steps', 'FontSize', 12);
ylabel('Control Signal', 'FontSize', 12);
grid on;
hold off;
figureFileName = 'ANFIS_Actual_vs_Predicted.png';
print(fullfile(figureFolder5, figureFileName), '-dpng', '-r300');
close(gcf);

% Plot residual errors
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
residuals_anfis = testData_ANFIS(:, 3) - anfis_output;
plot(residuals_anfis, 'k', 'LineWidth', 1.5);
title('ANFIS Prediction Residuals', 'FontSize', 14);
xlabel('Time Steps', 'FontSize', 12);
ylabel('Residuals', 'FontSize', 12);
grid on;
figureFileName = 'ANFIS_Residuals.png';
print(fullfile(figureFolder5, figureFileName), '-dpng', '-r300');
close(gcf);

% Error distribution
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
histogram(residuals_anfis, 50, 'FaceColor', [0.8 0.2 0.6]);
title('Histogram of ANFIS Prediction Errors', 'FontSize', 14);
xlabel('Error', 'FontSize', 12);
ylabel('Frequency', 'FontSize', 12);
grid on;
figureFileName = 'ANFIS_ErrorDistribution.png';
print(fullfile(figureFolder5, figureFileName), '-dpng', '-r300');
close(gcf);

% Scatter plot of actual vs predicted
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
scatter(testData_ANFIS(:, 3), anfis_output, 15, [0.2 0.6 0.8], 'filled');
xlabel('Actual Control Signal', 'FontSize', 12);
ylabel('ANFIS Predicted Control Signal', 'FontSize', 12);
title('ANFIS Predicted vs. Actual Control Signal', 'FontSize', 14);
hold on;
maxVal = max([testData_ANFIS(:, 3); anfis_output]);
minVal = min([testData_ANFIS(:, 3); anfis_output]);
plot([minVal maxVal], [minVal maxVal], 'r--', 'LineWidth', 2);
hold off;
grid on;
figureFileName = 'ANFIS_ScatterPlot.png';
print(fullfile(figureFolder5, figureFileName), '-dpng', '-r300');
close(gcf);

% Visualize membership functions after training
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1600, 1200]);
subplot(2,1,1);
plotmf(anfisModel, 'input', 1);
title('Trained Membership Functions for Error', 'FontSize', 14);
subplot(2,1,2);
plotmf(anfisModel, 'input', 2);
title('Trained Membership Functions for ErrorRate', 'FontSize', 14);
figureFileName = 'TrainedMembershipFunctions.png';
print(fullfile(figureFolder5, figureFileName), '-dpng', '-r300');
close(gcf);

% Surface Plot of FIS Output
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1600, 1200]);
gensurf(anfisModel);
title('Surface Plot of FIS Output', 'FontSize', 14);
xlabel('Error', 'FontSize', 12);
ylabel('ErrorRate', 'FontSize', 12);
zlabel('Control Signal', 'FontSize', 12);
view(30,30);
figureFileName = 'FIS_SurfacePlot.png';
print(fullfile(figureFolder5, figureFileName), '-dpng', '-r300');
close(gcf);

% Rule Activation Frequency
numRules = numMFs_error * numMFs_errorRate;
ruleActivationFrequency = zeros(numRules,1);
for i = 1:size(testData_ANFIS, 1)
    [~, ~, ruleFiringStrengths] = evalfis(anfisModel, ...
                                          testData_ANFIS(i, 1:2));
    [~, ruleIdx] = max(ruleFiringStrengths);
    ruleActivationFrequency(ruleIdx) = ruleActivationFrequency(ruleIdx) + 1;
end

figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
bar(ruleActivationFrequency, 'FaceColor', [0.2 0.6 0.8]);
xlabel('Rule Index', 'FontSize', 12);
ylabel('Activation Frequency', 'FontSize', 12);
title('Rule Activation Frequency', 'FontSize', 14);
grid on;
figureFileName = 'RuleActivationFrequency.png';
print(fullfile(figureFolder5, figureFileName), '-dpng', '-r300');
close(gcf);

%% ================================