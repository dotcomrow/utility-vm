# Harbor GitHub OIDC Authentication Setup

This document explains how to configure Harbor with GitHub OIDC (OpenID Connect) authentication using GitHub OAuth App.

## Prerequisites

1. A GitHub organization with the following teams:
   - `harbor_admins` - Users who will have full administrative access to Harbor
   - `harbor_users` - Users who will have read-only access to proxy cache projects

2. GitHub OAuth App configured in your organization

## GitHub OAuth App Setup

1. **Create a GitHub OAuth App:**
   - Go to your GitHub organization settings
   - Navigate to `Developer settings` > `OAuth Apps`
   - Click `New OAuth App`

2. **OAuth App Configuration:**
   - **Application name:** `Harbor Registry`
   - **Homepage URL:** `http://10.0.0.200` (or your Harbor instance URL)
   - **Authorization callback URL:** `http://10.0.0.200/c/oidc/callback`
   - **Application description:** `Harbor Container Registry with OIDC Authentication`

3. **After creating the app:**
   - Note down the `Client ID`
   - Generate a new `Client Secret` and note it down

## GitHub Teams Setup

1. **Create Teams in your GitHub Organization:**
   ```bash
   # harbor_admins team - Full Harbor administrative access
   # harbor_users team - Read-only access to proxy cache projects
   ```

2. **Add users to appropriate teams:**
   - Add Harbor administrators to `harbor_admins` team
   - Add regular users to `harbor_users` team

## Terraform Configuration

1. **Set the required variables in your `.tfvars` file:**
   ```hcl
   GITHUB_OIDC_CLIENT_ID     = "your_github_oauth_client_id"
   GITHUB_OIDC_CLIENT_SECRET = "your_github_oauth_client_secret"
   ```

2. **Deploy the infrastructure:**
   ```bash
   terraform plan
   terraform apply
   ```

## Harbor OIDC Configuration

The Terraform configuration will automatically:

1. **Configure Harbor with OIDC settings:**
   - Set authentication mode to `oidc_auth`
   - Configure GitHub as the OIDC provider
   - Set up user and group claims mapping

2. **Create user groups:**
   - `harbor_admins` - System administrators
   - `harbor_users` - Read-only users

3. **Configure role-based access:**
   - `harbor_admins` team members get full system admin privileges
   - `harbor_users` team members get read-only access to proxy cache projects

## Post-Deployment Steps

### 1. Test GitHub OIDC Login

1. Navigate to Harbor web UI: `http://10.0.0.200`
2. Click "Login via OIDC Provider" instead of using admin credentials
3. You'll be redirected to GitHub for authentication
4. Authorize the Harbor application
5. You should be logged into Harbor with appropriate permissions

### 2. Disable Built-in Admin Account (IMPORTANT)

**⚠️ Only do this after confirming GitHub OIDC login works and you have admin access through a GitHub team member:**

1. Login to Harbor via GitHub OIDC as a member of `harbor_admins` team
2. Go to `Administration` > `Users`
3. Find the `admin` user and click the three dots menu
4. Select `Disable User`
5. Confirm the action

### 3. Verify Team-based Access Control

**For harbor_admins team members:**
- Should have access to Administration panel
- Can create/modify projects
- Can manage users and groups
- Can configure system-wide settings

**For harbor_users team members:**
- Can browse and pull from proxy cache projects:
  - `dockerhub` (Docker Hub proxy)
  - `gcr` (Google Container Registry proxy)
  - `quay` (Quay.io proxy)
  - `k8s-gcr` (Kubernetes GCR proxy)
  - `registry-k8s` (Kubernetes Registry proxy)
- Cannot access Administration panel
- Cannot create new projects

## Using Harbor as Pull-Through Cache

After OIDC authentication is configured, you can use Harbor as a pull-through cache:

```bash
# Instead of: docker pull nginx:latest
docker pull 10.0.0.200/dockerhub/nginx:latest

# Instead of: docker pull gcr.io/project/image:tag
docker pull 10.0.0.200/gcr/project/image:tag

# Instead of: docker pull quay.io/repo/image:tag
docker pull 10.0.0.200/quay/repo/image:tag
```

## Troubleshooting

### OIDC Login Issues

1. **Check GitHub OAuth App configuration:**
   - Verify callback URL matches: `http://10.0.0.200/c/oidc/callback`
   - Ensure app is enabled and not suspended

2. **Check Harbor logs:**
   ```bash
   # On Harbor VM
   docker-compose -f /opt/harbor/docker-compose.yml logs core
   ```

3. **Verify team membership:**
   - Ensure users are members of `harbor_admins` or `harbor_users` teams
   - Check team visibility settings in GitHub

### Permission Issues

1. **User cannot access admin features:**
   - Verify user is member of `harbor_admins` team
   - Check that team name matches exactly in configuration

2. **User cannot pull images:**
   - Verify user is member of `harbor_users` or `harbor_admins` team
   - Check project permissions in Harbor UI

### Network Issues

1. **Cannot access Harbor UI:**
   - Verify VM is running: `proxmox_virtual_environment_vm.utility_vm`
   - Check if Harbor services are running: `harbor-manage status`
   - Verify network connectivity to 10.0.0.200

## Security Considerations

1. **OAuth App Security:**
   - Keep Client Secret secure and rotate regularly
   - Use environment variables or secret management for Client ID/Secret
   - Monitor OAuth app usage in GitHub organization settings

2. **Harbor Security:**
   - Disable the built-in admin account after OIDC setup
   - Regularly review user and group permissions
   - Monitor Harbor access logs

3. **Network Security:**
   - Consider enabling HTTPS for production deployments
   - Implement proper firewall rules
   - Use private networks when possible

## Management Commands

```bash
# Harbor service management
harbor-manage start    # Start Harbor
harbor-manage stop     # Stop Harbor
harbor-manage restart  # Restart Harbor
harbor-manage status   # Check Harbor status
harbor-manage logs     # View Harbor logs
```
