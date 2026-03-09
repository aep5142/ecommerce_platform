output "network_id" {
  description = "Docker network ID — passed to every container module"
  value       = docker_network.ecomm.id
}

output "network_name" {
  description = "Docker network name"
  value       = docker_network.ecomm.name
}
