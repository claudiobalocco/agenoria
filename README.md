# agenoria
A genetic algorithm for the optimisation of patch antennas

To run Agenoria (after having downloaded lucifer)
This runs on linux and will require Matlab (2019b).

This code is designed to optimise a patch antenna with patch described by a binary array of ones and zeros, describing metal and vaccuum respectively.


Ensure these files are saved in one folder.

Open the function Produce_files.m
This function produces the folders and files required as inputs to lucifer.
Try running this function with inputs (1,1,0) to see an example of the configuration and geometry files (in folder Gen1).
In configuration, variables such as simulation length and cell size can be changed depending on the frequency range intended to optimise over.
The current variables have been chosen for a frequency range of 0.1 THz to 5.0 THz.

Open matlab and run the function Produce_files.m with inputs:
1. The maximum number of generations
2. The generation size, i.e. the number of individuals in each generation 
			(This will be limited by drive space- each individual is ~3.35 GB with default configuration)
3. The number of top perfroming individuals carried forward to the next generation without undergoing genetic reproduction algorithms (Normally 10% of generation size).


Open the bash script runlucifer
Line 18:         lucifer -t 32, refers to lucifer running on 32 threads. Change this to reflect system ability.
Line 6 and 22:   Ensure generation size and individuals carried forward is changed from default if required.

Ensure lucifer is saved as an executable before running.
To convert, use: chmod +x runlucifer

You can now run the bash script runlucifer, use: ./runlucifer
There are analysis files available to help plot the outputs.
