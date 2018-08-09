echo "$(hostname -i) $SPARK_USER_NAME" >> /etc/hosts
export SPARK_MASTER_HOST=$1

# run the spark master directly (instead of sbin/start-master.sh) to
# link master and container lifecycle
exec spark-class org.apache.spark.deploy.master.Master