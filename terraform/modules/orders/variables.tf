variable "environment" {
  description = "Environment name (dev | staging | prod)"
  type        = string
}

variable "network_id" {
  description = "Docker network ID"
  type        = string
}

variable "image_tag" {
  description = "Docker Hub image tag (dev | staging | latest)"
  type        = string
}

variable "host_port" {
  description = "Host port mapped to Orders API port 3002 (dev=3002, staging=3012, prod=3022)"
  type        = number
}

variable "db_host" {
  description = "Database container hostname on the Docker network (matches the container name)"
  type        = string
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
