# utility-vm

Terraform repo for suncoast systems proxmox utility vm. Will host utilities for K8S system.

## Features

- **Harbor Container Registry** (v2.11.1) with proxy cache for Docker Hub, GCR, Quay.io, etc.
- **Dex OIDC Provider** for GitHub OAuth integration with Harbor
- Performance-optimized networking and system configuration
- Automated setup and deployment scripts

## Services

### Harbor Container Registry

- **URL**: `https://harbor.${RANCHER_DOMAIN}`
- **Internal URL**: `http://utility-node.internal.lan`
- **Auth**: Database (admin/Harbor12345) or GitHub OAuth via Dex
- **Proxy Cache Projects**: dockerhub, gcr, quay, k8s-gcr, registry-k8s

## Configuration Variables

## Usage

### Deploy VM

```bash
terraform init
terraform plan
terraform apply
```

### Harbor Management

```bash
# Check Harbor status
harbor-manage status

# View logs
harbor-manage logs

# Check authentication status
harbor-manage auth-status
```

## Network Architecture

- **VM IP**: `10.0.0.200/24`
- **Service Access**:
  - **Harbor**: Available via LAN, Tailscale network, and optionally public internet (port 443)
  - **Rancher GUI**: Available via LAN and optionally public internet via Tailscale Funnel (port 8443)
  - **APISIX Dashboard**: Available locally and optionally public internet via Tailscale Funnel (port 9000)
