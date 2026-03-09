variable "environment" {
  description = "Environment name (dev | staging | prod)"
  type        = string
}

variable "network_id" {
  description = "Docker network ID from the network module"
  type        = string
}

variable "image_tag" {
  description = "Docker Hub image tag (dev | staging | latest)"
  type        = string
}

variable "host_port" {
  description = "Host port mapped to PostgreSQL port 5432 (dev=5432, staging=5433, prod=5434)"
  type        = number
}

variable "db_user" {
  description = "PostgreSQL username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
}
