FROM ubuntu:15.04
MAINTAINER michael@faille.io


ENV http_proxy http://172.17.42.1:3128
ENV https_proxy $http_proxy

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get install wget -y
RUN wget http://archive.cloudera.com/cdh5/one-click-install/trusty/amd64/cdh5-repository_1.0_all.deb && \
    dpkg -i /cdh5-repository_1.0_all.deb && \
    apt-get update -y


#Upgrade Ubuntu and install Oracle java 8
RUN apt-get upgrade -y
RUN apt-get install -y  openjdk-8-jre-headless hadoop-hdfs-namenode hadoop-hdfs-datanode impala impala-server impala-shell impala-catalog impala-state-store -y

RUN mkdir -p /data/persistent/dn


# Define working directory.
WORKDIR /data


RUN mkdir /var/run/hdfs-sockets/
RUN chown hdfs.hadoop /var/run/hdfs-sockets/

RUN mkdir -p /data/dn/
RUN chown hdfs.hadoop /data/persistent/dn
VOLUME /data/persistent/dn


# Hadoop Configuration files
# /etc/hadoop/conf/ --> /etc/alternatives/hadoop-conf/ --> /etc/hadoop/conf/ --> /etc/hadoop/conf.empty/
# /etc/impala/conf/ --> /etc/impala/conf.dist
ADD etc/core-site.xml /etc/hadoop/conf/
ADD etc/hdfs-site.xml /etc/hadoop/conf/
ADD etc/core-site.xml /etc/impala/conf/
ADD etc/hdfs-site.xml /etc/impala/conf/

# Various helper scripts
ADD bin/start.sh /data/
ADD bin/start-hdfs.sh /data/
ADD bin/start-impala.sh /data/
ADD bin/start-bash.sh /data/
ADD bin/start-daemon.sh /data/
ADD bin/hdp /usr/bin/hdp

# HDFS PORTS :
# 9000  Name Node IPC
# 50010 Data Node Transfer
# 50020 Data Node IPC
# 50070 Name Node HTTP
# 50075 Data Node HTTP


# IMPALA PORTS :
# 21000 Impala Shell
# 21050 Impala ODBC/JDBC
# 25000 Impala Daemon HTTP
# 25010 Impala State Store HTTP
# 25020 Impala Catalog HTTP

EXPOSE 9000 50010 50020 50070 50075 21000 21050 25000 25010 25020

CMD /start-daemon.sh
