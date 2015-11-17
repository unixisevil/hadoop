#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}
. $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

if [ -z $HADOOP_MASTER ];then
    echo "require env HADOOP_MASTER"
	exit 1
fi
if [ -z "${HADOOP_ROLE}" ]; then
	echo "require env HADOOP_ROLE"
	exit 1
fi

rm -f /tmp/*.pid

sed -i  s/{CSPHERE_MASTER_TO_BE_REPLACED}/$HADOOP_MASTER/  \
        $HADOOP_CONF_DIR/core-site.xml  \
        $HADOOP_CONF_DIR/yarn-site.xml  \
        $SPARK_HOME/yarn-remote-client/core-site.xml   \
	$SPARK_HOME/yarn-remote-client/yarn-site.xml 

touch $HADOOP_CONF_DIR/dfs.hosts.exclude

if [ "${HADOOP_ROLE}" == "slave" ]; then
	rm -f  $HADOOP_CONF_DIR/mapred-site.xml
	rm -f  $HADOOP_CONF_DIR/slaves
	service sshd start
	while true;do
		sleep  100
	done

elif  [ "${HADOOP_ROLE}" = "master" ]; then
	if [ -z $HADOOP_SLAVE ];then
		echo "require env HADOOP_SLAVE"
		exit 1
	fi

    sed -i  s/{CSPHERE_MASTER_TO_BE_REPLACED}/$HADOOP_MASTER/  \
		$HADOOP_CONF_DIR/mapred-site.xml

    
	service sshd start

    echo n | hdfs namenode -format

	# start local svrs first
	start-dfs.sh
	start-yarn.sh

    echo "after  starting  yarn  service"
    hdfs dfsadmin -safemode leave 
    hdfs dfs -put $SPARK_HOME-1.5.1-bin-hadoop2.6/lib /spark  
    echo spark.yarn.jar hdfs:///spark/spark-assembly-1.5.1-hadoop2.6.0.jar > \
         $SPARK_HOME/conf/spark-defaults.conf   
    cp $SPARK_HOME/conf/metrics.properties.template $SPARK_HOME/conf/metrics.properties 
    echo "after config   spark"

    : > $HADOOP_CONF_DIR/slaves
	while :; do
		old=$(cat $HADOOP_CONF_DIR/slaves 2>&-|sort -u)
		new=$(dig +search +short $HADOOP_SLAVE $HADOOP_MASTER 2>&-|sort -u)
		if [ "${new}" !=  "${old}" ];then
			lognew=$(echo -e "${new}" | tr '\n' ',')
			logold=$(echo -e "${old}" | tr '\n' ',')
			echo -e "slave nodes changed,  new: [${lognew}], old: [${logold}]"
			echo -e  "${new}" >  $HADOOP_CONF_DIR/slaves
			start-dfs.sh
			start-yarn.sh
			hdfs dfsadmin -refreshNodes
			yarn rmadmin  -refreshNodes
		fi
		sleep 5s
	done

else
	echo "env HADOOP_ROLE must be slave or master, abort."
	exit 1
fi
