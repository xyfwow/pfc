# Implementation of PFC code 

https://github.com/petenez/pfc

[中文](README.md) | [English](README-en.md)

In order to run this code, MPI and FFTW need to be installed.

The code can be compiled with the command
```
$ mpicc pfc.c -lfftw3_mpi -lfftw3 -lm -Ofast -Wall -o pfc -I /dir fftw/include -L /dir fftw/lib
```
this command will generate a file named 'pfc'

Add global variables
```
$ export LD_LIBRARY_PATH=/dir fftw/lib:$LD_LIBRARY_PATH    
```
run by
```
$ mpirun -np 8 pfc case
```
Here -np 8 indicates that eight CPUs will be used for the computation. The text string "case" is the name for the study case - the input file must be "case.in", numerical output appears in "case.out" and data files begin with "case".

#### Java tool

A tool written in Java for mapping the PFC density fields into atomic coordinates for further atomistic calculations is provided. It's composed of the classes "Coordinator", "Point" and "V". For a 1024-by-1024 case "step2" it can be run as
```
$ java -jar coordinator.jar step2-t\:10000.dat 1024 1024 0.7 0.7 7.3 2.46 step2-t\:10000.xy step2-t\:10000.nh
```
A plotter tool is also provided for visualization of the systems modeled. For a 1024-by-1024 case "step2" it can be run as
```
$ java -jar plotter.jar step2-t:# step2-t:# 1024 1024 0 1000 10000
```
By the java tool, there will be '.xy', '.nh' and '.png' files.

Use awk command to transform the '.xy' file to '.xyz' file in order to open it in Ovito.
```
$ awk '{print $1,1,$2,$3,0}' step2-t\:10000.xy > graphene.xyz
```
Then edit the '.xyz' file to the following form.

```
24231  #the number of atomic

1 1 18.084926676330312 240.3723222620622 0  #Serial, type, positon x, positon y, positon z
2 1 18.949856178256102 241.55177099813596 0
...
```
Open it by Ovito and save to Lammps's data file.

You can also use the Shell file to run the PFC code while the code has been compiled.
