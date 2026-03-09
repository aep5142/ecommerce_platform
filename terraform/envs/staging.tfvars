# =============================================================================
# envs/staging.tfvars — Staging environment
# Usage: terraform workspace select staging && terraform apply -var-file=envs/staging.tfvars
#
# Matches the "Deploy Staging" stage in each Jenkinsfile (branch: release/*)
# Image tag used by Jenkins: :staging
# Container names: db-staging, frontend-staging, products-staging, orders-staging
# =============================================================================

project_name = "ecommerce"

# Image tags — Jenkins builds these from a 'release/*' branch
db_image_tag  = "staging"
app_image_tag = "staging"

# Database credentials (same as dev for simplicity — override per your policy)
db_user     = "postgres"
db_password = "password"
db_name     = "ecommerce"

# Port mappings — MUST match Jenkinsfile "Deploy Staging" stage
# database Jenkinsfile:  -p 5433:5432
# frontend Jenkinsfile:  -p 3010:3000
# products Jenkinsfile:  -p 3011:3001
# orders   Jenkinsfile:  -p 3012:3002
db_host_port       = 5433
frontend_host_port = 3010
products_host_port = 3011
orders_host_port   = 3012

# Jenkins is NOT deployed here (dev Jenkins drives staging deploys too)
enable_jenkins     = false
jenkins_ui_port    = 8081  # unused, but variable must be set
jenkins_agent_port = 50001 # unused

# Minikube — slightly more resources for integration testing
minikube_driver    = "docker"
kubernetes_version = "v1.28.3"
minikube_cpus      = 2
minikube_memory    = 6144
minikube_disk_size = "30g"
