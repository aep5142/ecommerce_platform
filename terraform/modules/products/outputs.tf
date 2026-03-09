output "container_name" {
  value = docker_container.products.name
}

output "container_id" {
  value = docker_container.products.id
}

output "host_port" {
  value = var.host_port
}
