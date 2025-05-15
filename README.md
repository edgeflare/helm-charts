# HelmCharts packaged by Edgeflare

## TL;DR

```sh
helm repo add edgeflare https://helm.edgeflare.io
helm repo update
helm search repo edgeflare
helm install my-release edgeflare/<chart-name>
```

## Available Charts
#### VPN
- [wireguard-guardian](./charts/wireguard-guardian/)
#### Blockchain
- [fabric-ca](./charts/fabric-ca/)
- [fabric-orderer](./charts/fabric-orderer/)
- [fabric-peer](./charts/fabric-peer/)
- [fabric-channel](./charts/fabric-channel/)
- [fabric-chaincode](./charts/fabric-chaincode/)
- [hyperledger-explorer](./charts/hyperledger-explorer/)

## Quickstart a Hyperledger Fabric Network
### Create channel, and install chaincode-as-a-service
> **The installaton might take up to 5-10 minutes to reconcile**


#### Architecture:
- 2 Orgs, each with 2 peers (peer0.org1, peer1.org1, peer0.org2, peer1.org2)
- 3 Orderering nodes (orderer0, orderer1, orderer2)
- 1 Fabric CA for each org (ca.org1, ca.org2) and 1 CA for orderer (ca.orderer)
- Components of each org is deployed in its own namespace (org1, org2, orderer)

#### Features:
- non-root containers
- only certificates are distributed to participants' namespaces; keys remain in respective org's namespace
- suitable for multi-cloud network

#### Prerequisites:
- Kubernetes cluster (e.g., kind, k3s, EKS, GKE, AKS etc.)
- kubectl and helm installed
- Ensure cert-manager is installed in the cluster
- Optionally instal a [Kubernetes Gateway API controller](https://gateway-api.sigs.k8s.io/guides/#installing-a-gateway-controller) e.g., Istio, Traefik, EnvoyGateway, etc.  See [docs](./docs/) for exposing Fabric network to the internet using TLSRoute CRD of Kubernetes Gateway API. If using Istio, enable alpha TLSRoute CRD:

```shell
kubectl -n istio-system set env deploy/istiod PILOT_ENABLE_ALPHA_GATEWAY_API=true
```

#### Create namespaces for each of orderer and participant orgs

```shell
for ns in org1 org2 orderer; do
  kubectl create ns $ns
done
```

#### Install Fabric CAs
```shell
helm upgrade --install -n org1 ca-org1 edgeflare/fabric-ca --set caOrg=org1 --set 'distributeTLSCACertToOrgs[0]=org2'
helm upgrade --install -n org2 ca-org2 edgeflare/fabric-ca --set caOrg=org2 --set 'distributeTLSCACertToOrgs[0]=org1'
helm upgrade --install -n orderer ca-orderer edgeflare/fabric-ca --set caOrg=orderer --set 'distributeTLSCACertToOrgs[0]=org1' --set 'distributeTLSCACertToOrgs[1]=org2'
```

#### Install Orderers
```shell
helm -n orderer upgrade --install orderer1 edgeflare/fabric-orderer --set orderer.name=orderer1
helm -n orderer upgrade --install orderer2 edgeflare/fabric-orderer --set orderer.name=orderer2
helm -n orderer upgrade --install orderer3 edgeflare/fabric-orderer --set orderer.name=orderer3
```

#### Install Peers
```shell
helm -n org1 upgrade --install peer0-org1 edgeflare/fabric-peer --set peer.name=peer0
helm -n org1 upgrade --install peer1-org1 edgeflare/fabric-peer --set peer.name=peer1
helm -n org2 upgrade --install peer0-org2 edgeflare/fabric-peer --set peer.name=peer0 --set peer.org=org2
helm -n org2 upgrade --install peer1-org2 edgeflare/fabric-peer --set peer.name=peer1 --set peer.org=org2
```

#### Create a channel named `default`, and have all peers, orderers join the channel
```shell
helm -n orderer upgrade --install join-default-genesis edgeflare/fabric-channel
```

#### Install chaincode-as-a-service
```shell
helm -n orderer upgrade --install install-asset-cc edgeflare/fabric-chaincode
```

#### Install Hyperledger Explorer
```shell
helm -n org1 upgrade --install hyperledger-explorer edgeflare/hyperledger-explorer
```

#### Access Hyperledger Explorer
```shell
kubectl -n org1 port-forward svc/hyperledger-explorer 8080:80
```

Hyperledger Explorer can now be accessed at http://localhost:8080. The default username and password is `exploreradmin` and `exploreradminpw`.

#### **Submit transactions using OIDC credentials**
See [fabric-oidc-proxy](https://github.com/edgeflare/fabric-oidc-proxy) for more.

#### cleanup
```shell
for ns in org1 org2 orderer; do
  kubectl delete ns $ns
done
```

## License
Apache License 2.0

## Contributing / Development
If you wanna make it better, please do! Fork the repo, make your changes, and submit a PR.