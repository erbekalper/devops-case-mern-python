variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "c7i-flex.large"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
  default     = "devops-case-key"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to access SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "monitoring_allowed_cidr" {
  description = "CIDR block allowed to access Grafana and Prometheus"
  type        = string
  default     = "0.0.0.0/0"
}