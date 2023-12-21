



# ECE464/564 Final Project
This document contains the instructions and commands to setup ECE464/564 final project directory. In the folder tree of this project, several ```Makefile```s are used to 

## Overview
- [Unzip](#unzip)
- [Start Designing](#start-designing)
- [Synthesis](#synthesis)
- [Submission](#submission)
- [Appendix](#appendix)

## Unzip
Once you have placed ```project2022.zip``` at desired directory. Launch a terminal at that directory and use the following command to unzip.
```bash
unzip project2023.zip
```
You should find the unzipped project folder ```projectFall2023/```

## Start Designing
### Setup script

```projectFall2023/setup.sh``` is provided to load Modelsim and Synopsys

To source the script:
```bash
source setup.sh
```
This script also enables you to <kbd>Tab</kbd> complete ```make``` commands

### Project description

The document is located in ```projectFall2023/project_specification/```

### Where to put your design

A Verilog file ```projectFall2023/rtl/dut.v``` is provided with all the ports already connected to the test fixture

### How to compile your design

To compile your design

Change directory to ```projectFall2023/run/``` 

```bash
make build
```

All the .v files in ```projectFall2023/rtl/``` will be compiled with this command.

### How to run your design

#### For ECE464
Run with Modelsim UI 464:
```bash
make debug-test[1/2] # debug-test1
```
#### For ECE564
Run with Modelsim UI 564:
```bash
make debug-test[1/2/3/4] # debug-test3
```

#### Sorthand Debug command
```
make debug TEST=1/2/3/4
```

### How to compile and run the golden model
In case you still have doubt in how to interface with the test fixture, a golden model is provided for your reference.

To compile the golden model, change directory to ```projectFall2023/run/```

```bash
make build-golden
```
The run commands are the same ```make debug-test[1/2]``` for 464 project and ```debug-test[1/2/3/4]``` for 564 project

Make sure to recompile your own design with the following command when you wish to switch back
```bash
make build
```
The golden model is only intended to give you an example of how to interface with the SRAMs
and is not synthesizable by design. 


### Evaluation Testing
To evaluate you design headless/no-gui, change directory to ```projectFall2023/run/```
```
make eval-[464/564]
```
This will produce a set of log files that will highlight the results of your design. This should only be ran as a final step before Synthesis

All log files are in the following directory ```projectFall2023/run/logs```

Each tests' log is in the corresponding ditectory ```test1/test2/test3/test4```

All tests resutls are in the results log file ```projectFall2023/run/results/finial_result.log```

## Synthesis

Once you have a functional design, you can synthesize it in ```projectFall2023/synthesis/```

### Synthesis Command
The following command will synthesize your design with a default clock period of 10 ns
```bash
make all
```
### Clock Period

To run synthesis with a different clock period
```bash
make all CLOCK_PER=<YOUR_CLOCK_PERIOD>
```
For example, the following command will set the target clock period to 4 ns.

```bash
make all CLOCK_PER=4
```

### Synthesis Reports
You can find your timing report and area report in ```projectFall2023/synthesis/reports/```

## Submission
### Project Report

Place your report file in ```projectFall2023/project_report/```

### Zip for submission

To generate the zip file for submission

change directory to ```projectFall2023/``` and use the following command

```bash
make zip MY_UID=<your_unity_id>
```

For example, if your unity ID is "jdoe12", you should enter the following command when generating the .zip file for submission.
```bash
make zip MY_UID=jdoe12
```
You will find the generated zip file in ```projectFall2023/``` 

### Check before you submit

Please check your zip file and make sure all the files are present for submission

It's recommended to download a fresh copy of the project directory and place the zip file in the root of the copy

The following command will restore the submission file to the directory
```bash
make unzip MY_UID=<your_unity_id>
```
You could then proceed to compile, run and synthesis your design and check if you misplaced any file that did not get included in the zip file.

### Submit your files
Upload the generated zip file to Moodle page


## Appendix

### Directory Rundown

You will find the following directories in ```projectFall2023/```

* ```inputs/input[1/2/3/4]``` 
  * Contains the .dat files for the input/gate SRAMs used in 464/564 project
* ```outputs/input[1/2/3/4]``` 
  * Contains the .dat files for the output SRAMs used in 464/564 project
* ```golden_model/``` 
  * Contains the reference behavior model for the project
  * The content in this directory is compiled instead when executing ```make build-golden``` in ```projectFall2023/run/```
* ```project_report/```
  * Place your project report here before running ```make zip MY_UID=<your_unity_id>``` command
* ```project_specification/```
  * Contains the project specification document
* ```rtl/```
  * All .v files will be compiled when executing ```make vlog-v``` in ```projectFall2023/run/```
  * A template ```dut.v``` that interfaces with the test fixture is provided
* ```run/```
  * Contains the ```Makefile``` to compile and simulate the design
* ```scripts/```
  * Contains the python script that generates a random input/output
* ```synthesis/```
  * The directory you will use to synthesize your design
  * Synthesis reports will be exported to ```synthesis/reports/```
  * Synthesized netlist will be generated to ```synthesis/gl/```
* ```testbench/```
  * Contains the test fixture of the project


# Quantum-Computer-Emulator-
# Quantum-Computer-Emulator-
