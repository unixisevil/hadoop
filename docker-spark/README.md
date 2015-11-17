Apache Spark on Docker
==========

这个镜像基于hadoop on docker.

## 镜像构建
```
docker build --rm -t  nicescale/spark .
```

## 启动容器

使用csphere 自带应用模板功能, 创建一个应用模板, 比如叫做hadoop, 在此模板添加两个服务分别为master,slave.
master 服务启动容器参数,创建三个环境变量: HADOOP_ROLE=master,  HADOOP_MASTER=master, HADOOP_SLAVE=slave
slave 服务启动容器参数,创建三个环境变量: HADOOP_ROLE=slave,  HADOOP_MASTER=master, HADOOP_SLAVE=slave
环境变量 HADOOP_MASTER, HADOOP_SLAVE 的取值可以更改,用以标识master,slave.

待hadoop相关进程启动后, 可以访问master 服务的8088 端口, 进入yarn 资源管理器面板.

## Versions
```
Hadoop 2.7.0 and Apache Spark v1.5.1 on Centos 
```

## Testing

yarn上有yarn-client, yarn-cluster 两种启动spark 方式.

### YARN-client mode

In yarn-client mode, the driver runs in the client process, and the application master is only used for requesting resources from YARN.

```
# run the spark shell
spark-shell \
--master yarn-client \
--driver-memory 1g \
--executor-memory 1g \
--executor-cores 1

# execute the the following command which should return 1000
scala> sc.parallelize(1 to 1000).count()
```
### YARN-cluster mode

In yarn-cluster mode, the Spark driver runs inside an application master process which is managed by YARN on the cluster, and the client can go away after initiating the application.

计算 Pi (yarn-cluster mode):

```
# 执行下面命令, 会在 $HADOOP_PREFIX/logs/userlogs/appid 下日志 "Pi is roughly 3.1418"
# note you must specify --files argument in cluster mode to enable metrics
spark-submit \
--class org.apache.spark.examples.SparkPi \
--files $SPARK_HOME/conf/metrics.properties \
--master yarn-cluster \
--driver-memory 1g \
--executor-memory 1g \
--executor-cores 1 \
$SPARK_HOME/lib/spark-examples-1.5.1-hadoop2.6.0.jar
```

计算 Pi (yarn-client mode):

```
# 执行下面命令,会在屏幕上打印 "Pi is roughly 3.1418"
spark-submit \
--class org.apache.spark.examples.SparkPi \
--master yarn-client \
--driver-memory 1g \
--executor-memory 1g \
--executor-cores 1 \
$SPARK_HOME/lib/spark-examples-1.5.1-hadoop2.6.0.jar
```
