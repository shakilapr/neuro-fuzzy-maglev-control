% ======================================================================
% Save Processed Data
% Part of: Neuro-Fuzzy Control for Magnetic Levitation Systems
% Author: Shakila Praveen Rathnayake
% Email: shakilabeta@gmail.com
% ======================================================================

% Section 6: Save Processed Data
% ================================
% Here we save the processed dataset in multiple formats as requested.

% 'data' holds the fully preprocessed dataset (after Section 3).
% 'trainData_ANFIS' and 'testData_ANFIS' come from Section 4.

disp('Saving processed data in multiple formats...');

% 1) Save the processed dataset to CSV (retains headers)
writetable(data, 'dataset_processed.csv');

% 2) Save the processed dataset to DAT (numeric array only)
writematrix(table2array(data), 'dataset_processed.dat');

% 3) Save training data to DAT
writematrix(trainData_ANFIS, 'dataset_training.dat');

% 4) Save testing data to DAT
writematrix(testData_ANFIS, 'dataset_test.dat');

disp('All processed data files have been saved successfully:');
disp('- dataset_processed.csv');
disp('- dataset_processed.dat');
disp('- dataset_training.dat');
disp('- dataset_test.dat');
