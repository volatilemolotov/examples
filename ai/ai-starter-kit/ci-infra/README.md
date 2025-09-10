# Terraform GCP Minikube Module

This Terraform module provisions a GCP Compute Instance with Minikube installed and configured for Kubernetes AI starter kits.

## Features

- Automated Minikube installation on GCP Compute Instance
- Automatic kubeconfig retrieval for automation
- Support for both Docker and none drivers
- Configurable instance specifications
- Security best practices with service accounts and firewall rules

## Prerequisites

1. GCP Project with billing enabled
2. Terraform
3. gcloud CLI configured
4. Appropriate GCP permissions:
   - Compute Instance Admin
   - Service Account Admin

## Usage

### 1. Clone the repository

```bash
#repo clone will go here
```

### 2. Configure variables

Edit `default_env.tfvars` with your specific values:

```hcl
project_id = "your-gcp-project-id"
ssh_public_key = "ssh-rsa AAAAB3NzaC1... your-key"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan and Apply

```bash
terraform plan -var-file="default_env.tfvars"

# Apply configuration
terraform apply -var-file="default_env.tfvars"
```

### 5. Access Minikube

After successful deployment:

```bash
# SSH into the instance
$(terraform output -raw ssh_command)

# Use kubectl locally with the retrieved kubeconfig
export KUBECONFIG=$(terraform output -raw kubeconfig_path)
kubectl get nodes

# Or use the kubectl command directly
$(terraform output -raw kubectl_command) get nodes
```

## Automation Integration

The module automatically retrieves the kubeconfig file and stores it locally. For CI/CD pipelines:

```bash
# Get kubeconfig path
KUBECONFIG_PATH=$(terraform output -raw kubeconfig_path)

# Use in automation
kubectl --kubeconfig=$KUBECONFIG_PATH apply -f your-manifests.yaml
```

## Security Considerations

1. **SSH Access**: Restrict `ssh_source_ranges` to your IP
2. **Kubectl Access**: Only enable `enable_external_kubectl` if needed
3. **Service Account**: Uses least-privilege service account

## Cleanup

To destroy all resources:

```bash
terraform destroy -var-file="default_env.tfvars"
```

## Troubleshooting

1. **Kubeconfig retrieval fails**: Wait a few minutes for instance setup to complete
2. **Connection refused**: Check firewall rules and source IP ranges
3. **Minikube not starting**: SSH into instance and check `/var/log/syslog`

The module will output the path to the kubeconfig file and various commands you can use to interact with your Minikube cluster.
