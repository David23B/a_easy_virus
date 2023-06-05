# Simple-Virus

简单的汇编病毒，DOS下运行感染简单的exe文件，输出I'm a virus!

# 文件简介

## AA

测试文件，输出`Hello world!`

## VIRUS

病毒程序，运行后会感染exe文件，输出

```
I'm a virus!
I'm a virus!

```

感染病毒的EXE程序，会在运行时输出`I’m a virus!`，然后再执行正常的功能。

## KILL

杀毒程序，如果程序中有病毒，则会先输出病毒`I'm a virus!`然后继续执行杀毒的程序。

欠缺的功能：输出被感染的文件并提示杀毒完毕

## DEFEND

运行中，若有病毒出现，会直接提示`virus!`，并自动杀毒。

欠缺的功能：只能防一次、没有提示杀毒完成、

# 参考文章

学习过程中主要用到的一些资料

WIN32 汇编写病毒感染PE文件
https://www.daimajiaoliu.com/daima/4796d6c96100402
用汇编写的病毒的原理
https://www.daimajiaoliu.com/daima/47616318d100400
用汇编写的病毒代码
https://blog.csdn.net/longxin5/article/details/83635844
汇编 常用中断列表 文件操作功能
http://biancheng.45soft.com/asm/interrupt-table/531.html
DOS下EXE文件头分析
http://www.asmedu.net/bbs/pasteinfo.jsp?part=1&level=free&kind=1020&qkSg=2&qID=17819

# 代码简介

## VIRUS

病毒代码工作流程：

怎么先执行病毒然后再执行源程序
