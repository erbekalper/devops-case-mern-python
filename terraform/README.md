# Terraform Infrastructure

This folder contains Terraform configuration files for provisioning the AWS infrastructure used in the DevOps case project.

## Provisioned Resources

- AWS EC2 instance
- Security Group
- Inbound rules for:
  - SSH
  - Frontend NodePort
  - Backend NodePort
  - Grafana
  - Prometheus
- 20 GB gp3 root disk

## Usage

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Variables

| Variable | Description | Default |
|---|---|---|
| aws_region | AWS region | eu-north-1 |
| instance_type | EC2 instance type | t3.small |
| key_name | Existing AWS EC2 key pair name | devops-case-key |
| ssh_allowed_cidr | Allowed CIDR for SSH access | 0.0.0.0/0 |
| monitoring_allowed_cidr | Allowed CIDR for Grafana and Prometheus | 0.0.0.0/0 |

## Outputs

Terraform outputs the following values:

- EC2 public IP
- Frontend URL
- Backend healthcheck URL
- Grafana URL
- Prometheus URL

## Security Notes

For demo purposes, some ports are opened publicly.

In a production environment:

- SSH should be restricted to trusted IP addresses.
- Grafana and Prometheus should not be exposed directly to the internet.
- Secrets should be stored in a secure secret manager.
- HTTPS, Ingress, Load Balancer, VPN, or private networking should be used.