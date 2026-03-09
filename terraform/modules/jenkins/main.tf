terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# =============================================================================
# modules/jenkins/main.tf
# Provisions the Jenkins CI/CD server container.
#
# Only runs when var.enable = true (set via envs/dev.tfvars).
# Jenkins manages pipelines for all 4 services.
#
# Ports:
#   8080  → Jenkins web UI  (http://localhost:8080)
#   50000 → JNLP agent port (Jenkins agents connect here)
# =============================================================================

resource "docker_image" "jenkins" {
  count        = var.enable ? 1 : 0
  name         = "jenkins/jenkins:lts"
  keep_locally = true
}

resource "docker_volume" "jenkins_home" {
  count = var.enable ? 1 : 0
  name  = "jenkins-home-${var.environment}"

  labels {
    label = "environment"
    value = var.environment
  }

  labels {
    label = "managed-by"
    value = "terraform"
  }
}

resource "docker_container" "jenkins" {
  count = var.enable ? 1 : 0
  name  = "jenkins-${var.environment}"
  image = docker_image.jenkins[0].image_id

  networks_advanced {
    name = var.network_id
  }

  # Web UI port
  ports {
    internal = 8080
    external = var.ui_host_port
  }

  # JNLP agent port
  ports {
    internal = 50000
    external = var.agent_host_port
  }

  # Persist Jenkins configuration, jobs, and build history
  volumes {
    volume_name    = docker_volume.jenkins_home[0].name
    container_path = "/var/jenkins_home"
  }

  # Allow Jenkins to run Docker commands on the host (Docker-in-Docker pattern)
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  user    = "root" # Required to access /var/run/docker.sock
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
