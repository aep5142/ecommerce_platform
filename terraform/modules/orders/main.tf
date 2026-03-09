terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# =============================================================================
# modules/orders/main.tf
# Provisions the Orders FastAPI service container.
#
# Replicates Jenkinsfile "Deploy *" for orders-ecommerce:
#   dev:     docker run -d --name orders        -p 3002:3002 --network ecomm-net ...
#   staging: docker run -d --name orders-staging   -p 3012:3002 --network ecomm-net ...
#   prod:    docker run -d --name orders-prod       -p 3022:3002 --network ecomm-net ...
# =============================================================================

resource "docker_image" "orders" {
  name         = "aeyzaguirre/orders-ecommerce:${var.image_tag}"
  keep_locally = true
}

resource "docker_container" "orders" {
  name  = var.environment == "dev" ? "orders" : "orders-${var.environment}"
  image = docker_image.orders.image_id

  networks_advanced {
    name = var.network_id
  }

  ports {
    internal = 3002
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
