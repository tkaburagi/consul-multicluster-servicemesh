<kbd>
  <img src="https://github-image-tkaburagi.s3-ap-northeast-1.amazonaws.com/my-github-repo/multicluster-servicemesh.png">
</kbd>

# Blog post
**This post shows detailed instructions and how to setup.**

## setup

```shell script
eksctl create cluster \
    --name=consul-mesh-gateway-cluster-2 \
    --nodes=3 \
    --node-ami=auto \
    --region=ap-northeast-1 \
    --version=1.16
```

```shell script
gcloud container clusters create consul-mesh-gateway-cluster-1 --num-nodes=3
```

```shell script
gcloud container clusters get-credentials consul-mesh-gateway-cluster-1 --zone asia-northeast1-a --project se-kabu
kc apply -f ns.yaml
helm install -f helm/consul-values-gke.yaml consul hashicorp/consul  --wait -n multicluster-servicemesh
kc get secret consul-federation -o yaml -n multicluster-servicemesh > consul-federation-secret.yaml
```

```shell script
aws eks --region ap-northeast-1 update-kubeconfig --name consul-mesh-gateway-cluster-2
kc apply -f ns.yaml
kc apply -f consul-federation-secret.yaml
helm install -f helm/consul-values-eks.yaml consul hashicorp/consul  --wait -n multicluster-servicemesh
```

```shell script
./deploy.sh 0
```

## setup Procy config
```shell script
export CONSUL_HTTP_ADDR=xxx # GKE
consul config write proxy-config/hcx-svc-router.hcl
consul config write ingress-gateway/ingress-gateway.hcl
consul config write ingress-gateway/teminating-gateway.hcl
consul config write proxy-config/japan-svc-defaults.hcl
consul config write proxy-config/france-svc-defaults.hcl
consul config write proxy-config/corp-svc-defaults.hcl
consul config write proxy-config/country-svc-defaults.hcl
consul config write proxy-config/country-svc-router.hcl
```

## Ingress Gateway

### Deploy UI App on Heroku

**Pivotal Web Services has been depricated.** Please use Heroku instead.

```console
$ git clone -b heroku https://github.com/tkaburagi/mesh-ui
$ rm -rf .git
$ heroku login
$ git init
$ git add .
$ git commit -m "first commit"
$ heroku create
```

```console
$ kubectl get svc -n=multicluster-sevicemesh | grep consul-ingress-gateway
consul-ingress-gateway        LoadBalancer   10.0.39.98    35.224.90.180    8080:30948/TCP,8443:30402/TCP                                             21h
```

```console
$ git push heroku master
$ heroku config:set ingress_url=<INGRESSGW_IP>:8080
$ heroku config:set service_fqdn=hashicorpx.ingress.dc-1.consul:8080
$ heroku open
```

## Temrinating Gateway

### Deploy UI App on Google Compute Engine

This Instance is public, you can use with the same parameters in `regist-hashi.json`

```shell script
curl --request PUT --data @terminating-gateway/regist-hashi.json -k $CONSUL_HTTP_ADDR/v1/catalog/register
consul config write proxy-config/hashi-svc-defaults.hcl
consul config write terminating-gateway/terminating-gateway.hcl
```

## Consul UI
<kbd>
  <img src="https://github-image-tkaburagi.s3-ap-northeast-1.amazonaws.com/my-github-repo/dc-1.png">
</kbd>
<kbd>
  <img src="https://github-image-tkaburagi.s3-ap-northeast-1.amazonaws.com/my-github-repo/dc-2.png">
</kbd>

## Access to App
* `https://<random-route>.herokuapp.com/japan`

<kbd>
  <img src="https://github-image-tkaburagi.s3-ap-northeast-1.amazonaws.com/my-github-repo/japan.png">
</kbd>

* `https://<random-route>.herokuapp.com/france`

<kbd>
  <img src="https://github-image-tkaburagi.s3-ap-northeast-1.amazonaws.com/my-github-repo/france.png">
</kbd>
