# 多晶石墨烯的PFC建模方法

https://github.com/petenez/pfc

[中文](README.md) | [English](README-en.md)

在运行PFC代码之前，需要事先安装MPI和FFTW。

将src和example文件放入同一个文件夹中。

进入src文件夹中，使用以下命令来进行PFC的编译
```
$ mpicc pfc.c -lfftw3_mpi -lfftw3 -lm -Ofast -Wall -o pfc -I /dir fftw/include -L /dir fftw/lib
```
该命令会在src中创建一个名为'pfc'的文件。

加入全局变量
```
$ export LD_LIBRARY_PATH=/dir fftw/lib:$LD_LIBRARY_PATH    
```
下面以example为例，进行建模

文件夹中有两个in文件，两个输入文件演示了一个快速的两阶段过程。'step1.in'应用保守动力学，建立模型并计算晶粒生长，'step2.in'则应用非保守动力学，在step1的基础上将晶界清晰化。详细过程可以参照原文[Parctial considerations](https://github.com/petenez/pfc#practical-considerations)部分。

进入example文件夹中，运行
```
$ mpirun -np 8 ../src/pfc step1
```
'-np 8'表示使用8核进行计算。'../src/pfc'需要指向刚刚生成的'pfc'文件路径位置。'step1'表示算例的名称，输入文件必须命名为'step1.in'，输出的结果文件为'step1.out'并且数据文件以'step1'开头。

比如example文件夹中输入文件为'step1.in'，那么会输出'step1.out'和'step1'开头的数据文件。

对于种子数量和尺寸，通过修改输入文件'step1.in'的内容来修改种子数量和模型尺寸
```
# arrays
#	W     H		(width and height)
A	1024	1024
#	dimensions whose factors are all small primes (like 2 or 3) should be slightly faster

# polycrystalline initialization
#	init	dx	dy	l0	  	p	  	A	  	N	  R
I	1		  0.7	0.7	7.2552	0.25	-0.1	10	2.0
#	... x- and y-discretization, lattice constant [in dimensionless units, ~4pi/sqrt(3)],
#	average density, amplitude of density oscillations,
#	number and radius (in lattice constants) of grains
```
修改A的1、2项和I的7、8项的值来改变尺寸和种子数量和半径。

在step1计算完成后，进行step2的计算
```
$ mpirun -np 8 ../src/pfc step2
```
对于step2需要设置从step1的数据文件继承，因此设置I的类型为2，并读取'step1-t:10000.dat'
```
# arrays
#	W		H		(width and height)
A	1024	1024
#	dimensions whose factors are all small primes (like 2 or 3) should be slightly faster

# random initialization
#	init	p		A		(... noise mean and amplitude)
# I	0		0.25	-0.1

# polycrystalline initialization
#	init	dx	dy	l0		p		A		N	R
# I	1		0.7	0.7	7.2552	0.25	-0.1	10	2.0
#	... x- and y-discretization, lattice constant [in dimensionless units, ~4pi/sqrt(3)],
#	average density, amplitude of density oscillations,
#	number and radius (in lattice constants) of grains

# initial state read from data file
#	init	filename			p		A	(initialization type and data file name, ...)
I	2		step1-t:10000.dat	-0.072	0.1
```

注意：1、'step1.in'和'step2.in'的尺寸需要相同，同时吻合下面Java工具中设定的尺寸；
     2、将W和H设置为1024 * 1024，实际大小约为243 nm。


### Java tool
通过Java工具将PFC密度场映射到原子坐标，以便进行进一步的原子计算。它由'Coordinator'、'Point'和'V'组成。对于1024 * 1024的'step2-t:10000.dat'文件，可以这样运行
```
$ java -jar coordinator.jar step2-t\:10000.dat 1024 1024 0.7 0.7 7.3 2.46 step2-t\:10000.xy step2-t\:10000.nh
```
同样可以通过绘图工具来可视化所建模的系统。对于对于1024 * 1024的'step2'，可以这样运行
```
$ java -jar plotter.jar step2-t:# step2-t:# 1024 1024 0 1000 10000
```
通过Java工具，将会得到'.xy'、'.nh'和'.png'文件。

'coordinator.jar'和'plotter.jar'已放置在example文件夹中。

使用awk命令将'.xy'文件转化为'.xyz'文件，使其可以在Ovito中打开。
```
$ awk '{print $1,1,$2,$3,0}' step2-t\:10000.xy > graphene.xyz
```
此时'graphene.xyz'如下开始
```
0 1 5.848928320551197 241.8612577055367 0
1 1 7.192606595174229 241.3870269606722 0
2 1 5.532769184639267 0.4742314845641932 0
3 1 6.560286841427878 1.4227093664201642 0
4 1 8.220125179139359 242.33550483848785 0
5 1 7.903964561304939 0.948478647288644 0
...
```

编辑'.xyz'文件，得到以下格式（起始写上原子数，第三行从序号1开始）
```
22384  #the number of atomic

1 1 7.192606595174229 241.3870269606722 0   #Serial, type, positon x, positon y, positon z
2 1 5.532769184639267 0.4742314845641932 0
3 1 6.560286841427878 1.4227093664201642 0
4 1 8.220125179139359 242.33550483848785 0
5 1 7.903964561304939 0.948478647288644 0
...
```
使用Ovito打开并另存为Lammps数据文件，就可以进行计算了。
在Ovito中，第一列选择粒子id，第二列为粒子类型，第三到五列为x、y、z方向的位置。

可以使用Shell文件来运行PFC代码。
