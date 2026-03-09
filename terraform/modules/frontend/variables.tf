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
  description = "Host port mapped to React app port 3000 (dev=3000, staging=3010, prod=3020)"
  type        = number
}
