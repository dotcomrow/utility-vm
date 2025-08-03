# utility-vm

Terraform repo for suncoast systems proxmox utility vm. Will host utilities for K8S system.

## Features

- **Harbor Container Registry** (v2.11.1) with proxy cache for Docker Hub, GCR, Quay.io, etc.
- **Dex OIDC Provider** for GitHub OAuth integration with Harbor
- **Tailscale VPN** with subnet routing and Funnel support for secure remote access
- Performance-optimized networking and system configuration
- Automated setup and deployment scripts

## Services

### Harbor Container Registry

- **URL**: `https://harbor.${RANCHER_DOMAIN}`
- **Internal URL**: `http://utility-node.internal.lan`
- **Auth**: Database (admin/Harbor12345) or GitHub OAuth via Dex
- **Proxy Cache Projects**: dockerhub, gcr, quay, k8s-gcr, registry-k8s

### Tailscale VPN

- **Subnet Router**: Advertises `10.0.0.0/24` to Tailscale network
- **Multi-Service Funnel**: Optional public HTTPS access to Harbor, Rancher GUI, and APISIX Dashboard
- **Management**: Use `tailscale-manage` command

## Configuration Variables

### Required Variables

```hcl
variable "TAILSCALE_AUTH_KEY" {
  description = "Tailscale authentication key for automatic connection"
  type        = string
  sensitive   = true
}
```

### Optional Variables

```hcl
variable "TAILSCALE_FUNNEL_ENABLED" {
  description = "Enable Tailscale Funnel for public access to Harbor, Rancher, and APISIX"
  type        = bool
  default     = false
}
```

## Usage

### Deploy VM

```bash
terraform init
terraform plan
terraform apply
```

### Tailscale Management

```bash
# Check status and service URLs
tailscale-manage status

# Show detailed service information
tailscale-manage services

# Connect with auth key
tailscale-manage up tskey-auth-xxxxx

# Enable public Funnel access for all services
tailscale-manage funnel-enable

# Disable Funnel
tailscale-manage funnel-disable
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
- **Tailscale Subnet**: `10.0.0.0/24` (advertised to Tailscale network)
- **Service Access**:
  - **Harbor**: Available via LAN, Tailscale network, and optionally public internet (port 443)
  - **Rancher GUI**: Available via LAN and optionally public internet via Tailscale Funnel (port 8443)
  - **APISIX Dashboard**: Available locally and optionally public internet via Tailscale Funnel (port 9000)
