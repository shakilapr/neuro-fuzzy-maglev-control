% ======================================================================
% Data Preparation for Modeling
% Part of: Neuro-Fuzzy Control for Magnetic Levitation Systems
% Author: Shakila Praveen Rathnayake
% Email: shakilabeta@gmail.com
% ======================================================================

% Section 4: Data Preparation for Modeling
% ====================================

% Define figure folder for this section
figureFolder4 = 'figures/Section4';
if ~exist(figureFolder4, 'dir')
    mkdir(figureFolder4);
end

% ANFIS Data Preparation

% Define input and output features for ANFIS
inputs_anfis_table = data(:, {'Error', 'ErrorRate'}); % Use non-normalized data
outputs_anfis_table = data(:, 'ControlSignal');

% Convert tables to arrays
inputs_anfis = table2array(inputs_anfis_table);
outputs_anfis = table2array(outputs_anfis_table);

% Split into training and testing sets
train_ratio_anfis = 0.8;
train_size_anfis = floor(train_ratio_anfis * size(inputs_anfis, 1));

trainData_ANFIS = [inputs_anfis(1:train_size_anfis, :) outputs_anfis(1:train_size_anfis)];
testData_ANFIS = [inputs_anfis(train_size_anfis+1:end, :) outputs_anfis(train_size_anfis+1:end)];

% Validate training and testing split
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
pie([train_size_anfis, size(inputs_anfis, 1) - train_size_anfis], ...
    {'Training Data', 'Testing Data'});
title('ANFIS Training vs Testing Data Split', 'FontSize', 14);
figureFileName = 'ANFIS_TrainTestSplit.png';
print(fullfile(figureFolder4, figureFileName), '-dpng', '-r300');
close(gcf);

% Compare target distributions
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 2400, 1200]);
subplot(1,2,1);
histogram(outputs_anfis(1:train_size_anfis), 50, 'FaceColor', [0.2 0.6 0.8]);
title('ANFIS Training Data Target Distribution', 'FontSize', 14);
xlabel('Control Signal', 'FontSize', 12);
ylabel('Frequency', 'FontSize', 12);

subplot(1,2,2);
histogram(outputs_anfis(train_size_anfis+1:end), 50, 'FaceColor', [0.8 0.2 0.6]);
title('ANFIS Testing Data Target Distribution', 'FontSize', 14);
xlabel('Control Signal', 'FontSize', 12);
ylabel('Frequency', 'FontSize', 12);

figureFileName = 'ANFIS_TargetDistribution_TrainTest.png';
print(fullfile(figureFolder4, figureFileName), '-dpng', '-r300');
close(gcf);

% Save ANFIS prepared data
save('anfis_prepared_data.mat', 'trainData_ANFIS', 'testData_ANFIS', 'train_size_anfis');

%% ======================================