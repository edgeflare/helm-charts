```shell
helm install -n org2 ca-org2 edgeflare/fabric-ca --set caOrg=org2 --set 'distributeTLSCACertToOrgs[0]=org1' --set 'distributeTLSCACertToOrgs[1]=org3'
```