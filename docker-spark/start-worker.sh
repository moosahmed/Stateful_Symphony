#!/bin/sh

MASTER=$1

if [ -z "${MASTER}" ]; then
  echo "No master provided, e.g. spark://spark-master.local:7077" >&2
  exit 1
fi

echo "Starting worker, will connect to: ${MASTER}"

# because the hostname only resolves locally
export SPARK_LOCAL_HOSTNAME=$(hostname -i)

spark-class org.apache.spark.deploy.worker.Worker ${MASTER}
