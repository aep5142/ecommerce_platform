terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# =============================================================================
# modules/frontend/main.tf
# Provisions the React/Node.js frontend container.
#
# Replicates Jenkinsfile "Deploy *" for frontend-ecommerce:
#   dev:     docker run -d --name frontend          -p 3000:3000 --network ecomm-net ...
#   staging: docker run -d --name frontend-staging     -p 3010:3000 --network ecomm-net ...
#   prod:    docker run -d --name frontend-prod         -p 3020:3000 --network ecomm-net ...
# =============================================================================

resource "docker_image" "frontend" {
  name         = "aeyzaguirre/frontend-ecommerce:${var.image_tag}"
  keep_locally = true
}

resource "docker_container" "frontend" {
  name  = var.environment == "dev" ? "frontend" : "frontend-${var.environment}"
  image = docker_image.frontend.image_id

  networks_advanced {
    name = var.network_id
  }

  ports {
    internal = 3000
    external = var.host_port
  }

  # The frontend does not need DB vars directly — it talks to products/orders APIs
  env = [
    "NODE_ENV=${var.environment == "prod" ? "production" : "development"}",
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
