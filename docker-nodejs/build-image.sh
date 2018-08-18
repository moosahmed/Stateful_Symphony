#! /bin/bash

tag=1.0
docker build -t moosahmed/docker-nodejs-8:${tag} .
docker push moosahmed/docker-nodejs-8:${tag}
