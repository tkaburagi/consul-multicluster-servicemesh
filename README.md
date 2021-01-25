<kbd>
  <img src="https://github-image-tkaburagi.s3-ap-northeast-1.amazonaws.com/my-github-repo/multicluster-servicemesh.png">
</kbd>

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

### Deploy UI App on Pivotal Web Services

```shell script
git clone https://github.com/tkaburagi/mesh-ui
./mvnw clean package -DskipTests
cf push mesh-ui  --random-route -p target/demo-0.0.1-SNAPSHOT.jar
```

## Temrinating Gateway

### Deploy UI App on Google Compute Engine

This Instance is public, you can use with the same parameters in `regist-hashi.json`

```shell script
curl --request PUT --data @terminating-gateway/regist-hashi.json -k $CONSUL_HTTP_ADDR/v1/catalog/register
consul config write proxy-config/hashi-svc-defaults.hcl
consul config write terminating-gateway/terminating-gateway.hcl
```

## Mesh Gateway


### GKE 