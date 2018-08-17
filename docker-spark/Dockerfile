FROM bde2020/spark-base:2.2.1-hadoop2.7

MAINTAINER Moosa Ahmed <moosahmed14@gmail.com>

ENV SPARK_MASTER_LOG /spark/logs
ENV SPARK_WORKER_LOG /spark/logs
ENV SPARK_HOME /spark
ENV PYSPARK_PYTHON /usr/bin/python3

# Get most up to date pip
RUN curl -s https://bootstrap.pypa.io/get-pip.py > get-pip.py \
 && python3 get-pip.py

ADD pip-requirements.txt /home/dev/pip-requirements.txt
RUN pip install -r /home/dev/pip-requirements.txt

COPY master.sh /
RUN chmod a+rx /master.sh

COPY worker.sh /
RUN chmod a+rx /worker.sh

ADD spark-defaults.conf /spark/conf/

RUN . "/spark/sbin/spark-config.sh"
RUN . "/spark/bin/load-spark-env.sh"
