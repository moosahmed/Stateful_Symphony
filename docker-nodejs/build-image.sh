#! /bin/bash

tag=latest
docker build -t moosahmed/docker-nodejs-8:${tag} .
docker push moosahmed/docker-nodejs-8:${tag}
