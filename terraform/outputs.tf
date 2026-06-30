output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.devops_case_ec2.public_ip
}

output "frontend_url" {
  description = "Frontend application URL"
  value       = "http://${aws_instance.devops_case_ec2.public_ip}:30080"
}

output "backend_healthcheck_url" {
  description = "Backend healthcheck URL"
  value       = "http://${aws_instance.devops_case_ec2.public_ip}:30505/healthcheck"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "http://${aws_instance.devops_case_ec2.public_ip}:30300"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${aws_instance.devops_case_ec2.public_ip}:30090"
}