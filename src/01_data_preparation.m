% ======================================================================
% Data Preparation
% Part of: Neuro-Fuzzy Control for Magnetic Levitation Systems
% Author: Shakila Praveen Rathnayake
% Email: shakilabeta@gmail.com
% ======================================================================

% =====================================
% Combined Code for Data Processing and ANFIS Modeling
% =====================================

% Clear workspace and close all figures
clear; clc; close all;

%% ============================
% Parameters (Adjustable Settings)
% ============================

% Data Processing Parameters
chunkSize = 500; % Reduced size of each chunk (originally 1000)
dataFolder = 'data'; % Folder containing the data files
outputFileName = 'dataset.csv';
figureFolder1 = 'figures/Section1'; % Folder to save Section 1 figures

% ANFIS Parameters
numMFs_error = 7;       % Number of Membership Functions for 'Error'
numMFs_errorRate = 7;   % Number of Membership Functions for 'ErrorRate'
numEpochs = 50;         % Number of training epochs for ANFIS

%% ============================


% Section 1: Data Preparation
% ============================

% Create figures folder for Section 1 if it doesn't exist
if ~exist(figureFolder1, 'dir')
    mkdir(figureFolder1);
end

% Initialize storage for all chunks
allChunks = {}; % Initialize as an empty cell array
chunkCounts = [];
fileSummary = {}; % For summary table

% Get all CSV files in the data folder
filePattern = fullfile(dataFolder, '*.csv');
files = dir(filePattern);

if isempty(files)
    error('No CSV files found in folder "%s".', dataFolder);
end

disp('Reading and processing files...');

for i = 1:length(files)
    fileName = files(i).name;
    fullFileName = fullfile(dataFolder, fileName);
    disp(['Processing file: ', fullFileName]);
    
    % Read the file and only take the first 3 columns
    dataFile = readtable(fullFileName, 'ReadVariableNames', false);
    if size(dataFile, 2) < 3
        error('File "%s" does not contain at least 3 columns.', fileName);
    end
    dataFile = dataFile(:, 1:3);
    
    % Assign variable names
    dataFile.Properties.VariableNames = {'Error', 'ErrorRate', 'ControlSignal'};
    
    % Display first few rows
    disp(['First 5 rows of ', fileName, ':']);
    disp(head(dataFile, 5));
    
    % Visualize data in the file with improved resolution
    figure('Visible', 'off');
    set(gcf, 'Position', [100, 100, 1200, 800]); % Set figure size for better resolution
    subplot(3,1,1); 
    plot(dataFile.Error, 'LineWidth', 1.5); 
    title('Error Over Time', 'FontSize', 14); 
    ylabel('Error', 'FontSize', 12);

    subplot(3,1,2); 
    plot(dataFile.ErrorRate, 'LineWidth', 1.5); 
    title('Error Rate Over Time', 'FontSize', 14); 
    ylabel('Error Rate', 'FontSize', 12);

    subplot(3,1,3); 
    plot(dataFile.ControlSignal, 'LineWidth', 1.5); 
    title('Control Signal Over Time', 'FontSize', 14); 
    ylabel('Control Signal', 'FontSize', 12);
    
    xlabel('Time Steps', 'FontSize', 12);
    
    % Save the figure with improved resolution
    [~, name, ~] = fileparts(fileName);
    figureFileName = sprintf('DataVisualization_%s.png', name);
    print(fullfile(figureFolder1, figureFileName), '-dpng', '-r300'); % Save at 300 DPI
    close(gcf);
    
    % Get the number of rows in the file
    numRows = size(dataFile, 1);
    
    % Calculate the number of chunks needed
    numChunks = ceil(numRows / chunkSize);
    
    % Recalculate rows per chunk to ensure all chunks are ~equal size
    rowsPerChunk = ceil(numRows / numChunks);
    
    % Split into chunks
    for j = 1:numChunks
        startIdx = (j-1) * rowsPerChunk + 1;
        endIdx = min(j * rowsPerChunk, numRows);
        chunk = dataFile(startIdx:endIdx, :);
        allChunks{end+1,1} = chunk; %#ok<AGROW>
    end
    chunkCounts = [chunkCounts; numChunks];
    fileSummary = [fileSummary; {fileName, numRows, numChunks, rowsPerChunk}];
end

disp('Splitting into chunks completed.');

% Plot chunk size distribution with improved resolution
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
bar(chunkCounts, 'FaceColor', [0.2 0.6 0.5]);
title('Number of Chunks per File', 'FontSize', 14);
xlabel('File Index', 'FontSize', 12);
ylabel('Number of Chunks', 'FontSize', 12);
grid on;
figureFileName = 'ChunkSizeDistribution.png';
print(fullfile(figureFolder1, figureFileName), '-dpng', '-r300');
close(gcf);

% Shuffle the chunks randomly
disp('Randomizing chunks...');
originalIndices = 1:length(allChunks);
shuffledIndices = randperm(length(allChunks));
randomizedChunks = allChunks(shuffledIndices);

% Visualize randomization with improved resolution
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1600, 1200]);
subplot(2,1,1);
stem(originalIndices, 'filled', 'MarkerSize', 2);
title('Original Chunk Indices', 'FontSize', 14);
xlabel('Chunk Index', 'FontSize', 12);
ylabel('Value', 'FontSize', 12);

subplot(2,1,2);
stem(shuffledIndices, 'filled', 'MarkerSize', 2);
title('Shuffled Chunk Indices', 'FontSize', 14);
xlabel('Shuffled Index', 'FontSize', 12);
ylabel('Original Chunk Index', 'FontSize', 12);
figureFileName = 'ChunkRandomization.png';
print(fullfile(figureFolder1, figureFileName), '-dpng', '-r300');
close(gcf);

% Combine randomized chunks into a single dataset
disp('Combining chunks...');
finalDataset = vertcat(randomizedChunks{:});

% Save the combined dataset as 'dataset.csv' in the default folder
disp(['Saving combined dataset to "', outputFileName, '"...']);
writetable(finalDataset, outputFileName);

disp('Data preparation completed. The combined dataset is saved as "dataset.csv".');

% Additional plot: Randomly combined dataset with improved resolution
figure('Visible', 'off');
set(gcf, 'Position', [100, 100, 1200, 800]);
subplot(3,1,1); 
plot(finalDataset.Error, 'LineWidth', 1.5); 
title('Error Over Time', 'FontSize', 14); 
ylabel('Error', 'FontSize', 12);

subplot(3,1,2); 
plot(finalDataset.ErrorRate, 'LineWidth', 1.5); 
title('Error Rate Over Time', 'FontSize', 14); 
ylabel('Error Rate', 'FontSize', 12);

subplot(3,1,3); 
plot(finalDataset.ControlSignal, 'LineWidth', 1.5); 
title('Control Signal Over Time', 'FontSize', 14); 
ylabel('Control Signal', 'FontSize', 12);

xlabel('Data Points', 'FontSize', 12);
figureFileName = 'RandomizedCombinedDataset.png';
print(fullfile(figureFolder1, figureFileName), '-dpng', '-r300');
close(gcf);

% Summary table of files
fileSummaryTable = cell2table(fileSummary, 'VariableNames', {'FileName', 'NumRows', 'NumChunks', 'RowsPerChunk'});
disp('Summary of files and chunks:');
disp(fileSummaryTable);

% Save summary table
writetable(fileSummaryTable, fullfile(figureFolder1, 'FileSummary.csv'));

%% ===============================