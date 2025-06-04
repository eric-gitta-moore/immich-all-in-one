# tc-docker

内核 netem 用队列模拟的，这个看 ctop、nethogs、iftop 会有点扯淡
- 再限速容器里面里面一直都是 TX 30mbit/s
- 但是再 minio 里面接收发现是一下有流量一下没有
- 如果仿真模拟测试一下还是用虚拟机限速模拟，指标就正常了