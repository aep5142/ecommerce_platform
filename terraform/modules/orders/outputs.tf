output "container_name" {
  value = docker_container.orders.name
}

output "container_id" {
  value = docker_container.orders.id
}

output "host_port" {
  value = var.host_port
}
