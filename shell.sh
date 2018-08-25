#!/bin/bash
mpirun -np 12 ../src/pfc step1
mpirun -np 12 ../src/pfc step2
java -jar coordinator.jar step2-t\:10000.dat 1024 1024 0.7 0.7 7.3 2.46 step2-t\:10000.xy step2-t\:10000.nh
java -jar plotter.jar step2-t:# step2-t:# 1024 1024 0 1000 10000
awk '{print $1,1,$2,$3,0}' step2-t\:10000.xy > graphene.xyz
