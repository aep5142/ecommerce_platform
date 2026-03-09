# Phase 5: Kubernetes Deployment

All manifests live under `k8s/` in the orchestrating repo.

## Folder Structure

```
k8s/
  namespaces.yaml        # Defines dev, staging, prod namespaces
  dev/
    configmap.yaml       # Non-sensitive config (DB_HOST, DB_NAME)
    secret.yaml          # Sensitive data (DB_USER, DB_PASSWORD) base64-encoded
    resource-quota.yaml  # Resource caps for the dev namespace
    db-storage.yaml      # PersistentVolume + PersistentVolumeClaim
    database.yaml        # Deployment + ClusterIP Service
    products.yaml        # Deployment + ClusterIP Service + NodePort Service
    orders.yaml          # Deployment + ClusterIP Service + NodePort Service
    frontend.yaml        # Deployment + NodePort Service
  staging/               # Same structure, uses :latest tag (staging tag pushed by Jenkins release/* pipeline)
  prod/                  # Same structure, uses :latest tag, 2 replicas for app services
```

## Namespaces

Three namespaces isolate environments from each other:

| Namespace | Purpose |
|-----------|---------|
| `dev` | Triggered by Jenkins on `develop` branch push |
| `staging` | Triggered by Jenkins on `release/*` branch |
| `prod` | Manual approval deployment from `main` branch |

## Image Tags per Environment

| Environment | Image Tag | Pushed by Jenkins when... |
|-------------|-----------|--------------------------|
| dev | `:dev` | `develop` branch builds |
| staging | `:staging` | `release/*` branch builds |
| prod | `:latest` | `main` branch builds |

## Services Design

Each application service exposes two Kubernetes Services:

- **ClusterIP** — internal cluster communication only (pod-to-pod)
- **NodePort** — external access from the host machine

The database only has a ClusterIP (no external exposure needed).

### Service Names (important)
The orders service calls `http://product-service:3001` in its source code.
Kubernetes DNS resolves service names within the same namespace, so the products
ClusterIP service **must** be named `product-service`.

### NodePort Assignments

| Service | Dev | Staging | Prod |
|---------|-----|---------|------|
| frontend | 30000 | 30010 | 30020 |
| products | 30001 | 30011 | 30021 |
| orders | 30002 | 30012 | 30022 |

## ConfigMaps vs Secrets

| Resource | Contains | Why |
|----------|----------|-----|
| ConfigMap `ecommerce-config` | `DB_HOST`, `DB_NAME`, `DB_PORT` | Non-sensitive, can be stored in plain text |
| Secret `ecommerce-secret` | `DB_USER`, `DB_PASSWORD` | Sensitive, stored base64-encoded, restricted by RBAC |

Pods reference these via `valueFrom.configMapKeyRef` and `valueFrom.secretKeyRef`
instead of hardcoding values in the deployment spec.

## Persistent Volumes

PostgreSQL data is persisted using `hostPath` volumes on the Minikube node.

| Environment | Host Path | Capacity |
|-------------|-----------|----------|
| dev | `/mnt/data/ecommerce-dev` | 1Gi |
| staging | `/mnt/data/ecommerce-staging` | 2Gi |
| prod | `/mnt/data/ecommerce-prod` | 5Gi |

Each environment has its own PersistentVolume (cluster-scoped) and
PersistentVolumeClaim (namespace-scoped). The database pod mounts the PVC
at `/var/lib/postgresql`, so data survives pod restarts.

## Resource Quotas

Each namespace has a ResourceQuota to prevent one environment from consuming
all cluster resources:

| Namespace | Max Pods | CPU Limit | Memory Limit |
|-----------|----------|-----------|--------------|
| dev | 10 | 1 core | 1 Gi |
| staging | 10 | 2 cores | 2 Gi |
| prod | 20 | 10 cores | 10 Gi |

## Deployment Strategy

All Deployments use **RollingUpdate**:

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0
    maxSurge: 1
```

- `maxUnavailable: 0` — never take a pod down before a new one is ready
- `maxSurge: 1` — spin up one extra pod during the update

This ensures zero downtime during image updates triggered by Jenkins.

## Replicas per Environment

| Service | Dev | Staging | Prod |
|---------|-----|---------|------|
| database | 1 | 1 | 1 |
| products | 1 | 1 | 2 |
| orders | 1 | 1 | 2 |
| frontend | 1 | 1 | 2 |

Prod runs 2 replicas for application services to demonstrate high availability.

## Health Probes

Every service has:
- **readinessProbe** — Kubernetes only sends traffic to a pod once this passes
- **livenessProbe** — Kubernetes restarts a pod if this fails

Database probes use `pg_isready`. Application services use HTTP GET on `/health`.

## How to Apply

```bash
# 1. Create namespaces first
kubectl apply -f k8s/namespaces.yaml

# 2. Deploy each environment
kubectl apply -f k8s/dev/
kubectl apply -f k8s/staging/
kubectl apply -f k8s/prod/

# 3. Verify pods
kubectl get pods -n dev
kubectl get pods -n staging
kubectl get pods -n prod

# 4. Get Minikube IP to access NodePort services
minikube ip
# Access dev frontend at: http://<minikube-ip>:30000
# Access staging frontend at: http://<minikube-ip>:30010
# Access prod frontend at: http://<minikube-ip>:30020
```

## State Backup

PersistentVolumes use `persistentVolumeReclaimPolicy: Retain`, meaning the data
on the Minikube host is preserved even if the PVC is deleted. To back up:

```bash
# SSH into Minikube node and copy data
minikube ssh
sudo cp -r /mnt/data/ecommerce-prod /mnt/data/ecommerce-prod-backup-$(date +%Y%m%d)
```
