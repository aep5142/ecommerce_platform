terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# =============================================================================
# modules/products/main.tf
# Provisions the Products FastAPI service container.
#
# Replicates Jenkinsfile "Deploy *" for products-ecommerce:
#   dev:     docker run -d --name products     -p 3001:3001 --network ecomm-net ...
#   staging: docker run -d --name products-staging -p 3011:3001 --network ecomm-net ...
#   prod:    docker run -d --name products-prod    -p 3002:3001 --network ecomm-net ...
# =============================================================================

resource "docker_image" "products" {
  name         = "aeyzaguirre/products-ecommerce:${var.image_tag}"
  keep_locally = true
}

resource "docker_container" "products" {
  name  = var.environment == "dev" ? "products" : "products-${var.environment}"
  image = docker_image.products.image_id

  networks_advanced {
    name = var.network_id
  }

  ports {
    internal = 3001
    external = var.host_port
  }

  env = [
    "DB_HOST=${var.db_host}",
    "DB_USER=${var.db_user}",
    "DB_PASSWORD=${var.db_password}",
    "DB_NAME=${var.db_name}",
  ]

  restart = "unless-stopped"

  labels {
    label = "environment"
    value = var.environment
  }

  labels {
    label = "managed-by"
    value = "terraform"
  }
}
