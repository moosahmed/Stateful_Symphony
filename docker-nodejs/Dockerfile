FROM node:8

MAINTAINER Moosa Ahmed <moosahmed14@gmail.com>

WORKDIR /home/nodejs/app

# Copying package.json first so changes wont rebuild npm install
COPY package.json .
RUN npm install

COPY . .

EXPOSE 3000