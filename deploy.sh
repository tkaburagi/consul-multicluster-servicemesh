#!/bin/sh

gcloud container clusters get-credentials lab-cluster --zone asia-northeast1-a --project se-kabu

if [ $1 = 1 ]; then
  kubectl delete -f corp.yaml -n=multicluster-servicemesh
  kubectl delete -f hashicorpx.yaml -n=multicluster-servicemesh
  kubectl get all -n=multicluster-servicemesh
elif [ $1 = 0 ]; then
  kubectl apply -f corp.yaml -n=multicluster-servicemesh
  kubectl apply -f hashicorpx.yaml -n=multicluster-servicemesh
  kubectl get all -n=multicluster-servicemesh
fi

#aws eks --region ap-northeast-1 update-kubeconfig --name consul-mesh-gateway-cluster-2

if [ $1 = 1 ]; then
  kubectl delete -f japan.yaml -n=multicluster-servicemesh
  kubectl delete -f france.yaml -n=multicluster-servicemesh
elif [ $1 = 0 ]; then
  kubectl apply -f japan.yaml -n=multicluster-servicemesh
  kubectl apply -f france.yaml -n=multicluster-servicemesh
fi
