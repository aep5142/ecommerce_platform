output "container_name" {
  description = "Container name (used as DB_HOST by other services on the same network)"
  value       = docker_container.database.name
}

output "container_id" {
  description = "Docker container ID"
  value       = docker_container.database.id
}

output "host_port" {
  description = "Host port the database is reachable on from outside Docker"
  value       = var.host_port
}

output "volume_name" {
  description = "Docker volume storing PostgreSQL data"
  value       = docker_volume.db_data.name
}
