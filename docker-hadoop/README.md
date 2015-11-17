#Apache Hadoop 2.7.0 Docker image


# 镜像构建

```
docker build  -t nicescale/hadoop  .
```

# 启动容器

使用csphere 自带应用模板功能, 创建一个应用模板, 比如叫做hadoop, 在此模板添加两个服务分别为master,slave.
master 服务启动容器参数,创建三个环境变量: HADOOP_ROLE=master,  HADOOP_MASTER=master, HADOOP_SLAVE=slave
slave 服务启动容器参数,创建三个环境变量: HADOOP_ROLE=slave,  HADOOP_MASTER=master, HADOOP_SLAVE=slave
环境变量 HADOOP_MASTER, HADOOP_SLAVE 的取值可以更改,用以标识master,slave.

待hadoop相关进程启动后, 可以访问master 服务的8088 端口, 进入yarn 资源管理器面板.

## 测试

运行自带mapreduce job 例子:

```
cd $HADOOP_PREFIX
hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.0.jar pi 30 100

```
