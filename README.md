# rishat.space

- My personal website.


## TechStack

* GoLang
* GoHugo

# How to develop?
```bash
cd source
hugo server
```

# How to run?
## Docker-compose (Production)

1. Build and run
```bash
docker-compose -f docker-compose.yml build
docker-compose -f docker-compose.yml up -d
```

## K8S (Production)

1. Create service account in your k8s cluster
```bash
cd k8s/production

./service-account-for-cd.sh
```

3. Deploy manifests
```bash
kubectl apply -f deployment.yaml
```