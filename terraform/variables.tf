# =============================================================================
# variables.tf — Root variable declarations
# Values are supplied by environment-specific .tfvars files in envs/
# =============================================================================

# --- Project metadata ---------------------------------------------------------

variable "project_name" {
  description = "Prefix applied to all resource names"
  type        = string
  default     = "ecommerce"
}

# --- Docker Hub image tags ----------------------------------------------------
# Jenkins builds tag images as: dev (develop branch), staging (release/*), latest (main)

variable "db_image_tag" {
  description = "Docker Hub tag for the database image (aeyzaguirre/database-ecommerce)"
  type        = string
}

variable "app_image_tag" {
  description = "Docker Hub tag for frontend/products/orders images"
  type        = string
}

# --- Database credentials (shared across all services) ------------------------

variable "db_user" {
  description = "PostgreSQL username"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  default     = "password"
  sensitive   = true
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "ecommerce"
}

# --- Host port mappings -------------------------------------------------------
# These MUST match the ports used in each service's Jenkinsfile Deploy stage.
# dev:     db=5432, frontend=3000, products=3001, orders=3002
# staging: db=5433, frontend=3010, products=3011, orders=3012
# prod:    db=5434, frontend=3020, products=3002, orders=3022

variable "db_host_port" {
  description = "Host port mapped to PostgreSQL (5432 internal)"
  type        = number
}

variable "frontend_host_port" {
  description = "Host port mapped to the React frontend (3000 internal)"
  type        = number
}

variable "products_host_port" {
  description = "Host port mapped to the Products API (3001 internal)"
  type        = number
}

variable "orders_host_port" {
  description = "Host port mapped to the Orders API (3002 internal)"
  type        = number
}

# --- Jenkins ------------------------------------------------------------------

variable "jenkins_ui_port" {
  description = "Host port for Jenkins web UI"
  type        = number
  default     = 8080
}

variable "jenkins_agent_port" {
  description = "Host port for Jenkins inbound agents (JNLP)"
  type        = number
  default     = 50000
}

variable "enable_jenkins" {
  description = "Deploy Jenkins container in this environment. Typically true only for dev."
  type        = bool
  default     = false
}

# --- Minikube -----------------------------------------------------------------

variable "minikube_driver" {
  description = "Minikube driver (docker | hyperkit | virtualbox)"
  type        = string
  default     = "docker"
}

variable "kubernetes_version" {
  description = "Kubernetes version for Minikube cluster"
  type        = string
  default     = "v1.28.3"
}

variable "minikube_cpus" {
  description = "vCPUs allocated to the Minikube cluster"
  type        = number
  default     = 2
}

variable "minikube_memory" {
  description = "Memory (MB) allocated to the Minikube cluster"
  type        = number
  default     = 4096
}

variable "minikube_disk_size" {
  description = "Disk size for the Minikube cluster (e.g. 20g)"
  type        = string
  default     = "20g"
}
