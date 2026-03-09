# =============================================================================
# envs/prod.tfvars — Production environment
# Usage: terraform workspace select prod && terraform apply -var-file=envs/prod.tfvars
#
# Matches the "Deploy Prod" stage in each Jenkinsfile (branch: main)
# Image tag used by Jenkins: :latest
# Container names: db-prod, frontend-prod, products-prod, orders-prod
# =============================================================================

project_name = "ecommerce"

# Image tags — Jenkins builds these from the 'main' branch (:latest = prod)
db_image_tag  = "latest"
app_image_tag = "latest"

# Database credentials (use strong credentials in a real production environment)
db_user     = "postgres"
db_password = "password"
db_name     = "ecommerce"

# Port mappings — MUST match Jenkinsfile "Deploy Prod" stage
# database Jenkinsfile:  -p 5434:5432
# frontend Jenkinsfile:  -p 3020:3000
# products Jenkinsfile:  -p 3002:3001  ← note: external 3002 maps to internal 3001
# orders   Jenkinsfile:  -p 3022:3002
db_host_port       = 5434
frontend_host_port = 3020
products_host_port = 3002
orders_host_port   = 3022

# Jenkins is NOT deployed in prod
enable_jenkins     = false
jenkins_ui_port    = 8082  # unused
jenkins_agent_port = 50002 # unused

# Minikube — maximum resources for production workloads
minikube_driver    = "docker"
kubernetes_version = "v1.28.3"
minikube_cpus      = 2
minikube_memory    = 6144
minikube_disk_size = "20g"
