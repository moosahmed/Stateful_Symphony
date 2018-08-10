#!/bin/sh

bash /common.sh

# -- estimate a reasonable executor memory --
total_ram=$(free -g | awk '/^Mem:/{print $2}')
default_executor_ram=$(expr $total_ram - 2)

PYSPARK_DRIVER_PYTHON=ipython2 PYSPARK_DRIVER_PYTHON_OPTS="notebook --port 7778 --notebook-dir $HOME" \
/usr/spark/bin/pyspark \
--py-files $HOME/plushy/dist/plushy-$PLUSHY_VERSION-py2.7.egg \
--packages com.databricks:spark-csv_2.10:1.1.0 \
--conf spark.executor.extraClassPath=$HOME/$JDBC_DRIVER_JAR \
--driver-class-path $HOME/$JDBC_DRIVER_JAR \
--executor-memory ${EXECUTOR_MEMORY:-"${default_executor_ram}G"} \
--jars $HOME/$JDBC_DRIVER_JAR \
--master spark://$SPARK_MASTER_DNS:7077