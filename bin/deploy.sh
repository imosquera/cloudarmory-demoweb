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
      --from-file=etc/web-nginx.conf \
      --namespace=${NAMESPACE}

  kubectl create -f etc/kubernetes/web-pod.yaml --namespace=${NAMESPACE}
  kubectl create -f etc/kubernetes/web-svc.yaml --namespace=${NAMESPACE}
}

updateDNS() {
  echo "waiting for external ip to become available..."
  while [ "$external_ip" == "" ]
  do
    echo -n ". "
    external_ip=$(kubectl get services armory-web-nginx-service -o jsonpath='{.status.loadBalancer.ingress[*].ip}')
    sleep 1
  done
  echo " DONE"

  # kill any existing dns record
  demo_exists=$(gcloud dns record-sets list --zone cloudarmory | grep demo.cloudarmory.io)
  if [[ $demo_exists != "" ]]
  then
    old_ip=$(gcloud dns record-sets list --zone cloudarmory | grep demo.cloudarmory.io | grep -o "[^ ]*$")
    echo "removing old dns record for $old_ip"
    # gcloud dns record-sets transaction abort --zone cloudarmory # kill any previous transaction
    gcloud dns record-sets transaction start --zone cloudarmory
    gcloud dns record-sets transaction remove --zone cloudarmory --name=demo.cloudarmory.io. --type=A --ttl=300 "$old_ip"
    gcloud dns record-sets transaction execute --zone cloudarmory
  fi

  # create new dns record; note
  echo "creating new dns record to $external_ip"
  # gcloud dns record-sets transaction abort --zone cloudarmory # only if previous transaction exists
  gcloud dns record-sets transaction start --zone cloudarmory
  gcloud dns record-sets transaction add --zone cloudarmory --name=demo.cloudarmory.io. --type=A --ttl=300 "$external_ip"
  gcloud dns record-sets transaction execute --zone cloudarmory
}

updateKubeConfig
updateDNS
