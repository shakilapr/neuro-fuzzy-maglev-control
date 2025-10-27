% =====================================
% Section 4: Data Preparation for Modeling
% =====================================

% Define figure folder for this section
figureFolder = 'figures/Section4';
if ~exist(figureFolder, 'dir')
    mkdir(figureFolder);
end

% 4.1 LSTM Data Preparation

% Define input and output features for LSTM
input_features_lstm = {'Error', 'ErrorRate', 'Feedback', 'GeneratedSignal'};
target_feature_lstm = 'ControlSignal';

% Extract inputs and target
data_inputs_lstm = data{:, input_features_lstm};
data_target_lstm = data{:, target_feature_lstm};

% Define sequence length
sequence_length = 10;
num_samples_lstm = size(data_inputs_lstm, 1) - sequence_length;

% Initialize sequences and targets
X_seq_lstm = zeros(num_samples_lstm, sequence_length, length(input_features_lstm));
y_seq_lstm = zeros(num_samples_lstm, 1);

% Create sequences
for i = 1:num_samples_lstm
    X_seq_lstm(i, :, :) = data_inputs_lstm(i:i+sequence_length-1, :);
    y_seq_lstm(i) = data_target_lstm(i+sequence_length);
end

% Split into training and testing sets
train_ratio = 0.8;
train_size_lstm = floor(train_ratio * num_samples_lstm);

X_train_lstm = X_seq_lstm(1:train_size_lstm, :, :);
y_train_lstm = y_seq_lstm(1:train_size_lstm);
X_test_lstm = X_seq_lstm(train_size_lstm+1:end, :, :);
y_test_lstm = y_seq_lstm(train_size_lstm+1:end);

% Convert to cell arrays for LSTM input
trainInputsCell_lstm = cell(size(X_train_lstm, 1), 1);
for i = 1:size(X_train_lstm, 1)
    trainInputsCell_lstm{i} = squeeze(X_train_lstm(i, :, :))';
end

testInputsCell_lstm = cell(size(X_test_lstm, 1), 1);
for i = 1:size(X_test_lstm, 1)
    testInputsCell_lstm{i} = squeeze(X_test_lstm(i, :, :))';
end

% Validate training and testing split
figure;
pie([train_size_lstm, num_samples_lstm - train_size_lstm], {'Training Data', 'Testing Data'});
title('LSTM Training vs Testing Data Split');
figureFileName = 'LSTM_TrainTestSplit.png';
saveas(gcf, fullfile(figureFolder, figureFileName));
close(gcf);

% Compare target distributions
figure;
subplot(1,2,1);
histogram(y_train_lstm, 50);
title('LSTM Training Data Target Distribution');
xlabel('Control Signal');
ylabel('Frequency');

subplot(1,2,2);
histogram(y_test_lstm, 50);
title('LSTM Testing Data Target Distribution');
xlabel('Control Signal');
ylabel('Frequency');

figureFileName = 'LSTM_TargetDistribution_TrainTest.png';
saveas(gcf, fullfile(figureFolder, figureFileName));
close(gcf);

% Visualize sample sequences
figure;
for i = 1:3 % Plot first 3 sequences
    seqData = squeeze(X_train_lstm(i, :, :));
    for j = 1:length(input_features_lstm)
        subplot(length(input_features_lstm),1,j);
        plot(seqData(:, j));
        title(sprintf('Sequence %d - %s', i, input_features_lstm{j}));
        ylabel(input_features_lstm{j});
    end
    xlabel('Time Steps');
    figureFileName = sprintf('LSTM_SequenceVisualization_%d.png', i);
    saveas(gcf, fullfile(figureFolder, figureFileName));
    close(gcf);
end

% Save LSTM prepared data
save('lstm_prepared_data.mat', 'trainInputsCell_lstm', 'y_train_lstm', 'testInputsCell_lstm', 'y_test_lstm', 'train_size_lstm', 'sequence_length', 'input_features_lstm');

% 4.2 ANFIS Data Preparation

% Define input and output features for ANFIS
inputs_anfis = [data.Error, data.ErrorRate]; % Use non-normalized data
outputs_anfis = data.ControlSignal;

% Split into training and testing sets
train_ratio_anfis = 0.8;
train_size_anfis = floor(train_ratio_anfis * size(inputs_anfis, 1));

trainData_ANFIS = [inputs_anfis(1:train_size_anfis, :) outputs_anfis(1:train_size_anfis)];
testData_ANFIS = [inputs_anfis(train_size_anfis+1:end, :) outputs_anfis(train_size_anfis+1:end)];

% Validate training and testing split
figure;
pie([train_size_anfis, size(inputs_anfis, 1) - train_size_anfis], {'Training Data', 'Testing Data'});
title('ANFIS Training vs Testing Data Split');
figureFileName = 'ANFIS_TrainTestSplit.png';
saveas(gcf, fullfile(figureFolder, figureFileName));
close(gcf);

% Compare target distributions
figure;
subplot(1,2,1);
histogram(outputs_anfis(1:train_size_anfis), 50);
title('ANFIS Training Data Target Distribution');
xlabel('Control Signal');
ylabel('Frequency');

subplot(1,2,2);
histogram(outputs_anfis(train_size_anfis+1:end), 50);
title('ANFIS Testing Data Target Distribution');
xlabel('Control Signal');
ylabel('Frequency');

figureFileName = 'ANFIS_TargetDistribution_TrainTest.png';
saveas(gcf, fullfile(figureFolder, figureFileName));
close(gcf);

% Save ANFIS prepared data
save('anfis_prepared_data.mat', 'trainData_ANFIS', 'testData_ANFIS', 'train_size_anfis');