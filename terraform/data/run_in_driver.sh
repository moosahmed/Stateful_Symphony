#!/bin/sh

#apt-utils?
#Failed to find Spark jars directory (/usr/spark-1.6.0-bin-hadoop2.4/assembly/target/scala-2.10/jars).
#You need to build Spark with the target "package" before running this program.

apt-get update && apt-get -y install python3

git clone https://github.com/CCInCharge/campsite-hot-or-not.git
pip install --upgrade pip

cd campsite-hot-or-not/batch
pip install -r requirements.txt


#bash /common.sh
#
## -- estimate a reasonable executor memory --
#total_ram=$(free -g | awk '/^Mem:/{print $2}')
#default_executor_ram=$(expr $total_ram - 2)
#
#PYSPARK_DRIVER_PYTHON=ipython2 PYSPARK_DRIVER_PYTHON_OPTS="notebook --port 7778 --notebook-dir $HOME" \
#/usr/spark/bin/pyspark \
#--py-files $HOME/plushy/dist/plushy-$PLUSHY_VERSION-py2.7.egg \
#--packages com.databricks:spark-csv_2.10:1.1.0 \
#--conf spark.executor.extraClassPath=$HOME/$JDBC_DRIVER_JAR \
#--driver-class-path $HOME/$JDBC_DRIVER_JAR \
#--executor-memory ${EXECUTOR_MEMORY:-"${default_executor_ram}G"} \
#--jars $HOME/$JDBC_DRIVER_JAR \
#--master spark://$SPARK_MASTER_DNS:7077

"git clone https://github.com/CCInCharge/campsite-hot-or-not.git; apt-get update && apt-get -y install python3 && python3 get-pip.py && pip install --upgrade pip && pip install -r campsite-hot-or-not/batch/requirements.txt && /start-worker.sh