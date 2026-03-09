output "cluster_name" {
  description = "Minikube cluster profile name"
  value       = null_resource.minikube_cluster.triggers.cluster_name
}

output "host" {
  description = "Kubernetes API server endpoint"
  value       = "https://${data.external.minikube_ip.result.ip}:8443"
}

output "cluster_ip" {
  description = "Raw Minikube cluster IP address"
  value       = data.external.minikube_ip.result.ip
}

output "kubeconfig_command" {
  description = "Command to configure kubectl for this cluster"
  value       = "minikube update-context --profile=${null_resource.minikube_cluster.triggers.cluster_name}"
}

output "dashboard_command" {
  description = "Command to open the Kubernetes dashboard"
  value       = "minikube dashboard --profile=${null_resource.minikube_cluster.triggers.cluster_name}"
}
