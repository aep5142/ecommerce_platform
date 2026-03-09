# =============================================================================
# envs/dev.tfvars — Development environment
# Usage: terraform workspace select dev && terraform apply -var-file=envs/dev.tfvars
#
# Matches the "Deploy Dev" stage in each Jenkinsfile (branch: develop)
# Image tag used by Jenkins: :dev
# Container names: db, frontend, products, orders
# =============================================================================

project_name = "ecommerce"

# Image tags — Jenkins builds these from the 'develop' branch
db_image_tag  = "dev"
app_image_tag = "dev"

# Database credentials
db_user     = "postgres"
db_password = "password"
db_name     = "ecommerce"

# Port mappings — MUST match Jenkinsfile "Deploy Dev" stage
# database Jenkinsfile:  -p 5432:5432
# frontend Jenkinsfile:  -p 3000:3000
# products Jenkinsfile:  -p 3001:3001
# orders   Jenkinsfile:  -p 3002:3002
db_host_port       = 5432
frontend_host_port = 3000
products_host_port = 3001
orders_host_port   = 3002

# Jenkins runs in dev (it IS the CI server for this environment)
enable_jenkins     = true
jenkins_ui_port    = 8080
jenkins_agent_port = 50000

# Minikube — lean config for local development
minikube_driver    = "docker"
kubernetes_version = "v1.28.3"
minikube_cpus      = 2
minikube_memory    = 4096
minikube_disk_size = "20g"
