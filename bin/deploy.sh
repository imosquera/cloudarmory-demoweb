#!/bin/bash
cd  `dirname $0`/../
BASEDIR=$(pwd)

kubectl create secret generic web-html \
    --from-file=build/html/ \
    --namespace=${NAMESPACE}

kubectl cre
#$ docker run -d -P --name web -v /src/webapp:/opt/webapp training/webapp python app.py
