# Methodology

## Complete Design and Implementation Process

This document provides a detailed methodology for the neuro-fuzzy control system for magnetic levitation, based on the actual implementation and research conducted.

---

## 1. Mathematical Model

### 1.1 Free Body Diagram Analysis

The magnetic levitation system consists of a ball suspended by electromagnetic forces. The system dynamics are governed by:

**Electromagnetic Dynamics** (Kirchhoff's Voltage Law):
\[ V = Ri + L\frac{di}{dt} \]

**Mechanical Dynamics**:
\[ m\ddot{x} = mg - F_{em} \]

Where:
- \( V \): Applied voltage
- \( R \): Coil resistance
- \( i \): Current through coil
- \( L \): Inductance (varies with ball position)
- \( m \): Mass of levitated ball
- \( g \): Gravitational acceleration
- \( x \): Ball position
- \( F_{em} \): Electromagnetic force

### 1.2 Nonlinear Model

The electromagnetic force is:
\[ F_{em} = \frac{k_f i^2}{x^2} \]

Inductance varies inversely with position:
\[ L(x) = \frac{L_0}{x} \]

### 1.3 Linearized State-Space Model

The system is linearized around an operating point for control design:

\[ \dot{X} = AX + Bu \]

Where:
- State vector: \( X = [x, \dot{x}, i]^T \)
- System matrices defined for pole placement control

---

## 2. Theoretical Framework

### 2.1 Adaptive Neuro-Fuzzy Inference System (ANFIS)

ANFIS combines:
- **Fuzzy Logic**: Handles uncertainties through linguistic rules
- **Neural Networks**: Provides learning and adaptation capabilities

**Architecture Components:**

1. **Input Layer**: Receives crisp input values (Error, ErrorRate)
2. **Fuzzification Layer**: Applies membership functions
3. **Rule Layer**: Computes firing strength of fuzzy rules
4. **Normalization Layer**: Normalizes firing strengths
5. **Output Layer**: Calculates weighted average to produce control signal

**Learning Algorithm:**
- Hybrid optimization method
- Forward pass: Least squares estimation for consequent parameters
- Backward pass: Backpropagation for premise parameters

### 2.2 Generalized Bell Membership Functions

The membership function is defined as:

\[ \mu(x) = \frac{1}{1 + |\frac{x-c}{a}|^{2b}} \]

Parameters:
- \( a \): Controls width of membership function
- \( b \): Determines slope
- \( c \): Represents center point

These functions provide smooth overlap and adaptability during training.

---

## 3. Data Collection

### 3.1 Simulink Model Setup

A Simulink model of the magnetic levitation system was created with:
- PID controller for baseline control
- Sampling rate: 1000 Hz (sampling time = 0.01 s)
- Operating range: 0.2 to -1.8 (stable region)

### 3.2 Input Signal Types

Thirteen datasets were collected using various input signals:

1. **Step Inputs**: Different amplitudes for steady-state analysis
2. **Sine Waves**: Various frequencies and amplitudes for frequency response
3. **Square Waves**: Testing transient response to abrupt changes
4. **Sawtooth Waves**: Ramp tracking performance
5. **Noise Signals**: System robustness evaluation

### 3.3 Data Structure

Each dataset contains 4000-4001 samples (except output3.csv with 2001 samples).

**Collected Variables:**
- **Error**: Difference between target and actual position
- **ErrorRate**: Rate of change of error
- **ControlSignal**: Control output sent to actuator
- **Feedback**: System response to control
- **GeneratedSignal**: System-generated signal

**Total Data Points**: 50,009 samples across 13 files

---

## 4. Data Processing Pipeline

### 4.1 Data Chunking (Section 1)

**Purpose**: Improve dataset diversity and manageability

**Process:**
1. Each dataset divided into chunks of minimum 500 samples (updated from original 1000)
2. Chunk size calculation:
   - 4000 samples → 4 chunks of 1000 samples
   - 4001 samples → 5 chunks of 801 samples
   - 2001 samples → 3 chunks of 667 samples

**Result**: 59 chunks total from 13 datasets

**Code Parameters:**
```matlab
chunkSize = 500;  % Minimum chunk size
dataFolder = 'data';
outputFileName = 'dataset.csv';
figureFolder1 = 'figures/Section1';
```

### 4.2 Data Randomization (Section 1 continued)

**Purpose**: Eliminate temporal bias and improve model generalization

**Process:**
1. All 59 chunks combined into single list
2. Chunks randomly shuffled
3. Shuffled chunks concatenated
4. Saved as `dataset.csv`

**Observations:**
- Error values cluster around zero (steady-state operation)
- ControlSignal shows saturation at extremes (±3)
- Strong correlations between Error, ErrorRate, and ControlSignal

### 4.3 Data Exploration (Section 2)

**Statistical Analysis:**
- Descriptive statistics (mean, median, std, min, max)
- Distribution analysis for all variables
- Correlation matrix computation

**Visualizations Generated:**
- Histograms for each variable
- Correlation heatmaps
- Scatter plots (pairwise relationships)
- Box plots for outlier detection
- PCA analysis
- Time-series plots

**Key Findings:**
- Error range: [-1, 1]
- ErrorRate range: [-10, 10]
- ControlSignal range: [-3, 3]
- High correlation between control variables

### 4.4 Data Preprocessing (Section 3)

**Missing Data Handling:**
- 0.02% of data points contained missing values
- Linear interpolation used to fill gaps
- No infinite values detected

**Data Clipping:**

Variables clipped to physically valid ranges:
```matlab
Error: [-1, 1]
ErrorRate: [-10, 10]
ControlSignal: [-3, 3]
Feedback: [-3, 0]
GeneratedSignal: [-3, 0]
```

**Validation:**
- Correlation structure preserved after clipping
- Before/after comparison plots generated
- Clipping impact analysis saved to CSV

**Outputs:**
- `ClippingImpactAnalysis.csv`
- Comparison visualizations in `figures/Section3/`

### 4.5 Data Preparation for Modeling (Section 4)

**Variable Selection:**
- **Inputs**: Error, ErrorRate
- **Output**: ControlSignal

**Rationale**: These three variables represent core control dynamics

**Train-Test Split:**
- Training set: 80% of data
- Testing set: 20% of data
- Random splitting ensures diverse representation

**Saved Output:**
- `anfis_prepared_data.mat` containing train/test splits

---

## 5. ANFIS Model Development

### 5.1 Initial FIS Structure Generation (Section 5 - Part 1)

**Grid Partitioning Method:**
- Input space divided into rectangular regions
- Each region defined by membership function combination

**Membership Function Configuration:**

**For Error Input (7 MFs):**
```
NB (Negative Big):     gbellmf([0.2, 2, -0.8])
NM (Negative Medium):  gbellmf([0.1, 2, -0.4])
NS (Negative Small):   gbellmf([0.1, 2, -0.2])
ZE (Zero):             gbellmf([0.1, 2, 0])
PS (Positive Small):   gbellmf([0.1, 2, 0.2])
PM (Positive Medium):  gbellmf([0.1, 2, 0.4])
PB (Positive Big):     gbellmf([0.2, 2, 0.8])
```

**For ErrorRate Input (2 MFs):**
```
N (Negative):  gbellmf([10, 2, -10])
P (Positive):  gbellmf([10, 2, 10])
```

**Total Fuzzy Rules**: 7 × 2 = 14 rules

**Rule Structure:**
```
IF Error is [MF] AND ErrorRate is [MF] THEN ControlSignal is [Linear]
```

**Consequent Function** (Takagi-Sugeno type):
\[ f_i = p_i \cdot Error + q_i \cdot ErrorRate + r_i \]

Where \( p_i, q_i, r_i \) are learned parameters for rule \( i \).

### 5.2 ANFIS Training (Section 5 - Part 2)

**Training Configuration:**
```matlab
numMFs_error = 7;
numMFs_errorRate = 7;  % Note: Code shows 7, actual implementation uses 2
numEpochs = 50;
```

**Hybrid Learning Algorithm:**

1. **Forward Pass:**
   - Input propagates through network
   - Firing strengths computed
   - Least squares estimation updates consequent parameters

2. **Backward Pass:**
   - Error backpropagated
   - Gradient descent updates premise parameters (MF parameters)

**Training Process:**
- 50 epochs of hybrid optimization
- Training data: 80% of dataset
- Validation data: 20% of dataset
- Validation prevents overfitting

**Performance Metrics:**
- Mean Absolute Error (MAE): 0.1927
- Root Mean Squared Error (RMSE): 0.2325
- R-squared (R²): 0.9211

**Outputs:**
- Trained ANFIS model in workspace
- `anfis_initial_[timestamp].fis` - Initial FIS structure
- `anfis_trained_[timestamp].fis` - Trained model
- Training curve plots
- Membership function evolution plots
- FIS surface visualizations

### 5.3 ANFIS Evaluation

**Test Set Performance:**
- Predictions computed on 20% test data
- Actual vs. predicted scatter plots
- Residual analysis
- Error distribution analysis

**Visualizations:**
- Scatter plot: Predicted vs. Actual
- Time-series: Actual vs. Predicted ControlSignal
- Residual error plot
- FIS decision surface (3D)
- Trained membership functions
- Active fuzzy rules

---

## 6. Data Export (Section 6)

**Purpose**: Save processed data for future use

**Exported Files:**
```matlab
dataset_processed.csv  % Preprocessed full dataset
dataset_processed.dat  % Binary format
dataset_training.dat   % Training subset
dataset_test.dat       % Testing subset
```

**Format**: CSV and DAT formats for compatibility with different tools

---

## 7. FIS File Creation (Section 7)

**Purpose**: Generate deployable FIS file for Simulink integration

**Manual FIS Structure:**

```matlab
fis_hybrid = mamfis('Name', 'MagLev');
```

**Input Definitions:**
```matlab
% Error input: [-1, 1]
fis_hybrid = addInput(fis_hybrid, [-1 1], 'Name', 'Error');

% ErrorRate input: [-10, 10]
fis_hybrid = addInput(fis_hybrid, [-10 10], 'Name', 'ErrorRate');
```

**Output Definition:**
```matlab
% ControlSignal output: [-3, 3]
fis_hybrid = addOutput(fis_hybrid, [-3 3], 'Name', 'Output');
```

**Membership Functions:**

For Error (7 MFs):
```matlab
NL: gbellmf([0.2, 2, -1])
N:  gbellmf([0.15, 2, -0.6])
NM: gbellmf([0.1, 2, -0.4])
Z:  gbellmf([0.1, 2, 0])
PM: gbellmf([0.1, 2, 0.4])
P:  gbellmf([0.15, 2, 0.6])
PL: gbellmf([0.2, 2, 1])
```

For ErrorRate (2 MFs):
```matlab
N: gbellmf([10, 2, -10])
P: gbellmf([10, 2, 10])
```

**Fuzzy Rules**: 14 rules automatically generated

**Output**: `models/MagLev.fis`

---

## 8. Real-Time Integration and Testing

### 8.1 Simulink Integration

The trained ANFIS model (`MagLev.fis`) was integrated into the Simulink model for real-time testing.

**Integration Steps:**
1. Fuzzy Logic Controller block added
2. FIS file loaded into block
3. Inputs connected: Error, ErrorRate
4. Output connected: ControlSignal
5. Simulation run with various reference signals

### 8.2 Test Signals and Performance

**Step Response:**
- Initial overshoot observed
- System stabilizes around desired value after ~5 seconds
- Minimal steady-state error
- Control signal shows sharp initial spikes

**Sine Wave Response:**
- System tracks sinusoidal input reasonably well
- Noticeable phase lag between desired and actual
- Continuous oscillations in control signal
- Stable amplitude matching

**Square Wave Response:**
- Challenges with abrupt position changes
- Overshoots and undershoots at transitions
- Sharp control signal spikes
- System eventually stabilizes at each plateau

**Performance Analysis (from Square Wave):**
- **Rise Time**: 18.4 s (both PID and ANFIS)
- **Settling Time**: PID 19.1 s, ANFIS 18.6 s
- **Overshoot**: 33.33% (both controllers)
- **Steady-State Error**: PID -0.2, ANFIS -0.35

---

## 9. Software and Tools

**MATLAB Version**: R2020a or later

**Required Toolboxes:**
- Fuzzy Logic Toolbox
- Statistics and Machine Learning Toolbox

**Optional:**
- Simulink (for real-time testing)
- Deep Learning Toolbox (for extensions)

**Development Environment:**
- MATLAB Editor for script development
- Simulink for system modeling
- MATLAB workspace for data analysis

---

## 10. Key Parameters Summary

**Data Processing:**
```matlab
chunkSize = 500
dataFolder = 'data'
samplingTime = 0.01  % 1000 Hz
trainRatio = 0.80
testRatio = 0.20
```

**ANFIS Configuration:**
```matlab
numMFs_Error = 7
numMFs_ErrorRate = 2  % Actual implementation
totalRules = 14
mfType = 'gbellmf'
fisType = 'sugeno'
```

**Training Parameters:**
```matlab
numEpochs = 50
optimMethod = 'hybrid'  % Backprop + Least Squares
validationData = testSet
```

**Input/Output Ranges:**
```matlab
Error: [-1, 1]
ErrorRate: [-10, 10]
ControlSignal: [-3, 3]
```

---

## 11. Limitations and Considerations

### 11.1 Data Collection Limitations

1. **PID-Generated Data**: Training data derived from PID controller
   - May inherit PID limitations
   - Restricts exploration of alternative strategies

2. **Limited Operating Range**: 0.2 to -1.8
   - Does not cover full system capabilities
   - May not handle extreme conditions

3. **Simulink-Based Collection**:
   - No real-world disturbances
   - No sensor noise
   - Idealized conditions

### 11.2 Model Limitations

1. **ANFIS Performance**:
   - Excellent R² (0.9211) on collected data
   - Performance may degrade in real-world scenarios
   - Sensitive to data quality

2. **Training Data Dependency**:
   - Model quality limited by training data
   - PID behavior embedded in learned patterns

3. **Real-Time Constraints**:
   - Computational requirements for online adaptation
   - Fixed structure after training

---

## 12. File Organization

**Generated Structure:**
```
neuro-fuzzy-maglev-control/
├── data/
│   └── [13 CSV input files]
├── src/
│   ├── 01_data_preparation.m
│   ├── 02_data_exploration.m
│   ├── 03_data_preprocessing.m
│   ├── 04_data_preparation_modeling.m
│   ├── 05_anfis_training.m
│   ├── 06_save_processed_data.m
│   └── 07_create_fis.m
├── models/
│   ├── anfis_initial_[timestamp].fis
│   ├── anfis_trained_[timestamp].fis
│   └── MagLev.fis
├── figures/
│   ├── 01_preparation/  [Data chunk plots]
│   ├── 02_exploration/  [Statistical analysis plots]
│   ├── 03_preprocessing/  [Before/after comparisons]
│   ├── 04_modeling_prep/  [Train/test visualizations]
│   └── 05_anfis_training/  [Training curves, MFs, surfaces]
└── results/
    ├── dataset.csv
    ├── ClippingImpactAnalysis.csv
    ├── anfis_prepared_data.mat
    ├── dataset_processed.csv
    ├── dataset_training.dat
    └── dataset_test.dat
```

---

## 13. Execution Sequence

**Complete workflow execution:**

```matlab
% Step 1: Data Preparation
run('src/01_data_preparation.m');
% Loads CSVs, chunks data, randomizes, saves dataset.csv

% Step 2: Data Exploration
run('src/02_data_exploration.m');
% Statistical analysis and visualization

% Step 3: Data Preprocessing
run('src/03_data_preprocessing.m');
% Clipping, missing value handling

% Step 4: Prepare for Modeling
run('src/04_data_preparation_modeling.m');
% Train/test split

% Step 5: ANFIS Training
run('src/05_anfis_training.m');
% Train model, evaluate performance

% Step 6: Export Data
run('src/06_save_processed_data.m');
% Save processed datasets

% Step 7: Create FIS File
run('src/07_create_fis.m');
% Generate MagLev.fis for deployment
```

**Expected Runtime:**
- Steps 1-4: ~10-15 minutes
- Step 5: ~10-30 minutes (training)
- Steps 6-7: ~1 minute

**Total**: Approximately 20-45 minutes for complete pipeline

---

## 14. Results Summary

**ANFIS Model Performance:**
- MAE: 0.1927
- RMSE: 0.2325
- R²: 0.9211

**Real-Time Control:**
- Comparable rise time to PID (18.4 s)
- Improved settling time (18.6 s vs 19.1 s)
- Increased steady-state error (-0.35 vs -0.2)
- Same overshoot (33.33%)

**Observations:**
- ANFIS successfully captures nonlinear dynamics
- Performance influenced by PID training data
- Stable control across multiple input types
- Phase lag observed in sine tracking
- Sharp spikes in square wave response

---

## 15. Future Improvements

**Data Collection:**
- Collect data from physical system
- Include real-world disturbances
- Expand operating range
- Add sensor noise scenarios

**Model Development:**
- Experiment with different MF counts
- Try alternative learning algorithms
- Implement online adaptation
- Explore ensemble methods

**Real-Time Implementation:**
- Optimize computational efficiency
- Add safety constraints
- Implement fault detection
- Develop model monitoring

---

**Document Status**: Based on actual implementation  
**Date**: December 24, 2024  
**Author**: Shakila Praveen Rathnayake  
**Email**: shakilabeta@gmail.com
