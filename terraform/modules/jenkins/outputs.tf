output "container_name" {
  description = "Jenkins container name (empty string if not deployed)"
  value       = var.enable ? docker_container.jenkins[0].name : ""
}

output "container_id" {
  description = "Jenkins container ID (empty string if not deployed)"
  value       = var.enable ? docker_container.jenkins[0].id : ""
}

output "ui_port" {
  description = "Host port for the Jenkins web UI"
  value       = var.ui_host_port
}

output "agent_port" {
  description = "Host port for Jenkins JNLP agents"
  value       = var.agent_host_port
}

output "volume_name" {
  description = "Volume storing Jenkins home directory"
  value       = var.enable ? docker_volume.jenkins_home[0].name : ""
}
