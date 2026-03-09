terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# =============================================================================
# modules/database/main.tf
# Provisions the PostgreSQL container.
#
# Replicates exactly what each Jenkinsfile "Deploy *" stage does:
#   docker run -d --name <db_container_name> --network ecomm-net \
#     -p <host_port>:5432 \
#     -e POSTGRES_USER=postgres \
#     -e POSTGRES_PASSWORD=password \
#     -e POSTGRES_DB=ecommerce \
#     aeyzaguirre/database-ecommerce:<tag>
# =============================================================================

# Pull the image from Docker Hub
resource "docker_image" "database" {
  name         = "aeyzaguirre/database-ecommerce:${var.image_tag}"
  keep_locally = true # don't delete the image when terraform destroy runs
}

resource "docker_container" "database" {
  # Name convention mirrors Jenkinsfile:
  #   dev     → "db"
  #   staging → "db-staging"
  #   prod    → "db-prod"
  name  = var.environment == "dev" ? "db" : "db-${var.environment}"
  image = docker_image.database.image_id

  # Attach to the shared ecomm-net network
  networks_advanced {
    name = var.network_id
  }

  # Expose host_port → internal 5432
  ports {
    internal = 5432
    external = var.host_port
  }

  # PostgreSQL environment variables (same as Dockerfile defaults)
  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}",
    # Kept for compatibility with app services that read DB_* variables
    "DB_HOST=db",
    "DB_USER=${var.db_user}",
    "DB_PASSWORD=${var.db_password}",
    "DB_NAME=${var.db_name}",
  ]

  # Persist data between container restarts.
  # postgres:latest (v18+) changed the data directory layout.
  # Mount the parent /var/lib/postgresql so postgres manages its own subdirectory.
  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/postgresql"
  }

  # Healthcheck mirrors docker-compose.yml
  healthcheck {
    test         = ["CMD-SHELL", "pg_isready -U ${var.db_user}"]
    interval     = "5s"
    timeout      = "5s"
    retries      = 5
    start_period = "10s"
  }

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

# Named volume so PostgreSQL data survives container recreation
resource "docker_volume" "db_data" {
  name = var.environment == "dev" ? "db-data" : "db-data-${var.environment}"

  labels {
    label = "environment"
    value = var.environment
  }
}
