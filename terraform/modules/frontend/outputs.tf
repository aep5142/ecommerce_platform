output "container_name" {
  value = docker_container.frontend.name
}

output "container_id" {
  value = docker_container.frontend.id
}

output "host_port" {
  value = var.host_port
}
