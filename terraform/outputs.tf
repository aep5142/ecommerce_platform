# =============================================================================
# outputs.tf — Values exported for CI/CD pipeline consumption
#
# In Jenkins, retrieve these with:
#   cd terraform && terraform output -raw <output_name>
#
# Example Jenkinsfile usage:
#   script {
#     env.DB_HOST      = sh(script: "cd terraform && terraform output -raw db_host",      returnStdout: true).trim()
#     env.PRODUCTS_URL = sh(script: "cd terraform && terraform output -raw products_url",  returnStdout: true).trim()
#   }
# =============================================================================

# --- Environment --------------------------------------------------------------

output "environment" {
  description = "Active Terraform workspace / environment name"
  value       = terraform.workspace
}

# --- Docker network -----------------------------------------------------------

output "docker_network_name" {
  description = "Name of the shared Docker bridge network"
  value       = module.network.network_name
}

output "docker_network_id" {
  description = "Docker network ID"
  value       = module.network.network_id
}

# --- Database -----------------------------------------------------------------

output "db_host" {
  description = "Hostname of the database container (used by app services)"
  value       = module.database.container_name
}

output "db_host_port" {
  description = "Host port exposed by the database container"
  value       = module.database.host_port
}

output "db_connection_string" {
  description = "PostgreSQL connection string (for tools/pipelines)"
  value       = "postgresql://${var.db_user}:${var.db_password}@localhost:${module.database.host_port}/${var.db_name}"
  sensitive   = true
}

# --- Frontend -----------------------------------------------------------------

output "frontend_url" {
  description = "URL to access the React frontend"
  value       = "http://localhost:${module.frontend.host_port}"
}

output "frontend_host_port" {
  description = "Host port the frontend is listening on"
  value       = module.frontend.host_port
}

# --- Products API -------------------------------------------------------------

output "products_url" {
  description = "URL to access the Products API"
  value       = "http://localhost:${module.products.host_port}"
}

output "products_host_port" {
  description = "Host port the Products API is listening on"
  value       = module.products.host_port
}

# --- Orders API ---------------------------------------------------------------

output "orders_url" {
  description = "URL to access the Orders API"
  value       = "http://localhost:${module.orders.host_port}"
}

output "orders_host_port" {
  description = "Host port the Orders API is listening on"
  value       = module.orders.host_port
}

# --- Jenkins ------------------------------------------------------------------

output "jenkins_url" {
  description = "URL to access the Jenkins UI (only available when enable_jenkins=true)"
  value       = var.enable_jenkins ? "http://localhost:${module.jenkins.ui_port}" : "Jenkins not deployed in this environment"
}

# --- Minikube -----------------------------------------------------------------

output "minikube_cluster_name" {
  description = "Minikube cluster profile name"
  value       = module.minikube.cluster_name
}

output "minikube_host" {
  description = "Kubernetes API server endpoint"
  value       = module.minikube.host
}

output "minikube_kubeconfig_command" {
  description = "Run this to point kubectl at this environment's cluster"
  value       = module.minikube.kubeconfig_command
}

output "minikube_dashboard_command" {
  description = "Run this to open the Kubernetes web dashboard"
  value       = module.minikube.dashboard_command
}

# --- Docker registry ----------------------------------------------------------

output "docker_registry" {
  description = "Docker Hub registry prefix used by all services"
  value       = "aeyzaguirre"
}

output "image_tag" {
  description = "Image tag currently deployed in this environment"
  value       = var.app_image_tag
}

# --- Summary (human-readable) ------------------------------------------------

output "service_summary" {
  description = "Quick-reference map of all service URLs for this environment"
  value = {
    environment = terraform.workspace
    frontend    = "http://localhost:${module.frontend.host_port}"
    products    = "http://localhost:${module.products.host_port}"
    orders      = "http://localhost:${module.orders.host_port}"
    database    = "localhost:${module.database.host_port}"
    jenkins     = var.enable_jenkins ? "http://localhost:${module.jenkins.ui_port}" : "N/A"
    minikube    = module.minikube.host
  }
}
