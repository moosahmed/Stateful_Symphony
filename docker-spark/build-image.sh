#! /bin/bash

tag=latest
docker build -t moosahmed/docker-spark-2.2.1:${tag} .
docker push moosahmed/docker-spark-2.2.1:${tag}
