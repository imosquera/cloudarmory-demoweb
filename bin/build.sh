#!/bin/bash

cd  `dirname $0`/../
BASE_DIR=$(pwd)

docker build -t cloudarmory/demoweb  -f etc/Dockerfile .
docker tag cloudarmory/demoweb gcr.io/cloud-armory/demoweb
