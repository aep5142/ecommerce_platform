variable "environment" {
  description = "Environment name (dev | staging | prod)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Minikube cluster (e.g. ecommerce-dev)"
  type        = string
}

variable "driver" {
  description = "Minikube driver: docker | hyperkit | virtualbox"
  type        = string
  default     = "docker"
}

variable "kubernetes_version" {
  description = "Kubernetes version (e.g. v1.28.3)"
  type        = string
  default     = "v1.28.3"
}

variable "cpus" {
  description = "Number of vCPUs to allocate to the cluster"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in MB to allocate to the cluster"
  type        = number
  default     = 4096
}

variable "disk_size" {
  description = "Disk size for the cluster (e.g. 20g)"
  type        = string
  default     = "20g"
}
