#!/usr/bin/env bash
set -e
kubeargs="--namespace=$KUBE_ENV"

shopt -s expand_aliases
alias kubectl="sudo docker run --rm -v /home/core/.kube:/root/.kube -v /home/core/pipelines/nginx:/root/nginx wernight/kubectl kubectl"


set +e
rcExist=$(kubectl get -o template rc $GO_PIPELINE_NAME --template={{.kind}} $kubeargs)
set -e
if [ "$rcExist" != "ReplicationController" ]; then
  tag=$GO_PIPELINE_NAME:$GO_PIPELINE_LABEL
  sed -i -e "s/\${TAG}/$tag/g" scripts/rc.yaml
  kubectl create -f /root/nginx/scripts/rc.yml $kubeargs
else
  kubectl rolling-update $GO_PIPELINE_NAME --image=canthefason/$GO_PIPELINE_NAME:$GO_PIPELINE_LABEL --update-period=20s $kubeargs
fi

set +e
svcExist=$(kubectl get -o template svc $GO_PIPELINE_NAME --template={{.kind}} $kubeargs)
set -e
if [ "$svcExist" != "Service" ]; then
  kubectl create -f /root/nginx/scripts/svc.yml $kubeargs
fi
