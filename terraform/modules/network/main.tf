terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# =============================================================================
# modules/network/main.tf
# Creates the Docker bridge network shared by all containers.
# Mirrors the "ecomm-net" network used in every Jenkinsfile deploy step.
# =============================================================================

resource "docker_network" "ecomm" {
  # In dev the network is named "ecomm-net" (exact name Jenkins uses).
  # In staging/prod it is "ecomm-net-staging" / "ecomm-net-prod" so the
  # environments stay fully isolated on the same Docker host.
  name = var.environment == "dev" ? "ecomm-net" : "ecomm-net-${var.environment}"

  driver = "bridge"

  labels {
    label = "environment"
    value = var.environment
  }

  labels {
    label = "managed-by"
    value = "terraform"
  }
}
