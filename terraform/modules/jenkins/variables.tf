variable "environment" {
  description = "Environment name (dev | staging | prod)"
  type        = string
}

variable "network_id" {
  description = "Docker network ID"
  type        = string
}

variable "enable" {
  description = "Whether to deploy Jenkins in this environment"
  type        = bool
  default     = false
}

variable "ui_host_port" {
  description = "Host port for Jenkins web UI (default 8080)"
  type        = number
  default     = 8080
}

variable "agent_host_port" {
  description = "Host port for Jenkins inbound agents (default 50000)"
  type        = number
  default     = 50000
}
