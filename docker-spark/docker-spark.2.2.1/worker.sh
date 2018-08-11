#!/bin/bash

SPARK_MASTER=$1

if [ -z "${SPARK_MASTER}" ]; then
  echo "No master provided, e.g. spark://spark-master.local:7077" >&2
  exit 1
fi

echo "Starting worker, will connect to: ${SPARK_MASTER}"

. "/spark/sbin/spark-config.sh"

. "/spark/bin/load-spark-env.sh"

mkdir -p $SPARK_WORKER_LOG

export SPARK_HOME=/spark

ln -sf /dev/stdout $SPARK_WORKER_LOG/spark-worker.out

/spark/sbin/../bin/spark-class org.apache.spark.deploy.worker.Worker \
    --webui-port $SPARK_WORKER_WEBUI_PORT $SPARK_MASTER >> $SPARK_WORKER_LOG/spark-worker.out