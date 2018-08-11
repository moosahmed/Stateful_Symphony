#! /bin/bash

tag=1.1.0
docker build -t moosahmed/docker-spark:${tag} .
docker push moosahmed/docker-spark:${tag}
