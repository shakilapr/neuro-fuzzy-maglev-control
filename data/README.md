# Data Folder

Place your CSV data files here for processing.

## Format

CSV files with 3 columns (no headers):

1. **Error** - Position error
2. **ErrorRate** - Rate of error change  
3. **ControlSignal** - Control output

## Requirements

- Minimum 500 samples per file
- Consistent sampling rate across files
- Value ranges:
  - Error: [-1, 1]
  - ErrorRate: [-10, 10]
  - ControlSignal: [-3, 3]

## Processing

The data preparation script will:
1. Load all CSV files from this directory
2. Chunk into 500-sample segments
3. Randomize chunks
4. Combine into `dataset.csv`

## Collection

Data should be collected from PID-controlled system using various inputs:
- Step responses
- Sine waves
- Square waves  
- Sawtooth waves
