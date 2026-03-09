terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}

# =============================================================================
# modules/minikube/main.tf
# Provisions and configures a local Minikube Kubernetes cluster.
#
# Uses null_resource + local-exec because Minikube has no maintained
# Terraform provider in the public registry. This is the standard pattern
# for Terraform-managed tools that only have a CLI interface.
#
# Prerequisites (macOS):
#   brew install minikube
#   brew install kubectl
#
# Each environment gets its own named profile so they can coexist:
#   dev     → ecommerce-dev
#   staging → ecommerce-staging
#   prod    → ecommerce-prod
# =============================================================================

resource "null_resource" "minikube_cluster" {
  # Re-run if any of these values change
  triggers = {
    cluster_name       = var.cluster_name
    driver             = var.driver
    kubernetes_version = var.kubernetes_version
    cpus               = tostring(var.cpus)
    memory             = tostring(var.memory)
    disk_size          = var.disk_size
  }

  # Start (or re-configure) the cluster on apply
  provisioner "local-exec" {
    command = <<-EOT
      echo "==> Starting Minikube cluster: ${var.cluster_name}"
      minikube start \
        --profile="${var.cluster_name}" \
        --driver="${var.driver}" \
        --kubernetes-version="${var.kubernetes_version}" \
        --cpus="${var.cpus}" \
        --memory="${var.memory}" \
        --disk-size="${var.disk_size}" \
        --addons=dashboard,metrics-server,default-storageclass,storage-provisioner
      echo "==> Cluster '${var.cluster_name}' is running."
      minikube status --profile="${var.cluster_name}"
    EOT
  }

  # Stop and delete the cluster on destroy
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "==> Deleting Minikube cluster: ${self.triggers.cluster_name}"
      minikube delete --profile="${self.triggers.cluster_name}" || true
      echo "==> Cluster '${self.triggers.cluster_name}' deleted."
    EOT
  }
}

# Retrieve the Minikube cluster IP after the cluster is running.
# Returns a JSON object with a single "ip" key.
data "external" "minikube_ip" {
  depends_on = [null_resource.minikube_cluster]

  program = [
    "bash", "-c",
    "IP=$(minikube ip --profile='${var.cluster_name}' 2>/dev/null || echo 'unknown'); printf '{\"ip\":\"%s\"}' \"$IP\""
  ]
}
