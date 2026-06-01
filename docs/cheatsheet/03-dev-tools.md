# Dev Tools

## Python
```bash
python     → python3
pip        → python3 -m pip
pyrun      → poetry run python
pyon       # Activate virtualenv
pyoff      # Deactivate virtualenv
```

## Kubernetes
```bash
k          → kubectl

# Context switching - EU
kdeu       → kubectl config use-context dev-eu-west
kseu       → kubectl config use-context stg-eu-west
kpeu       → kubectl config use-context prd-eu-west

# Context switching - US
kdus       → kubectl config use-context dev-us-west
ksus       → kubectl config use-context stg-us-west
kpus       → kubectl config use-context prd-us-west

# Context switching - AP
ksap       → kubectl config use-context stg-ap-southeast
kpap       → kubectl config use-context prd-ap-southeast

# Context switching - Runtastic
kdrun      → kubectl config use-context runtastic-dev-eu-west
kprun      → kubectl config use-context runtastic-prd-eu-west

# k9s shortcuts
k9dev      → k9s --context runtastic-dev-eu-west
k9prd      → k9s --context runtastic-prd-eu-west
```

## AWS
```bash
awsscdp    → aws --profile cdp_stg
awspcdp    → aws --profile prd_stg
```

## Container Tools
```bash
docker             → podman
docker-compose     → podman-compose
lzd                → lazydocker   # Terminal UI for docker
```
---
