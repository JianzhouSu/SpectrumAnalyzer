# Spectrum Analyzer
> Code for spectrum analysis of quartz impedance data acquired from Agilent 4294A and E4980A.



This project is aimed to analyze spectrum of certain electronic part. This code is designed to query frequency sweep data from impedance analyzer and analysis the output. By getting the resonate frequency, bandwidth and quality factor of electronic parts changing by time, we trying to find the relationship between impedance and physical property of electronic components.


## Installation

MATLAB:

pull from GitHub and run.

## Usage example

Measurement and Analysis:

1. Setup parameters of experiment in file “@measurement/parameterSetup.m”

2. Run measurementExample.m MATLAB code to start experiment.

3. During the code running, copy the image to folder of experiment results.

4. Rename the image with experiment’s property. Like “1um coating PBS pos3.jpg”

5. Wait enough sweeps being finished.

6. Use ‘STOP’ button on Figure to stop measurement.

7. Analysis will automatically start and save the results.

8. Measurement and Analysis:

Analysis only:

1. Run "dataAnalyzerExample.m"
2. Select measurement result folder in pop-up massage box
3. Analysis will start and results will be saved.

## Development setup



## Release History



## Meta




## Contributing

