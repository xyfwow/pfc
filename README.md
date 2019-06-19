# 多晶石墨烯的PFC建模方法

https://github.com/petenez/pfc

[中文](README.md) | [English](README-en.md)

在运行PFC代码之前，需要事先安装MPI和FFTW。

通过以下命令来进行PFC的编译
```
$ mpicc pfc.c -lfftw3_mpi -lfftw3 -lm -Ofast -Wall -o pfc -I /dir fftw/include -L /dir fftw/lib
```
该命令会创建一个名为'PFC'的文件夹。

加入全局变量
```
$ export LD_LIBRARY_PATH=/dir fftw/lib:$LD_LIBRARY_PATH    
```
运行
```
$ mpirun -np 8 pfc case
```
'-np 8'表示使用8核进行计算。'case'表示算例的名称，输入文件必须命名为'case.in'，输出的结果文件为'case.out'并且数据文件以'case'开头。

#### Java tool
通过Java工具将PFC密度场映射到原子坐标，以便进行进一步的原子计算。它由'Coordinator'、'Point'和'V'组成。对于1024 * 1024的'step2'，可以这样运行
```
$ java -jar coordinator.jar step2-t\:10000.dat 1024 1024 0.7 0.7 7.3 2.46 step2-t\:10000.xy step2-t\:10000.nh
```
同样可以通过绘图工具来可视化所建模的系统。对于对于1024 * 1024的'step2'，可以这样运行
```
$ java -jar plotter.jar step2-t:# step2-t:# 1024 1024 0 1000 10000
```
通过Java工具，将会得到'.xy'、'.nh'和'.png'文件。

使用awk命令将'.xy'文件转化为'.xyz'文件，使其可以在Ovito中打开。
```
$ awk '{print $1,1,$2,$3,0}' step2-t\:10000.xy > graphene.xyz
```
再编辑'.xyz'文件，得到以下格式（第一行从序号1开始）
```
24231  #the number of atomic

1 1 18.084926676330312 240.3723222620622 0  #Serial, type, positon x, positon y, positon z
2 1 18.949856178256102 241.55177099813596 0
...
```
使用Ovito打开并另存为Lammps数据文件。

可以使用Shell文件来运行PFC代码。
