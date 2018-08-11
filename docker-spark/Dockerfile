FROM debian:jessie
MAINTAINER Moosa Ahmed <moosahmed14@gmail.com>
ENV REFRESHED_AT 2018-08-10 15:46

ENV JAVA_HOME /usr/jdk1.8.0_31
ENV PATH $PATH:$JAVA_HOME/bin
ENV SPARK_VERSION 1.6.0
ENV HADOOP_VERSION 2.4
ENV SPARK_PACKAGE spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION
ENV SPARK_HOME /usr/$SPARK_PACKAGE
ENV PATH $PATH:$SPARK_HOME/bin
WORKDIR /home/dev
ENV HOME /home/dev

RUN apt-get update -y && apt-get install -y \
    curl \
    net-tools \
    unzip \
    python3 \
    ruby \
    git \
    vim-nox \
    tcpdump \
    screen \
    ruby-dev \
    cmake \
    pkg-config \
    libffi-dev \
    libssl-dev \
    libmysqlclient-dev \
    libkrb5-dev \
    python-dev \
    python-psycopg2 \
    python-matplotlib \
    python-lxml \
    python-scipy \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Get most up to date pip
RUN curl -s https://bootstrap.pypa.io/get-pip.py > get-pip.py \
 && python3 get-pip.py

# Java
RUN curl -sL --retry 3 --insecure \
  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
  "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/server-jre-8u181-linux-x64.tar.gz" \
  | gunzip \
  | tar x -C /usr/ \
  && ln -s $JAVA_HOME /usr/java \
  && rm -rf $JAVA_HOME/man

# Spark
RUN curl -sL --retry 3 \
  "http://d3kbcqa49mib13.cloudfront.net/$SPARK_PACKAGE.tgz" \
  | gunzip \
  | tar x -C /usr/ \
  && ln -s $SPARK_HOME /usr/spark

# Hadoop/S3 Dependencies
RUN curl -sL --retry 3 "http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.6.0/hadoop-aws-2.6.0.jar" -o $SPARK_HOME/lib/hadoop-aws-2.6.0.jar \
 && curl -sL --retry 3 "http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.14/aws-java-sdk-1.7.14.jar" -o $SPARK_HOME/lib/aws-java-sdk-1.7.14.jar \
 && curl -sL --retry 3 "http://central.maven.org/maven2/com/google/collections/google-collections/1.0/google-collections-1.0.jar" -o $SPARK_HOME/lib/google-collections-1.0.jar \
 && curl -sL --retry 3 "http://central.maven.org/maven2/joda-time/joda-time/2.8.2/joda-time-2.8.2.jar" -o $SPARK_HOME/lib/joda-time-2.8.2.jar

# Python Dependencies
ADD pip-requirements.txt /home/dev/pip-requirements.txt
RUN pip install -r /home/dev/pip-requirements.txt

# Add master and worker start scripts
COPY start-master.sh start-worker.sh /
RUN chmod a+rx /start-master.sh /start-worker.sh
