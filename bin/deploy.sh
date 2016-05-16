#!/bin/bash
cd  `dirname $0`/../
BASEDIR=$(pwd)


echo "REMOVEING SECRETS AND PODS"
kubectl delete secret armory-web-html --namespace=${NAMESPACE}
kubectl delete secret armory-web-nginx-config --namespace=${NAMESPACE}
kubectl delete svc,pod -l stack=web --namespace=${NAMESPACE}


echo "ADDING SECRETS AND PODS"
kubectl create secret generic armory-web-html \
    --from-file=html/ \
    --namespace=${NAMESPACE}

kubectl create secret generic armory-web-nginx-config \
    --from-file=etc/web-nginx.conf \
    --namespace=${NAMESPACE}

kubectl create -f etc/kubernetes/web-pod.yaml --namespace=${NAMESPACE}
kubectl create -f etc/kubernetes/web-svc.yaml --namespace=${NAMESPACE}

#$ docker run -d -P --name web -v /src/webapp:/opt/webapp training/webapp python app.py
