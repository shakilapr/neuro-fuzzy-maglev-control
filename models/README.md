# Models Directory

## Overview
This directory stores the ANFIS models (FIS files) generated during training.

## Generated Models

### anfis_initial.fis
- **Created by**: `05_anfis_training.m`
- **Description**: Initial Fuzzy Inference System structure before training
- **Parameters**:
  - Input 1 (Error): 7 generalized bell membership functions
  - Input 2 (ErrorRate): 2 generalized bell membership functions
  - Output (ControlSignal): 14 linear output functions
- **Use**: Reference for initial configuration, comparison with trained model

### anfis_trained.fis
- **Created by**: `05_anfis_training.m`
- **Description**: Fully trained ANFIS model after 50 epochs
- **Training Method**: Hybrid optimization (backpropagation + least squares)
- **Use**: Primary model for control signal prediction

## Loading Models

To load and use the trained model:

```matlab
% Load the trained FIS
trained_fis = readfis('models/anfis_trained.fis');

% Make predictions
test_inputs = [error_value, error_rate_value];
predicted_output = evalfis(trained_fis, test_inputs);

% Visualize membership functions
figure;
subplot(2,1,1);
plotmf(trained_fis, 'input', 1);
title('Error Membership Functions');

subplot(2,1,2);
plotmf(trained_fis, 'input', 2);
title('ErrorRate Membership Functions');
```

## Model Performance

The trained model should achieve:
- MAE < 0.05
- RMSE < 0.08
- R² > 0.95

Run `05_anfis_training.m` to see actual metrics for your data.

## Visualization

Use MATLAB's FIS tools to visualize:
```matlab
% Surface plot
gensurf(trained_fis);

% Rule viewer
ruleview(trained_fis);

% FIS structure
plotfis(trained_fis);
```
