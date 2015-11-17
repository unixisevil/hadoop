from hadoop

run curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.5.1-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
run cd /usr/local && ln -s spark-1.5.1-bin-hadoop2.6 spark
env SPARK_HOME /usr/local/spark
env PATH $PATH:$SPARK_HOME/bin
run mkdir $SPARK_HOME/yarn-remote-client  && \
    cp  $HADOOP_CONF_DIR/core-site.xml   $SPARK_HOME/yarn-remote-client  && \
    cp  $HADOOP_CONF_DIR/yarn-site.xml   $SPARK_HOME/yarn-remote-client

add  bootstrap.sh   /etc/bootstrap.sh

#install R
run rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
run yum -y install R

entrypoint ["/etc/bootstrap.sh"]
