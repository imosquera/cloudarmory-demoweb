#!/bin/bash -x
cd  `dirname $0`/../
BASEDIR=$(pwd)

updateKubeConfig() {
  echo "REMOVEING SECRETS AND PODS"
  kubectl delete secret armory-web-html --namespace=${NAMESPACE}
  kubectl delete secret armory-web-nginx-config --namespace=${NAMESPACE}
  kubectl delete svc,pod -l stack=web --namespace=${NAMESPACE}


  echo "ADDING SECRETS AND PODS"
  kubectl create secret generic armory-web-html \
      --from-file=html/ \
      --namespace=${NAMESPACE}

  kubectl create secret generic armory-web-nginx-config \
      --from-file=etc/web-ng}inx.conf \
      --namespace=${NAMESPACE}

  kubectl create -f etc/kubernetes/web-pod.yaml --namespace=${NAMESPACE}
  kubectl create -f etc/kubernetes/web-svc.yaml --namespace=${NAMESPACE}
}

updateDNS() {
  while [ "$external_ip" == "" ]
  do
    echo "waiting for external ip to become available..."
    external_ip=$(kubectl get services armory-web-nginx-service -o jsonpath='{.status.loadBalancer.ingress[*].ip}')
    sleep 1
  done

  gcloud dns record-sets -z=cloudarmory transaction add --name="demo.cloudarmory.io." --type=A --ttl=300 "$external_ip"
}
#$ docker run -d -P --name web -v /src/webapp:/opt/webapp training/webapp python app.py
