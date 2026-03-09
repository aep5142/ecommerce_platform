# =============================================================================
# main.tf — Root configuration
# Orchestrates all modules for the ecommerce platform.
# Run with: terraform workspace select <env> && terraform apply -var-file=envs/<env>.tfvars
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }

  # Local backend — state files live on disk, one per workspace.
  # Workspace state paths:
  #   default   → state/terraform.tfstate
  #   dev       → state/terraform.tfstate.d/dev/terraform.tfstate
  #   staging   → state/terraform.tfstate.d/staging/terraform.tfstate
  #   prod      → state/terraform.tfstate.d/prod/terraform.tfstate
  backend "local" {
    path = "state/terraform.tfstate"
  }
}

# =============================================================================
# Providers
# =============================================================================

provider "docker" {
  # Uses the local Docker socket. Ensure Docker Desktop is running.
  host = "unix:///var/run/docker.sock"
}

# =============================================================================
# Local values — derive environment name from workspace
# =============================================================================

locals {
  # The active workspace IS the environment name (dev / staging / prod).
  # This ensures the workspace and var file always stay in sync.
  env = terraform.workspace
}

# =============================================================================
# Module: Docker network
# Creates the shared bridge network all containers communicate over.
# =============================================================================

module "network" {
  source      = "./modules/network"
  environment = local.env
}

# =============================================================================
# Module: Minikube cluster
# Provisions a local Minikube cluster using local-exec (minikube binary).
# Prerequisite: brew install minikube
# =============================================================================

module "minikube" {
  source             = "./modules/minikube"
  environment        = local.env
  cluster_name       = "${var.project_name}-${local.env}"
  driver             = var.minikube_driver
  kubernetes_version = var.kubernetes_version
  cpus               = var.minikube_cpus
  memory             = var.minikube_memory
  disk_size          = var.minikube_disk_size
}

# =============================================================================
# Module: Database (PostgreSQL)
# Mirrors the container Jenkins deploys: same image, same env vars, same ports.
# =============================================================================

module "database" {
  source      = "./modules/database"
  environment = local.env
  network_id  = module.network.network_id
  image_tag   = var.db_image_tag
  host_port   = var.db_host_port
  db_user     = var.db_user
  db_password = var.db_password
  db_name     = var.db_name
}

# =============================================================================
# Module: Products service (FastAPI — port 3001 internal)
# =============================================================================

module "products" {
  source      = "./modules/products"
  environment = local.env
  network_id  = module.network.network_id
  image_tag   = var.app_image_tag
  host_port   = var.products_host_port
  db_host     = module.database.container_name
  db_user     = var.db_user
  db_password = var.db_password
  db_name     = var.db_name

  depends_on = [module.database]
}

# =============================================================================
# Module: Orders service (FastAPI — port 3002 internal)
# =============================================================================

module "orders" {
  source      = "./modules/orders"
  environment = local.env
  network_id  = module.network.network_id
  image_tag   = var.app_image_tag
  host_port   = var.orders_host_port
  db_host     = module.database.container_name
  db_user     = var.db_user
  db_password = var.db_password
  db_name     = var.db_name

  depends_on = [module.database]
}

# =============================================================================
# Module: Frontend (React/Node — port 3000 internal)
# =============================================================================

module "frontend" {
  source      = "./modules/frontend"
  environment = local.env
  network_id  = module.network.network_id
  image_tag   = var.app_image_tag
  host_port   = var.frontend_host_port

  depends_on = [module.database, module.products, module.orders]
}

# =============================================================================
# Module: Jenkins CI/CD server
# Only deployed in dev (the environment where the Jenkins server lives).
# =============================================================================

module "jenkins" {
  source          = "./modules/jenkins"
  environment     = local.env
  network_id      = module.network.network_id
  ui_host_port    = var.jenkins_ui_port
  agent_host_port = var.jenkins_agent_port
  enable          = var.enable_jenkins
}
