# Neuro-Fuzzy Control for Magnetic Levitation Systems

A MATLAB implementation of an Adaptive Neuro-Fuzzy Inference System (ANFIS) controller for magnetic levitation (MagLev) systems.

![MATLAB](https://img.shields.io/badge/MATLAB-R2020a+-orange.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

## Overview

This project implements a neuro-fuzzy controller using ANFIS to control nonlinear and unstable magnetic levitation systems. The controller uses PID-generated training data to learn system behavior and provides adaptive control.

### Key Features

- **ANFIS Controller**: Adaptive neuro-fuzzy inference system with 14 fuzzy rules
- **Complete Data Pipeline**: From data collection through model evaluation
- **Comprehensive Preprocessing**: Data chunking, randomization, clipping, and cleaning
- **Extensive Visualization**: Over 40 plots across all processing stages
- **Training & Validation**: Hybrid learning with validation monitoring

## System Architecture

The magnetic levitation system uses electromagnetic forces to suspend objects. The ANFIS controller takes Error and ErrorRate as inputs and generates control signals.

**Control Inputs:**
- Error: Position error ∈ [-1, 1]
- ErrorRate: Rate of change of error ∈ [-10, 10]

**Control Output:**
- ControlSignal: Electromagnetic force command ∈ [-3, 3]

## Project Structure

```
neuro-fuzzy-maglev-control/
├── src/                           # MATLAB source code
│   ├── 01_data_preparation.m
│   ├── 02_data_exploration.m
│   ├── 03_data_preprocessing.m
│   ├── 04_data_preparation_modeling.m
│   ├── 05_anfis_training.m
│   ├── 06_save_processed_data.m
│   └── 07_create_fis.m
├── models/                        # Trained FIS models
│   └── MagLev.fis
├── figures/                       # Generated visualizations
│   ├── 01_preparation/
│   ├── 02_exploration/
│   ├── 03_preprocessing/
│   ├── 04_modeling_prep/
│   └── 05_anfis_training/
├── results/                       # Generated datasets
└── docs/                          # Documentation
```

## Requirements

- MATLAB R2020a or later
- Fuzzy Logic Toolbox
- Statistics and Machine Learning Toolbox

## Installation

1. Clone the repository:
```bash
git clone https://github.com/shakilapr/neuro-fuzzy-maglev-control.git
cd neuro-fuzzy-maglev-control
```

2. Add to MATLAB path:
```matlab
addpath(genpath('src'));
```

3. Place CSV data files in the `data/` folder

## Usage

### Complete Pipeline

Run scripts in order:

```matlab
% 1. Prepare and combine data
run('src/01_data_preparation.m');

% 2. Explore data characteristics  
run('src/02_data_exploration.m');

% 3. Preprocess and clean data
run('src/03_data_preprocessing.m');

% 4. Prepare for modeling
run('src/04_data_preparation_modeling.m');

% 5. Train ANFIS model
run('src/05_anfis_training.m');

% 6. Save processed data
run('src/06_save_processed_data.m');

% 7. Create FIS file
run('src/07_create_fis.m');
```

### Configuration

Key parameters in `01_data_preparation.m`:

```matlab
chunkSize = 500;              % Data chunk size
dataFolder = 'data';          % Input folder
numMFs_error = 7;             % Error membership functions
numMFs_errorRate = 7;         % ErrorRate membership functions  
numEpochs = 50;               % Training epochs
```

## Methodology

### 1. Data Collection
Training data collected from PID-controlled Simulink model with various reference signals:
- Step inputs
- Sine waves
- Square waves
- Sawtooth waves

Total: 13 datasets, ~50,000 samples

### 2. Data Processing

**Preparation (Section 1):**
- Loads CSV files from `data/` folder
- Divides into 500-sample chunks
- Randomizes chunks to prevent temporal bias
- Combines into single `dataset.csv`

**Exploration (Section 2):**
- Statistical summaries
- Correlation analysis
- Distribution visualization
- Outlier detection

**Preprocessing (Section 3):**
- Missing value handling
- Data clipping to valid ranges
- Correlation verification

**Modeling Preparation (Section 4):**
- 80/20 train-test split
- Data validation

### 3. ANFIS Architecture

**Structure:**
- **Input Layer**: Error and ErrorRate
- **Fuzzification**: 7 generalized bell MFs for each input
- **Rule Layer**: 14 fuzzy rules (7×2 grid partition)
- **Defuzzification**: Takagi-Sugeno inference
- **Output Layer**: ControlSignal

**Training:**
- Hybrid learning (backpropagation + least squares)
- 50 epochs
- Validation monitoring

## File Descriptions

### Source Code (`src/`)

**01_data_preparation.m**
- Reads all CSV files from data folder
- Chunks data into 500-sample segments
- Randomizes and combines chunks
- Saves to `dataset.csv`
- Generates preparation visualizations

**02_data_exploration.m**
- Statistical analysis and summaries
- Correlation matrices and heatmaps
- Distribution plots
- Box plots for outliers
- PCA analysis
- Time-series visualizations

**03_data_preprocessing.m**
- Removes missing and infinite values
- Clips variables to valid ranges:
  - Error: [-1, 1]
  - ErrorRate: [-10, 10]
  - ControlSignal: [-3, 3]
- Generates before/after comparisons
- Creates clipping impact analysis

**04_data_preparation_modeling.m**
- Splits data 80% training, 20% testing
- Creates training/testing visualizations
- Saves prepared data to MAT file

**05_anfis_training.m**
- Generates initial FIS with grid partitioning
- Trains ANFIS using hybrid method
- Evaluates on test data
- Computes MAE, RMSE, R² metrics
- Saves trained FIS models
- Generates training visualizations

**06_save_processed_data.m**
- Exports processed data to multiple formats:
  - `dataset_processed.csv`
  - `dataset_processed.dat`
  - `dataset_training.dat`
  - `dataset_test.dat`

**07_create_fis.m**
- Creates MagLev FIS structure manually
- Defines 7 membership functions for Error:
  - NL, N, NM, Z, PM, P, PL (generalized bell)
- Defines 2 membership functions for ErrorRate:
  - N, P (generalized bell)
- Configures 14 fuzzy rules
- Saves to `models/MagLev.fis`

## Generated Outputs

### Figures
All visualizations automatically saved with 300 DPI resolution:
- **Section 1**: Data chunk distributions, randomization plots
- **Section 2**: Histograms, correlations, scatter plots, box plots
- **Section 3**: Before/after clipping comparisons
- **Section 4**: Train/test split visualizations
- **Section 5**: Training curves, membership functions, surfaces, predictions

### Data Files
- `dataset.csv` - Combined randomized dataset
- `anfis_prepared_data.mat` - Train/test splits
- `anfis_initial_[timestamp].fis` - Initial FIS structure
- `anfis_trained_[timestamp].fis` - Trained model
- `MagLev.fis` - Final deployable FIS

## Using the Trained Model

```matlab
% Load trained FIS
fis = readfis('models/MagLev.fis');

% Evaluate
error = 0.5;
errorRate = 2.0;
controlSignal = evalfis(fis, [error, errorRate]);
```

## Data Format

Input CSV files (3 columns, no headers):
1. **Error**: Position error
2. **ErrorRate**: Rate of error change
3. **ControlSignal**: Control output

## Troubleshooting

**No CSV files found:**
- Ensure CSV files in `data/` folder
- Check file naming pattern

**Out of memory:**
- Reduce `chunkSize` parameter
- Process fewer files at once

**Toolbox not found:**
- Install Fuzzy Logic Toolbox from MATLAB Add-Ons

## License

This project is licensed under the MIT License.

## Author

**Shakila Praveen Rathnayake**  
Email: shakilabeta@gmail.com  
GitHub: https://github.com/shakilapr

## Citation

```bibtex
@software{rathnayake2024neurofuzzy,
  author = {Rathnayake, Shakila Praveen},
  title = {Neuro-Fuzzy Control for Magnetic Levitation Systems},
  year = {2024},
  url = {https://github.com/shakilapr/neuro-fuzzy-maglev-control}
}
```

## Acknowledgments

- MATLAB Fuzzy Logic Toolbox documentation
- ANFIS architecture based on Jang (1993)
- Takagi-Sugeno fuzzy inference methodology

---

**Project Completed**: December 24, 2024  
**MATLAB Version Tested**: R2020a+
