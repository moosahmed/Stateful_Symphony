# docker-spark
This is adapted from github.com/guang/docker-spark 's docker setup for deploying spark (tailored towards pyspark) on kubernetes, based on other peeps' [existing](https://github.com/mattf/openshift-spark) [work](https://github.com/gettyimages/docker-spark)

Notice that things like port mappings are delegated to the orchestration tool.
As a result, the template for master pod should look something like
```
{
  "kind": "Pod",
  "apiVersion": "v1",
  "metadata": {
    "name": "{{USER_NAME}}-spark",
    "labels": {
      "name": "{{USER_NAME}}-spark-master",
      "owner": "{{USER_NAME}}"
    }
  },
  "spec": {
    "containers": [
      {
        "name": "{{USER_NAME}}-spark",
        "image": "guangyang/docker-spark:latest",
        "command": ["/bin/bash", "-c", "/start-master.sh {{USER_NAME}}-spark"],
        "env": [
          {
            "name": "SPARK_MASTER_PORT",
            "value": "7077"
          },
          {
            "name": "SPARK_MASTER_WEBUI_PORT",
            "value": "8080"
          }
        ],
        "ports": [
          {
            "containerPort": 7077,
            "protocol": "TCP"
          },
          {
            "containerPort": 8080,
            "protocol": "TCP"
          }
        ]
      }
    ]
  }
}
```

while the worker replication controller should look something like
```
{
  "kind": "ReplicationController",
  "apiVersion": "v1",
  "metadata": {
    "name": "{{USER_NAME}}-spark-worker-controller",
    "labels": {
      "name": "{{USER_NAME}}-spark-worker",
          "owner": "{{USER_NAME}}"
    }
  },
  "spec": {
    "replicas": 2,
    "selector": {
      "name": "{{USER_NAME}}-spark-worker"
    },
    "template": {
      "metadata": {
        "labels": {
          "name": "{{USER_NAME}}-spark-worker",
          "uses": "{{USER_NAME}}-spark",
          "owner": "{{USER_NAME}}"
        }
      },
      "spec": {
        "containers": [
          {
            "name": "{{USER_NAME}}-spark-worker",
            "image": "guangyang/docker-spark:latest",
            "command": ["/bin/bash", "-c", "/start-worker.sh spark://{{USER_NAME}}-spark:7077"],
            "ports": [
              {
                "hostPort": 8888,
                "containerPort": 8888
              }
            ]
          }
        ]
      }
    }
  }
}
```
where `{{USER_NAME}}` should be replaced with a dns-friendly name of your choosing


Love to hear feedbacks! To get started with spark on kubernetes, check out [kube's doc on spark](http://kubernetes.io/v1.1/examples/spark/README.html)
